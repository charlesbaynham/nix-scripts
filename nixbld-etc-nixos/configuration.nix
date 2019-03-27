# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixbld"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Select internationalisation properties.
  i18n = {
    consoleFont = "Lat2-Terminus16";
    consoleKeyMap = "de";
    defaultLocale = "en_US.UTF-8";
  };

  # Set your time zone.
  time.timeZone = "Asia/Hong_Kong";

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    wget vim git file lm_sensors acpi pciutils psmisc xc3sprog telnet whois zip unzip yosys symbiyosys yices z3 boolector cvc4
    irssi tmux adoptopenjdk-openj9-bin-11 tightvnc icewm xterm xorg.xsetroot usbutils virtmanager imagemagick
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = { enable = true; enableSSHSupport = true; };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 631 5901 80 443 ];
  networking.firewall.allowedUDPPorts = [ 631 ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Enable CUPS to print documents.
  services.avahi.enable = true;
  services.avahi.publish.enable = true;
  services.avahi.publish.userServices = true;
  services.printing.enable = true;
  services.printing.drivers = [ pkgs.hplipWithPlugin ];
  services.printing.browsing = true;
  services.printing.listenAddresses = [ "*:631" ];
  services.printing.defaultShared = true;
  hardware.sane.enable = true;
  hardware.sane.extraBackends = [ pkgs.hplipWithPlugin ];

  users.extraGroups.plugdev = { };
  users.extraUsers.sb = {
    isNormalUser = true;
    extraGroups = ["networkmanager" "wheel" "plugdev" "dialout" "lp" "scanner"];
    uid = 1000;
  };
  security.sudo.wheelNeedsPassword = false;
  services.udev.packages = [ pkgs.openocd ];
  services.udev.extraRules = ''
ACTION=="add", SUBSYSTEM=="tty", \
  ENV{ID_SERIAL}=="FTDI_Quad_RS232-HS", \
  ENV{ID_PATH}=="pci-0000:00:14.0-usb-0:5:1.1", \
  SYMLINK+="ttyUSB_sayma-1_0"
ACTION=="add", SUBSYSTEM=="tty", \
  ENV{ID_SERIAL}=="FTDI_Quad_RS232-HS", \
  ENV{ID_PATH}=="pci-0000:00:14.0-usb-0:5:1.2", \
  SYMLINK+="ttyUSB_sayma-1_1"

ACTION=="add", SUBSYSTEM=="tty", \
  ENV{ID_SERIAL}=="FTDI_Quad_RS232-HS", \
  ENV{ID_PATH}=="pci-0000:00:14.0-usb-0:1:1.2", \
  SYMLINK+="ttyUSB_kasli-n1"

  '';

  nixpkgs.config.allowUnfree = true;

  services.hydra = {
    enable = true;
    package = pkgs.callPackage ./hydra.nix {};
    useSubstitutes = true;
    hydraURL = "https://nixbld.m-labs.hk";
    notificationSender = "hydra@m-labs.hk";
    minimumDiskFree = 10;  # in GB
    minimumDiskFreeEvaluator = 1;
    buildMachinesFiles = [];
    extraConfig =
      ''
      binary_cache_secret_key_file = /etc/nixos/secret/nixbld.m-labs.hk-1
      max_output_size = 5500000000
      '';
  };

  nix.extraOptions = ''
    secret-key-files = /etc/nixos/secret/nixbld.m-labs.hk-1
  '';
  nix.sandboxPaths = ["/opt"];
  nix.maxJobs = 4;

  virtualisation.libvirtd.enable = true;

  services.gitlab = {
    enable = true;
    host = "gitlab.m-labs.hk";
    port = 443;
    https = true;
    databasePassword = pkgs.lib.fileContents /etc/nixos/secret/gitlab-db-password;
    secrets = import /etc/nixos/secret/gitlab.nix;
    initialRootPassword = pkgs.lib.fileContents /etc/nixos/secret/gitlab-default-root;
  };

  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    virtualHosts = {
      "buildbot.m-labs.hk" = {
        addSSL = true;
        enableACME = true;
        locations."/".proxyPass = "http://192.168.1.100";
      };
      "lab.m-labs.hk" = {
        addSSL = true;
        enableACME = true;
        locations."/".proxyPass = "http://192.168.1.100";
      };
      "nixbld.m-labs.hk" = {
        forceSSL = true;
        enableACME = true;
        locations."/".proxyPass = "http://127.0.0.1:3000";
      };
      "gitlab.m-labs.hk" = {
        forceSSL = true;
        enableACME = true;
        locations."/".proxyPass = "http://unix:/run/gitlab/gitlab-workhorse.socket";
      };
    };
  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "18.09"; # Did you read the comment?
}
