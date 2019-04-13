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

  qemu = import ./qemu.nix {
    inherit pkgs qemuMem;
    diskImage = "c.img";
  };
  # Double-escape because we produce a script from a shell heredoc
  ssh = cmd: qemu.ssh (qemu.escape cmd);
  scp = qemu.scp;

  condaEnv = "artiq-env";
  condaDepSpecs =
    builtins.concatStringsSep " "
    (map (s: "\"${s}\"")
     (import ../conda-artiq-deps.nix));

  instructions =
    builtins.toFile "install.txt"
    (builtins.readFile ./install.txt);
in
stdenv.mkDerivation {
  name = "windows-installer";
  src = windowsIso;
  setSourceRoot = "sourceRoot=`pwd`";
  unpackCmd = ''
    ln -s $curSrc windows.iso
  '';
  buildInputs = qemu.inputs;
  dontBuild = true;
  installPhase = ''
    mkdir -p $out/bin $out/data
    ln -s $(readlink windows.iso) $out/data/windows.iso
    cat > $out/bin/networked-installer.sh << EOF
    #!/usr/bin/env bash
    set -e -m

    if [ ! -f c.img ] ; then 
      ${qemu.qemu-img} create -f qcow2 c.img ${diskImageSize}
      ${qemu.runQemu [
        "-boot" "order=d"
        "-drive" "file=c.img,index=0,media=disk,cache=unsafe"
        "-drive" "file=$out/data/windows.iso,index=1,media=cdrom,cache=unsafe"
      ]} &
      echo "Please perform a Windows installation."
    else
      echo "Please finalize your Windows installation (or delete c.img and restart)"
      ${qemu.runQemu [
        "-boot" "order=c"
        "-drive" "file=c.img,index=0,media=disk"
      ]} &
    fi
    cat ${instructions}

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
    ${ssh "miniconda\\Scripts\\conda install -y -n ${condaEnv} ${condaDepSpecs}"}
    ${ssh "shutdown /p /f"}

    echo "Waiting for qemu exit"
    wait
    EOF
    chmod a+x $out/bin/networked-installer.sh
  '';
}
