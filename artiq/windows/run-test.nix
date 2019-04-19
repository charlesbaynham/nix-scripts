{ pkgs ? import <nixpkgs> {},
  diskImage ? "/opt/windows/c.img",
  qemuMem ? "2G",
  testTimeout ? 600,
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
  condaEnv = "artiq-env";
  tcpPorts = [ 1380 1381 1382 1383 ];
  forwardedPorts =
    map (port: {
      listenAddr = "192.168.1.50";
      targetAddr = "192.168.1.50";
      inherit port;
    }) tcpPorts;
in

stdenv.mkDerivation {
  name = "windows-test-runner";
  src = ./.;

  propagatedBuildInputs = qemu.inputs;
  dontBuild = true;
  installPhase = ''
    mkdir -p $out/bin
    cat > $out/bin/run.sh << EOF
    set -e -m

    # +1 day from last modification of the disk image
    CLOCK=$(date -Is -d @$(expr $(stat -c %Y ${diskImage}) + 86400))
    ${qemu.runQemu true forwardedPorts [
      "-boot" "order=c"
      "-snapshot"
      "-drive" "file=${diskImage},index=0,media=disk,cache=unsafe"
      "-rtc" "base=\\$CLOCK"
      "-display" "none"
    ]} &

    echo "Wait for Windows to boot"
    sleep 10
    export HOME=`mktemp -d`
    ${ssh "ver"}
    for pkg in ${artiqPkg}/noarch/artiq*.tar.bz2 ; do
      ${scp "\\$pkg" "artiq.tar.bz2"}
      ${ssh "anaconda\\scripts\\activate ${condaEnv} && conda install artiq.tar.bz2"}
    done

    # Allow tests to run for 2 minutes
    ${ssh "shutdown -s -t ${toString testTimeout}"}

    ${ssh "anaconda\\scripts\\activate ${condaEnv} && ${testCommand}"}

    # Abort timeouted shutdown
    ${ssh "shutdown -a"}
    # Power off immediately
    ${ssh "shutdown -p -f"}
    wait

    EOF
    chmod a+x $out/bin/run.sh
  '';
}