{ pkgs
, sipycoPkg
, artiqPkg
, diskImage ? (import ./build.nix { inherit pkgs; })
, qemuMem ? "2G"
, testTimeout ? 600
, testCommand ? "python -m unittest discover -v sipyco.test && python -m unittest discover -v artiq.test"
,
}:

with pkgs;

let
  escape = builtins.replaceStrings [ "\\" ] [ "\\\\" ];
  qemu = import ./qemu.nix {
    inherit pkgs qemuMem;
  };
  # Double-escape because we produce a script from a shell heredoc
  ssh = cmd: qemu.ssh (escape cmd);
  sshUnquoted = qemu.sshWithQuotes "\"";
  scp = qemu.scp;
  condaEnv = "artiq-env";
  tcpPorts = [ 1380 1381 1382 1383 ];
  forwardedPorts =
    map (
      port: {
        listenAddr = "192.168.1.50";
        targetAddr = "192.168.1.50";
        inherit port;
      }
    ) tcpPorts;
in

stdenv.mkDerivation {
  name = "windows-test-runner";

  # Dummy sources
  src = pkgs.runCommandNoCC "dummy" {} "touch $out";
  dontUnpack = true;

  propagatedBuildInputs = qemu.inputs;
  dontBuild = true;
  installPhase = ''
    mkdir -p $out/bin
    cat > $out/bin/run.sh << EOF
    #!/usr/bin/env bash
    set -e -m

    cp ${diskImage} c.img

    ${qemu.runQemu true forwardedPorts [
    "-boot"
    "order=c"
    "-snapshot"
    "-drive"
    "file=c.img,index=0,media=disk,cache=unsafe"
    "-display"
    "none"
  ]} &

    echo "Wait for Windows to boot"
    sleep 30
    ${ssh "ver"}
    i=0
    for pkg in ${sipycoPkg}/noarch/sipyco*.tar.bz2 ${artiqPkg}/noarch/artiq*.tar.bz2 ; do
      ${scp "\\$pkg" "to_install\\$i.tar.bz2"}
      ${sshUnquoted "anaconda\\scripts\\activate ${condaEnv} && conda install to_install\\$i.tar.bz2"}
      ((i=i+1))
    done

    # Schedule a timed shutdown against hanging test runs
    ${ssh "shutdown -s -t ${toString testTimeout}"}

    FAIL=n
    ( ${ssh "anaconda\\scripts\\activate ${condaEnv} && ${testCommand}"} ) || FAIL=y

    # Abort timeouted shutdown
    ${ssh "shutdown -a"}
    # Power off immediately
    ${ssh "shutdown -p -f"}
    wait

    if [ "\$FAIL" = "y" ]; then
      exit 1
    else
      exit 0
    fi
    EOF
    chmod a+x $out/bin/run.sh
  '';
}
