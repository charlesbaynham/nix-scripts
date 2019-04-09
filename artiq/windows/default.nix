{ pkgs ? import <nixpkgs> {},
  diskImage ? "/opt/windows/c.img",
  qemuMem ? "2G",
  testTimeout ? 120,
  artiq ? import ./.. { inherit pkgs; },
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
  installCondaPkg = pkg: ''
    F="$(basename ${pkg})"
    ${scp pkg "$F"}
    ${ssh "miniconda\\Scripts\\conda install $F"}
    ${ssh "del $F"}
  '';
  makeTest = name: artiqPkg:
    stdenv.mkDerivation {
      name = "windows-test-${name}";
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
        for pkg in ${artiqPkg}/noarch/*.tar.bz2 ; do
          ${installCondaPkg "$pkg"}
        done
        # Allow tests to run for 2 minutes
        ${ssh "shutdown -s -t ${toString testTimeout}"}
        ${ssh "miniconda\\scripts\\activate && miniconda\\python -m unittest discover -v artiq.test"}
        # Abort timeouted shutdown
        ${ssh "shutdown -a"}
        # Power off immediately
        ${ssh "shutdown -p -f"}
      '';
      installPhase = ''
        echo Done
      '';
    };
  condaPackageNames =
    builtins.filter (name: builtins.match "conda-.+" name != null)
    (builtins.attrNames artiq);
in
  builtins.listToAttrs
  (map (pkgName: {
    name = pkgName;
    value = makeTest pkgName artiq.${pkgName};
  }) condaPackageNames)
