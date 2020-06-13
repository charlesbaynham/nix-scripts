{ pkgs ? import <nixpkgs> {}
, lib ? pkgs.lib
, diskImageSize ? "22G"
, qemuMem ? "4G"
, windowsImage ? null
, autoUnattendParams ? {}
, packages ? []
, impureMode ? false
, baseRtc ? "2020-04-20T14:21:42"
, installCommands ? []
, users ? {}
, ...
}@attrs:

let
  # qemu_test is a smaller closure only building for a single system arch
  qemu = pkgs.qemu_test;
  libguestfs = pkgs.libguestfs-with-appliance;

  # p7zip on >20.03 has known vulns but we have no better option
  p7zip = pkgs.p7zip.overrideAttrs(old: {
    meta = old.meta // {
      knownVulnerabilities = [];
    };
  });

  runQemuCommand = name: command: (
    pkgs.runCommandNoCC name { buildInputs = [ p7zip qemu libguestfs ]; }
      (
        ''
          if ! test -f; then
            echo "KVM not available, bailing out" >> /dev/stderr
            exit 1
          fi
        '' + command
      )
  );

  windowsIso = if windowsImage != null then windowsImage else pkgs.fetchurl {
    url = "https://software-download.microsoft.com/download/sg/17763.107.101029-1455.rs5_release_svc_refresh_CLIENT_LTSC_EVAL_x64FRE_en-us.iso";
    sha256 = "668fe1af70c2f7416328aee3a0bb066b12dc6bbd2576f40f812b95741e18bc3a";
  };

  openSshServerPackage = ./openssh/server-package.cab;

  autounattend = import ./autounattend.nix (
    attrs // {
      inherit pkgs;
    }
  );

  bundleInstaller = pkgs.callPackage ./bundle {};

  # Packages required to drive installation of other packages
  bootstrapPkgs = let
    winPkgs = import ./pkgs.nix { inherit pkgs; };

  in
    runQemuCommand "bootstrap-win-pkgs.img" ''
      mkdir pkgs
      mkdir pkgs/bootstrap
      mkdir pkgs/user
      mkdir pkgs/fod

      cp ${bundleInstaller} pkgs/"$(stripHash "${bundleInstaller}")"

      # Install optional windows features

      cp ${openSshServerPackage} pkgs/fod/OpenSSH-Server-Package~31bf3856ad364e35~amd64~~.cab

      # SSH setup script goes here because windows XML parser sucks
      cp ${autounattend.setupScript} pkgs/ssh-setup.ps1

      ${lib.concatStringsSep "\n" (builtins.map (x: ''cp ${x} pkgs/bootstrap/"$(stripHash "${x}")"'') packages)}

      virt-make-fs --partition --type=fat pkgs/ $out
    '';

  mkQemuFlags = extraFlags: [
    "-enable-kvm"
    "-cpu"
    "host"
    "-smp"
    "$NIX_BUILD_CORES"
    "-m"
    "${qemuMem}"
    "-bios"
    "${pkgs.OVMF.fd}/FV/OVMF.fd"
    "-vga"
    "virtio"
    "-device"
    "piix3-usb-uhci" # USB root hub
    # "CD" drive with windows features-on-demand
    # "-cdrom" "${fodIso}"
    # Set the base clock inside the VM
    "-rtc base=${baseRtc}"
    # Always enable SSH port forward
    # It's not really required for the initial setup but we do it here anyway
    "-netdev user,id=n1,net=192.168.1.0/24,restrict=off,hostfwd=tcp::2022-:22"
    "-device e1000,netdev=n1"
  ] ++ lib.optional (!impureMode) "-nographic" ++ extraFlags;

  installScript = pkgs.writeScript "windows-install-script" (
    let
      qemuParams = mkQemuFlags [
        # "CD" drive with bootstrap pkgs
        "-drive"
        "id=virtio-win,file=${bootstrapPkgs},if=none,format=raw,readonly=on"
        "-device"
        "usb-storage,drive=virtio-win"
        # USB boot
        "-drive"
        "id=win-install,file=usbimage.img,if=none,format=raw,readonly=on"
        "-device"
        "usb-storage,drive=win-install"
        # Output image
        "-drive"
        "file=c.img,index=0,media=disk,cache=unsafe"
      ];
    in
      ''
        #!${pkgs.runtimeShell}
        set -euxo pipefail
        export PATH=${lib.makeBinPath [ p7zip qemu libguestfs ]}:$PATH

        if test -z "''${NIX_BUILD_CORES+x}"; then
          export NIX_BUILD_CORES=$(nproc)
        fi

        # Create a bootable "USB" image
        # Booting in USB mode circumvents the "press any key to boot from cdrom" prompt
        #
        # Also embed the autounattend answer file in this image
        mkdir -p win
        mkdir -p win/nix-win
        7z x -y ${windowsIso} -owin

        cp ${autounattend.autounattendXML} win/autounattend.xml

        virt-make-fs --partition --type=fat win/ usbimage.img
        rm -rf win

        # Qemu requires files to be rw
        qemu-img create -f qcow2 c.img ${diskImageSize}
        env NIX_BUILD_CORES="''${NIX_BUILD_CORES:4}" qemu-system-x86_64 ${lib.concatStringsSep " " qemuParams}
      ''
  );

  baseImage = pkgs.runCommandNoCC "windows.img" {} ''
    ${installScript}
    mv c.img $out
  '';

  # Use Paramiko instead of OpenSSH
  #
  # OpenSSH goes out of it's way to make password logins hard
  # and Windows goes out of it's way to make key authentication hard
  # so we're in a pretty tough spot
  #
  # Luckily the usage patterns are quite simple and easy to reimplement with paramiko
  paramikoClient = pkgs.writeScriptBin "win" ''
    #!${pkgs.python3.withPackages(ps: [ ps.paramiko ])}/bin/python
    import paramiko
    import os.path
    import sys


    def w_join(*args):
        # Like os.path.join but for windows paths
        return "\\".join(args)


    if __name__ == '__main__':
        client = paramiko.SSHClient()
        client.set_missing_host_key_policy(paramiko.client.AutoAddPolicy)


        cmd = sys.argv[1]

        try:
            client.connect(hostname="127.0.0.1", port=2022, username="artiq", password="${users.artiq.password}", timeout=1)

            if cmd == "put":
                sftp = client.open_sftp()
                src = sys.argv[2]
                dst = sys.argv[3]
                sftp.put(src, w_join(dst, os.path.basename(src)))

            elif cmd == "exec":
                _, stdout, stderr = client.exec_command(sys.argv[2])

                sys.stdout.write(stdout.read().strip().decode())
                sys.stdout.flush()

                sys.stderr.write(stderr.read().strip().decode())
                sys.stderr.flush()

            else:
                raise ValueError(f"Unhandled command: {cmd}")
        except (EOFError, paramiko.ssh_exception.SSHException):
            exit(1)
  '';

  finalImage = builtins.foldl' (acc: v: pkgs.runCommandNoCC "${v.name}.img" {
    buildInputs = [
      paramikoClient
      qemu
    ] ++ (v.buildInputs or []);
  } (let
    script = pkgs.writeScript "${v.name}-script" v.script;
    qemuParams = mkQemuFlags [
      # Output image
      "-drive"
      "file=c.img,index=0,media=disk,cache=unsafe"
    ];

  in ''
    export HOME=$(mktemp -d)

    # Create an image referencing the previous image in the chain
    qemu-img create -f qcow2 -b ${acc} c.img

    qemu-system-x86_64 ${lib.concatStringsSep " " qemuParams} &

    # If the machine is not up within 10 minutes it's likely never coming up
    timeout=600

    # Wait for VM to be accessible
    sleep 20
    echo "Waiting for SSH"
    while true; do
      if test "$timeout" -eq 0; then
        echo "SSH connection timed out"
        exit 1
      fi

      output=$(win exec 'echo Ran command' || echo "")
      if test "$output" = "Ran command"; then
        break
      fi

      echo "Retrying in 1 second, timing out in $timeout seconds"

      ((timeout=$timeout-1))

      sleep 1
    done

    echo "Executing user script to build layer"

    ${script}

    # Allow install to "settle"
    sleep 20

    win exec 'shutdown /s'

    mv c.img $out
  '')) baseImage installCommands;

in

# impureMode is meant for debugging the base image, not the full incremental build process
if !(impureMode) then finalImage else assert installCommands == []; installScript
