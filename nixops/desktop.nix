{ host }:

{ config, pkgs, ... }:
let
  m-labs = import (fetchTarball https://nixbld.m-labs.hk/channel/custom/artiq/full/artiq-full/nixexprs.tar.xz) { inherit pkgs; };
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
    wget vim git firefox thunderbird hexchat usbutils pciutils file lm_sensors cryptsetup audacious acpi
    gwenview okular gimp imagemagick
    (python3.withPackages(ps: with ps; [ numpy scipy matplotlib qtconsole regex ]))
    mosh psmisc libreoffice-fresh
    gtkwave telnet whois unzip zip gnupg
    wireshark pavucontrol
    jq ark sublime3 rink qemu_kvm konsole
    tmux xc3sprog m-labs.openocd screen gdb minicom picocom
    (import ./fish-nix-shell)
  ];
  programs.wireshark.enable = true;

  services.openssh.enable = true;
  services.openssh.forwardX11 = true;

  # Enable CUPS to print documents.
  services.printing = {
    enable = true;
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
  fonts.fonts = [ pkgs.noto-fonts pkgs.noto-fonts-cjk pkgs.noto-fonts-emoji pkgs.noto-fonts-extra ];

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.layout = "us";
  services.xserver.xkbOptions = "eurosign:e";

  # Enable touchpad support.
  services.xserver.libinput.enable = true;

  # Enable the KDE Desktop Environment.
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;

  hardware.bluetooth.enable = true;

  programs.fish.enable = true;
  programs.fish.promptInit = ''
    fish-nix-shell --info-right | source
  '';
  users.defaultUserShell = pkgs.fish;
  users.extraGroups.plugdev = { };
  users.extraUsers.sb = {
    isNormalUser = true;
    extraGroups = ["wheel" "plugdev" "dialout"];
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDZGtCJoIRtRadaSBMx+MNX53nvEGUk9q/89ZpEH/jCRS+FRnBOH73C8YGvsJaiL5xUZiLjIW7SRUr40bKgvns1FJ3PNMPqvAh6fC98h5EnWAVtzKpYVXGPVvxGOqRJwvEHr6DGMJbP1lRl78zFt3PQaeEiJ5mCxlY4KenKbkBJpUWBAUa11VrNd+o7AMfF0pbNDxZCd213brbyb8saLnEx28HwdaUn//MMWnfSPDLGlod5dy4/hzj0Yk/o+4yaeIkfk1Z0FqtZif1N+VTqD5r0dfvIi38mmVYzbImy5X/hoPtLTMRb//6KZH5POwMP3ZazIq7Bl0cmGfDEu/p6/zJd sb@sb-ThinkPad-10"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDdIXscubIsVCi9sfFdaorQ3VN1Ry3Se3NEDPUKDOxOas7MqoY+W0mvrlL8QfsCwUniIF/NUJbN8LDdleRn5nO6rQdUyVXuYjaizYMOyMunY6KgQZm24+FrNS3HoVX1nQxesLB18FPtJ7A3VwOTnfuFmY2A1TyFDlUIpnCUCJ0goIW2vW9xFGdd17MI8xshwZWa3ChObbkSqX6VN8YAPWMnIqPnbBWCnetjSSjFdtKPJzhYbr7usxKD1ksMKo5OYpZXK9kiqYQOtWTk/EL5eDIrr3+wJpoWqWX/UV29VImCWtRQE2bA5A1j3sySmixR9/OQMickWk0llgK/5Nj9Hz2v sb@nixbld"
    ];
  };
  users.extraUsers.harry = {
    isNormalUser = true;
    extraGroups = ["plugdev" "dialout" "wireshark"];
  };
  users.extraUsers.astro = {
    isNormalUser = true;
    extraGroups = ["plugdev" "dialout" "wireshark"];
    openssh.authorizedKeys.keys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGJJTSJdpDh82486uPiMhhyhnci4tScp5uUe7156MBC8 a"];
  };
  users.extraUsers.pca006132 = {
    isNormalUser = true;
    extraGroups = ["plugdev" "dialout"];
    openssh.authorizedKeys.keys = ["ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCqkGZIb57sjzcnYg6tJXrK1iPKnIP6iYkcc2h/cf4rknvOT9ZkeUra7hCTjQDCiC168Lxcdx2wQciuq2SypoUMFytQoLphGHKWpgLB6yoaQgwCUW+To55kJlbs/rOywfwaRAtiyNsCtf+1FTbl0X0mKNIibjDqVyawXaUhfDLNB0TPg1yhhHdi/fqDgq+9kI/2E++8k9TZ2SUZ6vLbERU0cRkGCrVhqR7QEV+Oqa0uFBvNzc+tp/L3BKUUOCiSThNOtUHR9mSx9/Yq31tQ/I+l+oDcJyDiQlrFvDTBRbaDiMDwTFZolsQ8pFR0aJXHOrWRP11LF/EibjqbiK6WHDG/2mTnkREgGOElbOhg4yypMg5KXPY3JhjNibXV8p4GHjRb9g59N7F0s+ez44uS85fXUVVf840+mOx7W+9hGxK5ALr1I5EjUz8q2/SsF4eYuD44xCPK5rrKP0BYjnEQcDQEe5aZ2KyX+aSBF8jeiZsXti6x3Jg7ces6zlBWOoBNOPqTug4eNtkNmmPaoAzVeiItTJZBUAehLUAzyRD+8aTyB4DWAvesHPan+uQb9HvPH0rgymSEGxTi5280VWwvEpKHTGbuB0eYNFffDYVW0Y6xx3K4mZi71r6yCRdC/tsQEyM7N/dtoknvf77+iXCpb5yVSj0j5IAIVhlyszVMiW2qmw=="];
  };
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
