{ pkgs ? import <nixpkgs> {},
  diskImage ? "/opt/windows/c.img",
  qemuMem ? "2G",
  testTimeout ? 180,
  artiqPkg ? import ../conda-artiq.nix { inherit pkgs; },
  testCommand ? "python -m unittest discover -v artiq.test",
}:

with pkgs;

let
  escape = builtins.replaceStrings [ "\\" ] [ "\\\\" ];
  qemu = import ./qemu.nix {
    inherit pkgs qemuMem;
    diskImage = "c.img";
  };
  # Double-escape because we produce a script from a shell heredoc
  ssh = cmd: qemu.ssh (escape cmd);
  scp = qemu.scp;
  condaEnv = "artiq";
in

stdenv.mkDerivation {
  name = "windows-test-runner";
  src = ./.;

  buildInputs = qemu.inputs;
  dontBuild = true;
  installPhase = ''
    mkdir -p $out/bin
    cat > $out/bin/run.sh << EOF
    # +1 day from last modification of the disk image
    CLOCK=$(date -Is -d @$(expr $(stat -c %Y ${diskImage}) + 86400))
    ${qemu.runQemu true [
      "-boot" "order=c"
      "-snapshot"
      "-drive" "file=${diskImage},index=0,media=disk,cache=unsafe"
      "-rtc" "base=$CLOCK"
      "-display" "none"
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

    ${ssh "anaconda\\scripts\\activate ${condaEnv} && ${testCommand}"}

    # Abort timeouted shutdown
    ${ssh "shutdown -a"}
    # Power off immediately
    ${ssh "shutdown -p -f"}
    EOF
    chmod a+x $out/bin/run.sh
  '';
}
