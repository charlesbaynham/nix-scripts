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
  sshOpts = "-o StrictHostKeyChecking=accept-new -o UserKnownHostsFile=$TMPDIR/known_hosts";
  ssh = cmd: ''
    echo "ssh windows \"${cmd}\""
    sshpass -p${sshPassword} -- \
      ssh  -np 2022 ${sshOpts} \
      ${sshUser}@localhost \
      "${cmd}"
  '';
  scp = src: target: ''
    echo "Copy ${src} to ${target}"
    sshpass -p${sshPassword} -- \
      scp -P 2022 ${sshOpts} \
      "${src}" "${sshUser}@localhost:${target}"
  '';
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

    TMPDIR=$(mktemp)

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
    ${ssh "miniconda\\Scripts\\conda update -y python"}
    ${ssh "miniconda\\Scripts\\conda install -y numpy h5py"}
    ${ssh "miniconda\\Scripts\\conda install -y -c m-labs pythonparser"}
    ${ssh "shutdown /p /f"}

    echo "Waiting for qemu exit"
    wait

    rm -rf $TMPDIR
    EOF
    chmod a+x $out/bin/networked-installer.sh
  '';
}
