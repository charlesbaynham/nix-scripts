{ pkgs ? import <nixpkgs> {},
  diskImage ? "/opt/windows/c.img",
  qemuMem ? "2G",
  testTimeout ? 120,
  artiqPkg ? import ../conda-artiq.nix { inherit pkgs; },
}:

with pkgs;

let
  artiqSrc = <artiqSrc>;
  artiqVersion =
    pkgs.runCommand "artiq-version" {
      buildInputs = [ pkgs.nix pkgs.git ];
    } ''
      REV=`git --git-dir ${artiqSrc}/.git rev-parse HEAD`
      echo \"5e.`cut -c1-8 <<< $REV`\" > $out
    '';

  generateTestOkHash =
    pkgs.runCommand "generate-test-ok-hash" {
      buildInputs = [ pkgs.nix ];
    } ''
      TMPDIR=`mktemp -d`
      cp ${artiqVersion} $TMPDIR/passed
      HASH=`nix-hash --type sha256 --base32 $TMPDIR`
      echo \"$HASH\" > $out
    '';

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

    outputHashAlgo = "sha256";
    outputHashMode = "recursive";
    outputHash = import generateTestOkHash;
    __hydraRetry = false;

    phases = [ "buildPhase" ];
    buildInputs = qemu.inputs;
    buildPhase = ''
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
        ${ssh "anaconda\\scripts\\activate ${condaEnv} && conda install artiq.tar.bz2"}
      done

      # Allow tests to run for 2 minutes
      ${ssh "shutdown -s -t ${toString testTimeout}"}

      ${ssh "anaconda\\scripts\\activate ${condaEnv} && python -m unittest discover -v artiq.test"}

      # Abort timeouted shutdown
      ${ssh "shutdown -a"}
      # Power off immediately
      ${ssh "shutdown -p -f"}

      mkdir $out
      cp ${artiqVersion} $out/passed
    '';
  }
