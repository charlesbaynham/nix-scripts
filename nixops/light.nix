{ host }:

{ config, pkgs, ... }:
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
  documentation.enable = false;
  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    wget vim git firefox usbutils pciutils file lm_sensors acpi
    gimp imagemagick
    (python3.withPackages(ps: with ps; [ numpy scipy ]))
    psmisc
    telnet unzip zip gnupg
    sublime3 rink
    tmux screen tigervnc
    (import ./fish-nix-shell)
  ];
  programs.wireshark.enable = true;

  services.openssh.enable = true;
  services.openssh.forwardX11 = true;
  services.openssh.passwordAuthentication = false;
  hardware.u2f.enable = true;
  services.pcscd.enable = true;
  programs.ssh.extraConfig =
    ''
    PKCS11Provider "${pkgs.opensc}/lib/opensc-pkcs11.so"
    '';

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
  fonts.fonts = [ pkgs.noto-fonts pkgs.noto-fonts-cjk pkgs.noto-fonts-emoji pkgs.noto-fonts-extra ];

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.layout = "us";
  services.xserver.xkbOptions = "eurosign:e";

  # Enable touchpad support.
  services.xserver.libinput.enable = true;

  services.xserver.displayManager.lightdm.enable = true;
  services.xserver.desktopManager.xfce.enable = true;

  programs.fish.enable = true;
  programs.fish.promptInit = ''
    fish-nix-shell --info-right | source
  '';
  users.defaultUserShell = pkgs.fish;
  users.extraGroups.plugdev = { };
  users.extraUsers = (import ./common-users.nix);
  
  security.sudo.wheelNeedsPassword = false;

  nix.binaryCachePublicKeys = ["nixbld.m-labs.hk-1:5aSRVA5b320xbNvu30tqxVPXpld73bhtOeH6uAjRyHc="];
  nix.binaryCaches = ["https://nixbld.m-labs.hk" "https://cache.nixos.org"];
  nix.sandboxPaths = ["/opt"];

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "19.03"; # Did you read the comment?
}
