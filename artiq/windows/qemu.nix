{ pkgs,
  diskImage,
  qemuMem,
  sshUser ? "user",
  sshPassword ? "user",
}:

with pkgs;

let
  qemu = qemu_kvm;
  qemu-img = "${qemu}/bin/qemu-img";
  runQemu = isolateNetwork: extraArgs:
    let
      restrict =
        if isolateNetwork
        then "on"
        else "off";
      args = [
        "-enable-kvm"
        "-m" qemuMem
        "-bios" "${OVMF.fd}/FV/OVMF.fd"
        "-netdev" "user,id=n1,restrict=${restrict},hostfwd=tcp::2022-:22"
        "-device" "e1000,netdev=n1"
      ];
      argStr = builtins.concatStringsSep " " (args ++ extraArgs);
    in "qemu-system-x86_64 ${argStr}";

  sshOpts = "-o StrictHostKeyChecking=accept-new -o UserKnownHostsFile=/tmp/known_hosts";
  ssh = cmd: ''
    echo ssh windows '${cmd}'
    ${sshpass}/bin/sshpass -p${sshPassword} -- \
      ${openssh}/bin/ssh  -np 2022 ${sshOpts} \
      ${sshUser}@localhost \
      '${cmd}'
  '';
  scp = src: target: ''
    echo "Copy ${src} to ${target}"
    ${sshpass}/bin/sshpass -p${sshPassword} -- \
      ${openssh}/bin/scp -P 2022 ${sshOpts} \
      "${src}" "${sshUser}@localhost:${target}"
  '';
  
in
{
  inherit qemu-img runQemu ssh scp;
  inputs = [ qemu openssh sshpass ];
}
