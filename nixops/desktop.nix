{ host }:

{ config, pkgs, ... }:
let
  m-labs = import (fetchTarball https://nixbld.m-labs.hk/channel/custom/artiq/full/artiq-full/nixexprs.tar.xz) { inherit pkgs; };
  pkgs-unstable = import (fetchTarball https://nixos.org/channels/nixos-unstable/nixexprs.tar.xz) {};
in
{
  deployment.targetHost = host;

  imports =
    [
      (./. + "/${host}-hardware-configuration.nix")
    ];

  networking.hostName = host;

  time.timeZone = "Asia/Hong_Kong";

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    wget vim git firefox thunderbird hexchat usbutils pciutils file lm_sensors audacious acpi
    gimp imagemagick
    (python3.withPackages(ps: with ps; [ numpy scipy matplotlib qtconsole regex ]))
    mosh psmisc libreoffice-fresh
    gtkwave telnet unzip zip gnupg
    gnome3.gnome-tweaks
    jq sublime3 rink qemu_kvm
    tmux xc3sprog m-labs.openocd screen gdb minicom picocom tigervnc
    emacs bat ripgrep
    pkgs-unstable.rust-analyzer
    (pkgs-unstable.vscode-with-extensions.override {
      vscodeExtensions = [
        pkgs-unstable.vscode-extensions.matklad.rust-analyzer
      ];
    })
    (import ./fish-nix-shell)
  ];
  programs.wireshark.enable = true;

  services.openssh.enable = true;
  services.openssh.forwardX11 = true;
  services.openssh.passwordAuthentication = false;

  # Enable CUPS to print documents.
  services.printing = {
    enable = true;
    extraConf =
      ''
      Browsing Off
      BrowseLocalProtocols none
      '';
    browsedConf =
      ''
      BrowseRemoteProtocols none
      BrowseProtocols none
      '';
  };
  services.avahi = {
    enable = true;
    nssmdns = true;
  };

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio = {
    enable = true;
    extraModules = [ pkgs.pulseaudio-modules-bt ];
    package = pkgs.pulseaudioFull;
  };

  i18n.inputMethod = {
    enabled = "fcitx";
    fcitx.engines = with pkgs.fcitx-engines; [ table-extra m17n ];
  };
  fonts.fonts = [ pkgs.noto-fonts pkgs.noto-fonts-cjk pkgs.noto-fonts-emoji pkgs.noto-fonts-extra pkgs.emacs-all-the-icons-fonts ];

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.layout = "us";
  services.xserver.xkbOptions = "eurosign:e";

  # Enable touchpad support.
  services.xserver.libinput.enable = true;

  services.xserver.displayManager.gdm.enable = true;
  services.xserver.displayManager.gdm.autoSuspend = false;
  services.xserver.desktopManager.gnome3.enable = true;

  hardware.bluetooth.enable = true;

  programs.fish.enable = true;
  programs.fish.promptInit = ''
    fish-nix-shell --info-right | source
  '';
  users.defaultUserShell = pkgs.fish;
  users.extraGroups.plugdev = { };
  users.extraUsers = (import ./common-users.nix);
  security.sudo.wheelNeedsPassword = false;
  services.udev.packages = [ m-labs.openocd ];
  services.udev.extraRules = ''
# leaf maple
SUBSYSTEM=="usb", ATTRS{idVendor}=="1eaf", ATTRS{idProduct}=="0003", MODE="0660", GROUP="plugdev"
SUBSYSTEM=="usb", ATTRS{idVendor}=="1eaf", ATTRS{idProduct}=="0004", MODE="0660", GROUP="plugdev"
# glasgow
SUBSYSTEM=="usb", ATTRS{idVendor}=="20b7", ATTRS{idProduct}=="9db1", MODE="0660", GROUP="plugdev"
# hackrf
SUBSYSTEM=="usb", ATTRS{idVendor}=="1d50", ATTRS{idProduct}=="6089", MODE="0660", GROUP="plugdev"
# bladerf
SUBSYSTEM=="usb", ATTRS{idVendor}=="2cf0", ATTRS{idProduct}=="5250", MODE="0660", GROUP="plugdev"
# personal measurement device
SUBSYSTEM=="usb", ATTRS{idVendor}=="09db", ATTRS{idProduct}=="007a", MODE="0660", GROUP="plugdev"
  '';

  nix.binaryCachePublicKeys = ["nixbld.m-labs.hk-1:5aSRVA5b320xbNvu30tqxVPXpld73bhtOeH6uAjRyHc="];
  nix.binaryCaches = ["https://nixbld.m-labs.hk" "https://cache.nixos.org"];
  nix.sandboxPaths = ["/opt"];

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "19.03"; # Did you read the comment?
}
