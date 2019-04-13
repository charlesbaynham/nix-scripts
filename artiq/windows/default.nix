{ pkgs ? import <nixpkgs> {},
  diskImage ? "/opt/windows/c.img",
  qemuMem ? "2G",
  testTimeout ? 120,
  artiqPkg ? import ../conda-artiq.nix { inherit pkgs; },
}:

with pkgs;

let
  qemu = qemu_kvm;
  runQemu = extraArgs:
    let
      args = [
        "-enable-kvm"
        "-m" qemuMem
        "-display" "none"
        "-bios" "${OVMF.fd}/FV/OVMF.fd"
        "-netdev" "user,id=n1,restrict=on,hostfwd=tcp::2022-:22" "-device" "e1000,netdev=n1"
      ];
      argStr = builtins.concatStringsSep " " (args ++ extraArgs);
    in "qemu-system-x86_64 ${argStr}";
  sshUser = "user";
  sshPassword = "user";
  sshOpts = "-o StrictHostKeyChecking=accept-new -o UserKnownHostsFile=$TMPDIR/known_hosts";
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
in
  stdenv.mkDerivation {
    name = "windows-test-conda-artiq";
    src = ./.;
    dontBuild = true;
    installPhase = ''
      mkdir $out
    '';
    doCheck = true;
    checkInputs = [ qemu sshpass openssh ];
    checkPhase = ''
      # +1 day from last modification of the disk image
      CLOCK=$(date -Is -d @$(expr $(stat -c %Y ${diskImage}) + 86400))
      ${runQemu [
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
