{ pkgs, baseRtc ? "2020-04-20T14:21:42", cores ? "4", qemuMem ? "4G" }:

rec {
  # qemu_test is a smaller closure only building for a single system arch
  qemu = pkgs.qemu_test;

  mkQemuFlags = extraFlags: [
    "-enable-kvm"
    "-cpu host"
    "-smp ${cores}"
    "-m ${qemuMem}"
    "-bios ${pkgs.OVMF.fd}/FV/OVMF.fd"
    "-vga virtio"
    "-rtc base=${baseRtc}"
    "-device piix3-usb-uhci"
    "-device e1000,netdev=n1"
  ] ++ extraFlags;

  # Pass empty config file to prevent ssh from failing to create ~/.ssh
  sshOpts = "-F /dev/null -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ConnectTimeout=1";
  win-exec = pkgs.writeShellScriptBin "win-exec" ''
    ${pkgs.sshpass}/bin/sshpass -p1234 -- \
      ${pkgs.openssh}/bin/ssh -np 2022 ${sshOpts} \
      wfvm@localhost \
      $1
  '';
  win-wait = pkgs.writeShellScriptBin "win-wait" ''
    # If the machine is not up within 10 minutes it's likely never coming up
    timeout=600

    # Wait for VM to be accessible
    sleep 20
    echo "Waiting for SSH..."
    while true; do
      if test "$timeout" -eq 0; then
        echo "SSH connection timed out"
        exit 1
      fi

      output=$(${win-exec}/bin/win-exec 'echo|set /p="Ran command"' || echo "")
      if test "$output" = "Ran command"; then
        break
      fi

      echo "Retrying in 1 second, timing out in $timeout seconds"

      ((timeout=$timeout-1))

      sleep 1
    done
    echo "SSH OK"
  '';
  win-put = pkgs.writeShellScriptBin "win-put" ''
    echo scp windows $1 -\> $2
    ${pkgs.sshpass}/bin/sshpass -p1234 -- \
      ${pkgs.openssh}/bin/scp -P 2022 ${sshOpts} \
      $1 wfvm@localhost:$2
  '';

  wfvm-run = { name, image, script, display ? false, isolateNetwork ? true, forwardedPorts ? [] }:
    let
      restrict =
        if isolateNetwork
        then "on"
        else "off";
      # use socat instead of `tcp:...` to allow multiple connections
      guestfwds =
        builtins.concatStringsSep ""
        (map ({ listenAddr, targetAddr, port }:
          ",guestfwd=tcp:${listenAddr}:${toString port}-cmd:${pkgs.socat}/bin/socat\\ -\\ tcp:${targetAddr}:${toString port}"
        ) forwardedPorts);
      qemuParams = mkQemuFlags (pkgs.lib.optional (!display) "-display none" ++ [
        "-drive"
        "file=${image},index=0,media=disk,cache=unsafe"
        "-snapshot"
        "-netdev user,id=n1,net=192.168.1.0/24,restrict=${restrict},hostfwd=tcp::2022-:22${guestfwds}"
      ]);
    in pkgs.writeShellScriptBin "wfvm-run-${name}" ''
      set -m
      qemu-system-x86_64 ${pkgs.lib.concatStringsSep " " qemuParams} &

      ${win-wait}/bin/win-wait

      ${script}

      echo "Shutting down..."
      ${win-exec}/bin/win-exec 'shutdown /s'
      echo "Waiting for VM to terminate..."
      fg
      echo "Done"
    '';
}
