{ pkgs ? import <nixpkgs> {},
  diskImage ? "/opt/windows/c.img",
  qemuMem ? "2G",
  testTimeout ? 120,
  artiqPkg ? import ../conda-artiq.nix { inherit pkgs; },
}:

with pkgs;

let
  qemu = import ./qemu.nix {
    inherit pkgs qemuMem;
    diskImage = "c.img";
  };
  ssh = qemu.ssh;
  scp = qemu.scp;
  condaEnv = "artiq-env";
in
  stdenv.mkDerivation {
    name = "windows-test-conda-artiq";
    src = ./.;
    dontBuild = true;
    installPhase = ''
      mkdir $out
    '';
    doCheck = true;
    checkInputs = qemu.inputs;
    checkPhase = ''
      # +1 day from last modification of the disk image
      CLOCK=$(date -Is -d @$(expr $(stat -c %Y ${diskImage}) + 86400))
      ${qemu.runQemu [
        "-boot" "order=c"
        "-snapshot"
        "-drive" "file=${diskImage},index=0,media=disk,cache=unsafe"
        "-rtc" "base=$CLOCK"
      ]} &

      echo "Wait for Windows to boot"
      sleep 10
      ${ssh "ver"}
      for pkg in ${artiqPkg}/noarch/artiq*.tar.bz2 ; do
        ${scp "\$pkg" "artiq.tar.bz2"}
        ${ssh "miniconda\\scripts\\activate ${condaEnv} && conda install artiq.tar.bz2"}
      done

      # Allow tests to run for 2 minutes
      ${ssh "shutdown -s -t ${toString testTimeout}"}

      ${ssh "miniconda\\scripts\\activate ${condaEnv} && python -m unittest discover -v artiq.test"}

      # Abort timeouted shutdown
      ${ssh "shutdown -a"}
      # Power off immediately
      ${ssh "shutdown -p -f"}
    '';
  }
