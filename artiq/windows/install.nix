{ pkgs ? import <nixpkgs> {},
  diskImageSize ? "20G",
  qemuMem ? "4G",
}:

with pkgs;

let
  windowsIso = fetchurl {
    url = "https://software-download.microsoft.com/download/sg/17763.107.101029-1455.rs5_release_svc_refresh_CLIENT_LTSC_EVAL_x64FRE_en-us.iso";
    sha256 = "668fe1af70c2f7416328aee3a0bb066b12dc6bbd2576f40f812b95741e18bc3a";
  };
  # Newer Miniconda contains unusable OpenSSL, preventing any package fetching
  miniconda = fetchurl {
    url = "https://repo.anaconda.com/miniconda/Miniconda3-4.5.11-Windows-x86_64.exe";
    sha256 = "1kyf03571fhxd0a9f8bcpmqfdpw7461kclfyb4yb3dsi783y4sck";
  };

  qemu = qemu_kvm;
  runQemu = extraArgs:
    let
      args = [
        "-enable-kvm"
        "-m" qemuMem
        "-bios" "${OVMF.fd}/FV/OVMF.fd"
        "-netdev" "user,id=n1,hostfwd=tcp::2022-:22" "-device" "e1000,netdev=n1"
      ];
      argStr = lib.escapeShellArgs (args ++ extraArgs);
    in "${qemu}/bin/qemu-system-x86_64 ${argStr}";

  sshUser = "user";
  sshPassword = "user";
  sshOpts = "-o StrictHostKeyChecking=accept-new -o UserKnownHostsFile=\\$TMPDIR/known_hosts";
  ssh = cmd: ''
    echo "ssh windows \"${cmd}\""
    ${sshpass}/bin/sshpass -p${sshPassword} -- \
      ${openssh}/bin/ssh  -np 2022 ${sshOpts} \
      ${sshUser}@localhost \
      "${cmd}"
  '';
  scp = src: target: ''
    echo "Copy ${src} to ${target}"
    ${sshpass}/bin/sshpass -p${sshPassword} -- \
      ${openssh}/bin/scp -P 2022 ${sshOpts} \
      "${src}" "${sshUser}@localhost:${target}"
  '';
  condaEnv = "artiq-env";
  condaDependencies = [
    "python >=3.5.3,<3.6"
    "llvmlite-artiq 0.23.0.dev py35_5"
    "binutils-or1k-linux >=2.27"
    "pythonparser >=1.1"
    "openocd 0.10.0 6"
    "scipy"
    "numpy"
    "prettytable"
    "asyncserial"
    "h5py 2.8"
    "python-dateutil"
    "pyqt >=5.5"
    "quamash"
    "pyqtgraph 0.10.0"
    "pygit2"
    "aiohttp >=3"
    "levenshtein"
  ];
  condaPkgSpecs =
    builtins.concatStringsSep " "
    (map (s: "\"${s}\"") condaDependencies);
in
stdenv.mkDerivation {
  name = "windows-installer";
  src = windowsIso;
  setSourceRoot = "sourceRoot=`pwd`";
  unpackCmd = ''
    ln -s $curSrc windows.iso
  '';
  buildInputs = [ qemu openssh sshpass ];
  dontBuild = true;
  installPhase = ''
    mkdir -p $out/bin $out/data
    ln -s $(readlink windows.iso) $out/data/windows.iso
    cat > $out/bin/networked-installer.sh << EOF
    #!/usr/bin/env bash
    set -e -m

    TMPDIR=\$(mktemp -d)

    if [ ! -f c.img ] ; then 
      ${qemu}/bin/qemu-img create -f qcow2 c.img ${diskImageSize}
      ${runQemu [
        "-boot" "order=d"
        "-drive" "file=c.img,index=0,media=disk,cache=unsafe"
        "-drive" "file=$out/data/windows.iso,index=1,media=cdrom,cache=unsafe"
      ]} &
      echo "Please perform a Windows installation."
    else
      echo "Please finalize your Windows installation (or delete c.img and restart)"
      ${runQemu [
        "-boot" "order=c"
        "-drive" "file=c.img,index=0,media=disk"
      ]} &
    fi
    echo "Add user account with expected password [user/user]."
    echo "Enable the OpenSSH server:"
    echo "- \"Add or remove programs\""
    echo "- \"Manage optional features\""
    echo "- \"Add a feature\""
    echo "- \"OpenSSH Server\""
    echo "- \"Install\""
    echo "- Open \"Services\""
    echo "- Double-click the \"OpenSSH SSH Server\" service"
    echo "- Set \"Startup type\" to \"Automatic\""
    echo "- \"Start\""
    echo "- \"Ok\""
    echo "Then press ENTER here to proceed with automatic installation"

    read
    ${ssh "ver"}

    ${scp miniconda "Miniconda.exe"}
    ${ssh "start /wait \"\" Miniconda.exe /S /D=%cd%\\miniconda"}
    ${ssh "del Miniconda.exe"}

    ${ssh "miniconda\\Scripts\\conda config --add channels conda-forge"}
    ${ssh "miniconda\\Scripts\\conda config --add channels m-labs"}
    ${ssh "miniconda\\Scripts\\conda update -y conda"}
    ${ssh "miniconda\\Scripts\\conda update -y --all"}
    ${ssh "miniconda\\Scripts\\conda create -y -n ${condaEnv}"}
    ${ssh "miniconda\\Scripts\\conda install -y -n ${condaEnv} ${condaPkgSpecs}"}
    ${ssh "shutdown /p /f"}

    echo "Waiting for qemu exit"
    wait

    rm -rf \$TMPDIR
    EOF
    chmod a+x $out/bin/networked-installer.sh
  '';
}
