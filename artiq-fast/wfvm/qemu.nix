{ pkgs, qemuMem }:

with pkgs;

let
  qemu-img = "${qemu_kvm}/bin/qemu-img";
  runQemu = isolateNetwork: forwardedPorts: extraArgs:
    let
      restrict =
        if isolateNetwork
        then "on"
        else "off";
      # use socat instead of `tcp:…` to allow multiple connections
      guestfwds =
        builtins.concatStringsSep ""
          (
            map (
              { listenAddr, targetAddr, port }:
                ",guestfwd=tcp:${listenAddr}:${toString port}-cmd:${socat}/bin/socat\\ -\\ tcp:${targetAddr}:${toString port}"
            ) forwardedPorts
          );
      args = [
        "-enable-kvm"
        "-m"
        qemuMem
        "-bios"
        "${OVMF.fd}/FV/OVMF.fd"
        "-netdev"
        "user,id=n1,net=192.168.1.0/24,restrict=${restrict},hostfwd=tcp::2022-:22${guestfwds}"
        "-device"
        "e1000,netdev=n1"
      ];
      argStr = builtins.concatStringsSep " " (args ++ extraArgs);
    in
      "${qemu_kvm}/bin/qemu-system-x86_64 ${argStr}";

in
{
  inherit qemu-img runQemu;
  inputs = [ qemu_kvm ];
}
