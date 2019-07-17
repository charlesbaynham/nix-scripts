# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  hydraWwwOutputs = "/var/www/hydra-outputs";
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./homu/nixos-module.nix
      ./backup-module.nix
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
    irssi tmux adoptopenjdk-openj9-bin-11 tigervnc xorg.xauth icewm xterm xorg.xsetroot usbutils virtmanager imagemagick jq
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = { enable = true; enableSSHSupport = true; };
  programs.wireshark.enable = true;

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.openssh.forwardX11 = true;
  programs.mosh.enable = true;

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
    extraGroups = ["wheel" "plugdev" "dialout" "lp" "scanner" "wireshark" "docker"];
  };
  users.extraUsers.rj = {
    isNormalUser = true;
    extraGroups = ["wheel" "plugdev" "dialout" "wireshark" "docker"];
  };
  users.extraUsers.astro = {
    isNormalUser = true;
    extraGroups = ["plugdev" "dialout" "wireshark"];
  };
  users.extraUsers.whitequark = {
    isNormalUser = true;
    extraGroups = ["plugdev" "dialout"];
  };
  users.extraUsers.nix = {
    isNormalUser = true;
  };
  security.sudo.wheelNeedsPassword = false;
  security.hideProcessInformation = true;
  boot.kernel.sysctl."kernel.dmesg_restrict" = true;
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

  nix.distributedBuilds = true;
  nix.buildMachines = [
    {
       hostName = "localhost";
       maxJobs = 4;
       system = "x86_64-linux";
       supportedFeatures = ["big-parallel"];
    }
    {
       hostName = "rpi-1";
       sshUser = "nix";
       sshKey = "/etc/nixos/secret/nix_id_rsa";
       maxJobs = 1;
       system = "aarch64-linux";
    }
  ];
  services.hydra = {
    enable = true;
    useSubstitutes = true;
    hydraURL = "https://nixbld.m-labs.hk";
    notificationSender = "hydra@m-labs.hk";
    minimumDiskFree = 15;  # in GB
    minimumDiskFreeEvaluator = 1;
    extraConfig =
      ''
      binary_cache_secret_key_file = /etc/nixos/secret/nixbld.m-labs.hk-1
      max_output_size = 10000000000

      <runcommand>
        job = artiq:full:artiq-manual-html
        command = ln -sf $(jq -r '.outputs[0].path' < $HYDRA_JSON) ${hydraWwwOutputs}/artiq-manual-html-beta
      </runcommand>
      <runcommand>
        job = artiq:full:artiq-manual-latexpdf
        command = ln -sf $(jq -r '.outputs[0].path' < $HYDRA_JSON) ${hydraWwwOutputs}/artiq-manual-latexpdf-beta
      </runcommand>
      <runcommand>
        job = artiq:full:conda-channel
        command = ln -sf $(jq -r '.outputs[0].path' < $HYDRA_JSON) ${hydraWwwOutputs}/conda-channel
      </runcommand>
      '';
  };
  systemd.services.hydra-www-outputs-init = {
    description = "Set up a hydra-owned directory for build outputs";
    wantedBy = [ "multi-user.target" ];
    requiredBy = [ "hydra-queue-runner.service" ];
    before = [ "hydra-queue-runner.service" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = [ "${pkgs.coreutils}/bin/mkdir -p ${hydraWwwOutputs}" "${pkgs.coreutils}/bin/chown hydra-queue-runner:hydra ${hydraWwwOutputs}" ];
    };
  };


  nix.extraOptions = ''
    secret-key-files = /etc/nixos/secret/nixbld.m-labs.hk-1
  '';
  nix.sandboxPaths = ["/opt"];

  virtualisation.libvirtd.enable = true;
  virtualisation.docker.enable = true;

  services.munin-node.enable = true;
  services.munin-cron = {
    enable = true;
     hosts = ''
       [${config.networking.hostName}]
       address localhost
     '';
  };
  services.mlabs-backup.enable = true;

  services.gitea = {
    enable = true;
    httpPort = 3001;
    rootUrl = "https://git.m-labs.hk/";
    appName = "M-Labs Git";
    cookieSecure = true;
    disableRegistration = true;
    extraConfig =
    ''
    [attachment]
    ALLOWED_TYPES = */*
    '';
  };

  services.mattermost = {
    enable = true;
    siteUrl = "https://chat.m-labs.hk/";
    mutableConfig = true;
  };

  services.matterbridge = {
    enable = true;
    configPath = "/etc/nixos/secret/matterbridge.toml";
  };
 
  nixpkgs.config.packageOverrides = super: let self = super.pkgs; in {
    hydra = super.hydra.overrideAttrs(oa: {
      patches = oa.patches ++ [ ./hydra-conda.patch ./hydra-retry.patch ];
      hydraPath = oa.hydraPath + ":" + super.lib.makeBinPath [ super.jq ];
    });
    matterbridge = super.matterbridge.overrideAttrs(oa: {
      patches = [ ./matterbridge-disable-github.patch ];
    });
  };

  security.acme.certs = {
    "nixbld.m-labs.hk" = {
      webroot = "/var/lib/acme/acme-challenge";
      extraDomains = {
        "m-labs.hk" = null;
        "www.m-labs.hk" = null;
        "lab.m-labs.hk" = null;
        "git.m-labs.hk" = null;
        "chat.m-labs.hk" = null;
        "hooks.m-labs.hk" = null;
        "forum.m-labs.hk" = null;

        "fractalide.org" = null;
        "www.fractalide.org" = null;
        "hydra.fractalide.org" = null;
        "git.fractalide.org" = null;
        "vpn.fractalide.org" = null;
        "luceo-mainnet-rest.fractalide.org" = null;
        "luceo-mainnet-grpc.fractalide.org" = null;
        "luceo-testnet-rest.fractalide.org" = null;
        "luceo-testnet-grpc.fractalide.org" = null;
      };
    };
  };
  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    virtualHosts = {
      "m-labs.hk" = {
        addSSL = true;
        useACMEHost = "nixbld.m-labs.hk";
        root = "/var/www/m-labs.hk";
        locations."/gateware.html".extraConfig = ''
          return 301 /migen/;
        '';
        locations."/artiq/manual-beta" = {
          alias = "${hydraWwwOutputs}/artiq-manual-html-beta/share/doc/artiq-manual/html";
          extraConfig = ''
            etag off;
            if_modified_since off;
            add_header last-modified "";
          '';
        };
        locations."/artiq/manual-beta.pdf" = {
          alias = "${hydraWwwOutputs}/artiq-manual-latexpdf-beta/share/doc/artiq-manual/ARTIQ.pdf";
          extraConfig = ''
            etag off;
            if_modified_since off;
            add_header last-modified "";
          '';
        };
        locations."/artiq/conda" = {
          alias = "${hydraWwwOutputs}/conda-channel";
          extraConfig = ''
            etag off;
            if_modified_since off;
            add_header last-modified "";
            autoindex on;
          '';
        };
      };
      "www.m-labs.hk" = {
        addSSL = true;
        useACMEHost = "nixbld.m-labs.hk";
        root = "/var/www/m-labs.hk";
        locations."/gateware.html".extraConfig = ''
          return 301 /migen/;
        '';
      };
      "lab.m-labs.hk" = {
        addSSL = true;
        useACMEHost = "nixbld.m-labs.hk";
        locations."/munin".alias = "/var/www/munin";
        locations."/munin".extraConfig = ''
          auth_basic "Munin";
          auth_basic_user_file /etc/nixos/secret/muninpasswd;
        '';
        locations."/homu/".proxyPass = "http://127.0.0.1:54856/";
      };
      "nixbld.m-labs.hk" = {
        forceSSL = true;
        useACMEHost = "nixbld.m-labs.hk";
        locations."/".proxyPass = "http://127.0.0.1:3000";
      };
      "git.m-labs.hk" = {
        forceSSL = true;
        useACMEHost = "nixbld.m-labs.hk";
        locations."/".proxyPass = "http://127.0.0.1:3001";
      };
      "chat.m-labs.hk" = {
        forceSSL = true;
        useACMEHost = "nixbld.m-labs.hk";
        locations."/".proxyPass = "http://127.0.0.1:8065";
        locations."~ /api/v[0-9]+/(users/)?websocket$".proxyPass = "http://127.0.0.1:8065";
        locations."~ /api/v[0-9]+/(users/)?websocket$".proxyWebsockets = true;
      };
      "hooks.m-labs.hk" = {
        forceSSL = true;
        useACMEHost = "nixbld.m-labs.hk";
        locations."/".extraConfig = ''
          include ${pkgs.nginx}/conf/uwsgi_params;
          uwsgi_pass unix:${config.services.uwsgi.runDir}/uwsgi.sock;
        '';
      };
      "forum.m-labs.hk" = {
        forceSSL = true;
        useACMEHost = "nixbld.m-labs.hk";
         root = "/var/www/flarum/public";
         locations."~ \.php$".extraConfig = ''
           fastcgi_pass 127.0.0.1:9000;
           fastcgi_index index.php;
         '';
         extraConfig = ''
           index index.php;
           include /var/www/flarum/.nginx.conf;
         '';
      };

      "hydra.fractalide.org" = {
        forceSSL = true;
        useACMEHost = "nixbld.m-labs.hk";
        locations."/".proxyPass = "http://192.168.1.204:3000";
      };
      "git.fractalide.org" = {
        forceSSL = true;
        useACMEHost = "nixbld.m-labs.hk";
        locations."/".proxyPass = "http://192.168.1.204:3001";
      };
      "fractalide.org" = {
        forceSSL = true;
        useACMEHost = "nixbld.m-labs.hk";
        locations."/".proxyPass = "http://192.168.1.204:3002";
      };
      "www.fractalide.org" = {
        forceSSL = true;
        useACMEHost = "nixbld.m-labs.hk";
        locations."/".proxyPass = "http://192.168.1.204:3002";
      };
      "vpn.fractalide.org" = {
        forceSSL = true;
        useACMEHost = "nixbld.m-labs.hk";
        locations."/".proxyPass = "http://192.168.1.204:3003";
      };
      "luceo-mainnet-rest.fractalide.org" = {
        forceSSL = true;
        useACMEHost = "nixbld.m-labs.hk";
        locations."/".proxyPass = "http://192.168.1.204:3004";
      };
      "luceo-mainnet-grpc.fractalide.org" = {
        forceSSL = true;
        useACMEHost = "nixbld.m-labs.hk";
        locations."/".proxyPass = "http://192.168.1.204:3005";
      };
      "luceo-testnet-rest.fractalide.org" = {
        forceSSL = true;
        useACMEHost = "nixbld.m-labs.hk";
        locations."/".proxyPass = "http://192.168.1.204:3006";
      };
      "luceo-testnet-grpc.fractalide.org" = {
        forceSSL = true;
        useACMEHost = "nixbld.m-labs.hk";
        locations."/".proxyPass = "http://192.168.1.204:3007";
      };

    };
  };
  services.uwsgi = {
    enable = true;
    plugins = [ "python3" ];
    instance = {
      type = "emperor";
      vassals = {
        mattermostgithub = import ./mattermost-github-integration/uwsgi-config.nix { inherit config pkgs; };
      };
    };
  };
  services.mysql = {
    enable = true;
    package = pkgs.mariadb;
  };
  services.phpfpm.poolConfigs.mypool = ''
    listen = 127.0.0.1:9000
    user = nobody
    pm = dynamic
    pm.max_children = 5
    pm.start_servers = 2
    pm.min_spare_servers = 1
    pm.max_spare_servers = 3
    pm.max_requests = 500
  '';

  services.homu = {
    enable = true;
    config = "/etc/nixos/secret/homu.toml";
  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "18.09"; # Did you read the comment?
}
