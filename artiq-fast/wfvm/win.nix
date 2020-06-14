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

  # Pass empty config file to prevent ssh from failing to create ~/.ssh
  sshOpts = "-F /dev/null -o StrictHostKeyChecking=accept-new -o UserKnownHostsFile=\$TMP/known_hosts -o ConnectTimeout=1";
  win-exec = pkgs.writeShellScriptBin "win-exec" ''
    ${pkgs.sshpass}/bin/sshpass -p${users.artiq.password} -- \
      ${pkgs.openssh}/bin/ssh  -np 2022 ${sshOpts} \
      artiq@localhost \
      $1
  '';
  win-put = pkgs.writeShellScriptBin "win-put" ''
    echo scp windows $1 -\> $2
    ${pkgs.sshpass}/bin/sshpass -p${users.artiq.password} -- \
      ${pkgs.openssh}/bin/scp -P 2022 ${sshOpts} \
      $1 artiq@localhost:$2
  '';

  finalImage = builtins.foldl' (acc: v: pkgs.runCommandNoCC "${v.name}.img" {
    buildInputs = [
      win-exec
      win-put
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

    set -m
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

      output=$(win-exec 'echo|set /p="Ran command"' || echo "")
      if test "$output" = "Ran command"; then
        break
      fi

      echo "Retrying in 1 second, timing out in $timeout seconds"

      ((timeout=$timeout-1))

      sleep 1
    done

    echo "Executing user script..."
    ${script}
    echo "Done"

    # Allow install to "settle"
    sleep 20

    echo "Shutting down..."
    win-exec 'shutdown /s'
    echo "Waiting for VM to terminate..."
    fg
    echo "Done"

    mv c.img $out
  '')) baseImage installCommands;

in

# impureMode is meant for debugging the base image, not the full incremental build process
if !(impureMode) then finalImage else assert installCommands == []; installScript
