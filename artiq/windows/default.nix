{ pkgs ? import <nixpkgs> {},
  diskImage ? "/opt/windows/c.img",
  qemuMem ? "2G",
  testTimeout ? 120,
  # This artiqPkg should be a current build passed by the caller
  artiqPkg ? (pkgs.fetchurl {
    url = "https://nixbld.m-labs.hk/build/2316/download/1/artiq-5e.b8e2b82a-0.tar.bz2";
    sha256 = "0gisv3a17rnwavsifpz4cfnqvlssv37pysi2qx41k67rmcpqcs98";
  }),
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
        "-netdev" "user,id=n1,hostfwd=tcp::2022-:22" "-device" "e1000,netdev=n1"
      ];
      argStr = builtins.concatStringsSep " " (args ++ extraArgs);
    in "qemu-system-x86_64 ${argStr}";
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
  installCondaPkgs = condaPkgs:
    builtins.concatStringsSep "\n" (map (pkg: ''
      F="$(basename ${pkg})"
      ${scp pkg "$F"}
      ${ssh "miniconda\\Scripts\\conda install $F"}
      ${ssh "del $F"}
    '') condaPkgs);
in
stdenv.mkDerivation {
  name = "windows-test";
  src = ./.;
  buildInputs = [ qemu sshpass openssh ];
  buildPhase = ''
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
    ${installCondaPkgs [artiqPkg]}
    # Allow tests to run for 2 minutes
    ${ssh "shutdown -s -t $ {toString testTimeout}"}
    ${ssh "miniconda\\scripts\\activate && miniconda\\python -m unittest discover -v artiq.test"}
    # Abort timeouted shutdown
    ${ssh "shutdown -a"}
    # Power off immediately
    ${ssh "shutdown -p -f"}
  '';
  installPhase = ''
    echo Done
  '';
}
