# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  netifWan = "enp0s31f6";
  netifLan = "enp3s0";
  netifWifi = "wlp1s0";
  netifSit = "henet0";
  hydraWwwOutputs = "/var/www/hydra-outputs";
in
{
  imports =
    [
      ./hardware-configuration.nix
      ./homu/nixos-module.nix
      ./backup-module.nix
      (builtins.fetchTarball {
        url = "https://gitlab.com/simple-nixos-mailserver/nixos-mailserver/-/archive/v2.3.0/nixos-mailserver-v2.3.0.tar.gz";
        sha256 = "0lpz08qviccvpfws2nm83n7m2r8add2wvfg9bljx9yxx8107r919";
      })
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.blacklistedKernelModules = ["iwlwifi"];

  security.apparmor.enable = true;

  networking = {
    hostName = "nixbld";
    firewall = {
      allowedTCPPorts = [ 80 443 ];
      allowedUDPPorts = [ 53 67 ];
      trustedInterfaces = [ netifLan ];
    };
    interfaces."${netifLan}" = {
      ipv4.addresses = [{
        address = "192.168.1.1";
        prefixLength = 24;
      }];
      ipv6.addresses = [{
        address = "2001:470:f821:1::";
        prefixLength = 64;
      }];
    };
    interfaces."${netifWifi}" = {
      ipv4.addresses = [{
        address = "192.168.12.1";
        prefixLength = 24;
      }];
      ipv6.addresses = [{
        address = "2001:470:f821:2::";
        prefixLength = 64;
      }];
    };
    nat = {
      enable = true;
      externalInterface = netifWan;
      internalInterfaces = [ netifLan netifWifi ];
      forwardPorts = [
        { sourcePort = 2201; destination = "192.168.1.201:22"; proto = "tcp"; }
        { sourcePort = 2202; destination = "192.168.1.202:22"; proto = "tcp"; }
        { sourcePort = 2203; destination = "192.168.1.203:22"; proto = "tcp"; }
        { sourcePort = 2204; destination = "192.168.1.204:22"; proto = "tcp"; }
        { sourcePort = 2205; destination = "192.168.1.205:22"; proto = "tcp"; }
      ];
      extraCommands = ''
        iptables -w -N block-lan-from-wifi
        iptables -w -A block-lan-from-wifi -i ${netifLan} -o ${netifWifi} -j DROP
        iptables -w -A block-lan-from-wifi -i ${netifWifi} -o ${netifLan} -j DROP
        iptables -w -A FORWARD -j block-lan-from-wifi
      '';
      extraStopCommands = ''
        iptables -w -D FORWARD -j block-lan-from-wifi 2>/dev/null|| true
        iptables -w -F block-lan-from-wifi 2>/dev/null|| true
        iptables -w -X block-lan-from-wifi 2>/dev/null|| true
      '';
    };
    sits."${netifSit}" = {
      dev = netifWan;
      remote = "216.218.221.6";
      local = "42.200.147.171";
      ttl = 255;
    };
    interfaces."${netifSit}".ipv6 = {
      addresses = [{ address = "2001:470:18:629::2"; prefixLength = 64; }];
      routes = [{ address = "::"; prefixLength = 0; }];
    };
  };
  boot.kernel.sysctl."net.ipv6.conf.all.forwarding" = "1";
  boot.kernel.sysctl."net.ipv6.conf.default.forwarding" = "1";

  services.unbound = {
    enable = true;
    extraConfig =
    ''
    server:
      port: 5353
    '';
  };

  services.hostapd = {
    enable        = true;
    interface     = netifWifi;
    hwMode        = "g";
    ssid          = "M-Labs";
    wpaPassphrase = (import /etc/nixos/secret/wifi_password.nix);
    extraConfig   = ''
      ieee80211d=1
      country_code=HK
      ieee80211n=1
      wmm_enabled=1
      auth_algs=1
      wpa_key_mgmt=WPA-PSK
      rsn_pairwise=CCMP
    '';
  };
  services.dnsmasq = {
    enable = true;
    servers = ["::1#5353"];
    extraConfig = ''
      interface=${netifLan}
      interface=${netifWifi}
      bind-interfaces
      dhcp-range=interface:${netifLan},192.168.1.81,192.168.1.254,24h
      dhcp-range=interface:${netifWifi},192.168.12.10,192.168.12.254,24h
      enable-ra
      dhcp-range=interface:${netifLan},::,constructor:${netifLan},ra-names
      dhcp-range=interface:${netifWifi},::,constructor:${netifWifi},ra-only

      no-resolv

      # Static IPv4s to make Red Pitayas less annoying
      dhcp-host=rp-f05cc9,192.168.1.190
      dhcp-host=rp-f0612e,192.168.1.191
      # Static IPv4s to make port redirections work
      dhcp-host=rpi-1,192.168.1.201
      dhcp-host=rpi-2,192.168.1.202
      dhcp-host=rpi-3,192.168.1.203
      dhcp-host=rpi-4,192.168.1.204
      dhcp-host=rpi-5,192.168.1.205

      # Default IP addresses for ARTIQ boards
      address=/thermostat/192.168.1.26
      address=/kc705/192.168.1.50
      address=/zc706/192.168.1.51
      address=/zc706-2/192.168.1.52
      address=/sayma/192.168.1.60
      address=/metlino/192.168.1.65
      address=/kasli/192.168.1.70
      address=/kasli-customer/192.168.1.75
      address=/stabilizer-customer/192.168.1.76
      # uTCA MCH from NAT
      address=/tschernobyl/192.168.1.80
    '';
  };

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "de";
  };

  # Set your time zone.
  time.timeZone = "Asia/Hong_Kong";

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    wget vim git file lm_sensors acpi pciutils psmisc telnet nixops
    irssi tmux usbutils imagemagick jq zip unzip
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = { enable = true; enableSSHSupport = true; };

  # List services that you want to enable:

  services.apcupsd.enable = true;
  services.apcupsd.configText = ''
    UPSTYPE usb
    NISIP 127.0.0.1
    BATTERYLEVEL 10
    MINUTES 5
  '';

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.openssh.forwardX11 = true;
  services.openssh.passwordAuthentication = false;
  programs.mosh.enable = true;

  programs.fish.enable = true;

  # Enable CUPS to print documents.
  services.avahi.enable = true;
  services.avahi.interfaces = [ netifLan ];
  services.avahi.publish.enable = true;
  services.avahi.publish.userServices = true;
  nixpkgs.config.allowUnfree = true;
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
    extraGroups = ["wheel" "plugdev" "dialout" "lp" "scanner"];
    shell = pkgs.fish;
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCyPk5WyFoWSvF4ozehxcVBoZ+UHgrI7VW/OoQfFFwIQe0qvetUZBMZwR2FwkLPAMZV8zz1v4EfncudEkVghy4P+/YVLlDjqDq9zwZnh8Nd/ifu84wmcNWHT2UcqnhjniCdshL8a44memzABnxfLLv+sXhP2x32cJAamo5y6fukr2qLp2jbXzR+3sv3klE0ruUXis/BR1lLqNJEYP8jB6fLn2sLKinnZPfn6DwVOk10mGeQsdME/eGl3phpjhODH9JW5V2V5nJBbC0rBnq+78dyArKVqjPSmIcSy72DEIpTctnMEN1W34BGrnsDd5Xd/DKxKxHKTMCHtZRwLC2X0NWN"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCMALVC8RDTHec+PC8y1s3tcpUAODgq6DEzQdHDf/cyvDMfmCaPiMxfIdmkns5lMa03hymIfSmLUF0jFFDc7biRp7uf9AAXNsrTmplHii0l0McuOOZGlSdZM4eL817P7UwJqFMxJyFXDjkubhQiX6kp25Kfuj/zLnupRCaiDvE7ho/xay6Jrv0XLz935TPDwkc7W1asLIvsZLheB+sRz9SMOb9gtrvk5WXZl5JTOFOLu+JaRwQLHL/xdcHJTOod7tqHYfpoC5JHrEwKzbhTOwxZBQBfTQjQktKENQtBxXHTe71rUEWfEZQGg60/BC4BrRmh4qJjlJu3v4VIhC7SSHn1"
    ];
  };
  users.extraUsers.rj = {
    isNormalUser = true;
    extraGroups = ["wheel" "plugdev" "dialout"];
  };
  users.extraUsers.astro = {
    isNormalUser = true;
    extraGroups = ["plugdev" "dialout"];
  };
  users.extraUsers.nix = {
    isNormalUser = true;
  };
  security.sudo.wheelNeedsPassword = false;
  security.hideProcessInformation = true;
  boot.kernel.sysctl."kernel.dmesg_restrict" = true;
  services.udev.packages = [ pkgs.sane-backends ];

  nix.distributedBuilds = true;
  nix.buildMachines = [
    {
       hostName = "localhost";
       maxJobs = 4;
       system = "x86_64-linux";
       supportedFeatures = ["big-parallel"];
    }
    {
       hostName = "rpi-3";
       sshUser = "nix";
       sshKey = "/etc/nixos/secret/nix_id_rsa";
       maxJobs = 1;
       system = "aarch64-linux";
    }
  ];
  services.hydra = {
    enable = true;
    package = pkgs.hydra-unstable;
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
        job = web:web:web
        command = [ $(jq '.buildStatus' < $HYDRA_JSON) = 0 ] && ln -sfn $(jq -r '.outputs[0].path' < $HYDRA_JSON) ${hydraWwwOutputs}/web
      </runcommand>

      <runcommand>
        job = artiq:full:sipyco-manual-html
        command = [ $(jq '.buildStatus' < $HYDRA_JSON) = 0 ] && ln -sfn $(jq -r '.outputs[0].path' < $HYDRA_JSON) ${hydraWwwOutputs}/sipyco-manual-html
      </runcommand>
      <runcommand>
        job = artiq:full:sipyco-manual-latexpdf
        command = [ $(jq '.buildStatus' < $HYDRA_JSON) = 0 ] && ln -sfn $(jq -r '.outputs[0].path' < $HYDRA_JSON) ${hydraWwwOutputs}/sipyco-manual-latexpdf
      </runcommand>

      <runcommand>
        job = artiq:full-beta:artiq-manual-html
        command = [ $(jq '.buildStatus' < $HYDRA_JSON) = 0 ] && ln -sfn $(jq -r '.outputs[0].path' < $HYDRA_JSON) ${hydraWwwOutputs}/artiq-manual-html-beta
      </runcommand>
      <runcommand>
        job = artiq:full-beta:artiq-manual-latexpdf
        command = [ $(jq '.buildStatus' < $HYDRA_JSON) = 0 ] && ln -sfn $(jq -r '.outputs[0].path' < $HYDRA_JSON) ${hydraWwwOutputs}/artiq-manual-latexpdf-beta
      </runcommand>
      <runcommand>
        job = artiq:full-beta:conda-channel
        command = [ $(jq '.buildStatus' < $HYDRA_JSON) = 0 ] && ln -sfn $(jq -r '.outputs[0].path' < $HYDRA_JSON) ${hydraWwwOutputs}/artiq-conda-channel-beta
      </runcommand>

      <runcommand>
        job = artiq:full:artiq-manual-html
        command = [ $(jq '.buildStatus' < $HYDRA_JSON) = 0 ] && ln -sfn $(jq -r '.outputs[0].path' < $HYDRA_JSON) ${hydraWwwOutputs}/artiq-manual-html
      </runcommand>
      <runcommand>
        job = artiq:full:artiq-manual-latexpdf
        command = [ $(jq '.buildStatus' < $HYDRA_JSON) = 0 ] && ln -sfn $(jq -r '.outputs[0].path' < $HYDRA_JSON) ${hydraWwwOutputs}/artiq-manual-latexpdf
      </runcommand>
      <runcommand>
        job = artiq:full:conda-channel
        command = [ $(jq '.buildStatus' < $HYDRA_JSON) = 0 ] && ln -sfn $(jq -r '.outputs[0].path' < $HYDRA_JSON) ${hydraWwwOutputs}/artiq-conda-channel
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
    mailerPasswordFile = "/etc/nixos/secret/mailerpassword";
    extraConfig =
    ''
    [mailer]
    ENABLED = true
    HOST = ssl.serverraum.org:587
    FROM = sysop@m-labs.hk
    USER = sysop@m-labs.hk

    [service]
    ENABLE_NOTIFY_MAIL = true

    [attachment]
    ALLOWED_TYPES = */*
    '';
  };
  systemd.tmpfiles.rules = [
    "L+ '${config.services.gitea.stateDir}/custom/templates/home.tmpl' - - - - ${./gitea-home.tmpl}"
  ];

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
    hydra-unstable = super.hydra-unstable.overrideAttrs(oa: {
      patches = oa.patches or [] ++ [ ./hydra-conda.patch ./hydra-retry.patch ./hydra-unbreak-sysbuild.patch ];
      hydraPath = oa.hydraPath + ":" + super.lib.makeBinPath [ super.jq ];
    });
    matterbridge = super.matterbridge.overrideAttrs(oa: {
      patches = oa.patches or [] ++ [ ./matterbridge-disable-github.patch ];
    });
  };

  security.acme.acceptTerms = true;
  security.acme.email = "sb" + "@m-labs.hk";
  security.acme.certs = {
    "nixbld.m-labs.hk" = {
      group = "nginx";
      user = "nginx";
      webroot = "/var/lib/acme/acme-challenge";
      extraDomains = {
        "m-labs.hk" = null;
        "www.m-labs.hk" = null;
        "conda.m-labs.hk" = null;
        "lab.m-labs.hk" = null;
        "git.m-labs.hk" = null;
        "chat.m-labs.hk" = null;
        "hooks.m-labs.hk" = null;
        "forum.m-labs.hk" = null;
        "perso.m-labs.hk" = null;
        "nmigen.org" = null;
        "www.nmigen.org" = null;

        "openhardware.hk" = null;
        "git.openhardware.hk" = null;
      };
    };
  };
  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedGzipSettings = true;
    virtualHosts = let
      mainWebsite = {
        addSSL = true;
        useACMEHost = "nixbld.m-labs.hk";
        root = "${hydraWwwOutputs}/web";
        extraConfig = ''
          error_page 404 /404.html;
        '';
        locations."^~ /fonts/".extraConfig = ''
          expires 60d;
        '';
        locations."^~ /js/".extraConfig = ''
          expires 60d;
        '';
        locations."/MathJax/" = {
          alias = "/var/www/MathJax/";
          extraConfig = ''
            expires 60d;
          '';
        };

        # legacy URLs, redirect to avoid breaking people's bookmarks
        locations."/gateware.html".extraConfig = ''
          return 301 /gateware/migen/;
        '';
        locations."/migen".extraConfig = ''
          return 301 /gateware/migen/;
        '';
        locations."/artiq".extraConfig = ''
          return 301 /experiment-control/artiq/;
        '';
        locations."/artiq/resources.html".extraConfig = ''
          return 301 /experiment-control/resources/;
        '';

        # autogenerated manuals
        locations."/artiq/sipyco-manual/" = {
          alias = "${hydraWwwOutputs}/sipyco-manual-html/share/doc/sipyco-manual/html/";
        };
        locations."=/artiq/sipyco-manual.pdf" = {
          alias = "${hydraWwwOutputs}/sipyco-manual-latexpdf/share/doc/sipyco-manual/SiPyCo.pdf";
        };
        locations."/artiq/manual-beta/" = {
          alias = "${hydraWwwOutputs}/artiq-manual-html-beta/share/doc/artiq-manual/html/";
        };
        locations."=/artiq/manual-beta.pdf" = {
          alias = "${hydraWwwOutputs}/artiq-manual-latexpdf-beta/share/doc/artiq-manual/ARTIQ.pdf";
        };
        locations."/artiq/manual/" = {
          alias = "${hydraWwwOutputs}/artiq-manual-html/share/doc/artiq-manual/html/";
        };
        locations."=/artiq/manual.pdf" = {
          alias = "${hydraWwwOutputs}/artiq-manual-latexpdf/share/doc/artiq-manual/ARTIQ.pdf";
        };

        # legacy content
        locations."/migen/manual/" = {
          alias = "/var/www/m-labs.hk.old/migen/manual/";
        };
        locations."/artiq/manual-release-4/" = {
          alias = "/var/www/m-labs.hk.old/artiq/manual-release-4/";
        };
        locations."/artiq/manual-release-3/" = {
          alias = "/var/www/m-labs.hk.old/artiq/manual-release-3/";
        };
        locations."/artiq/manual-release-2/" = {
          alias = "/var/www/m-labs.hk.old/artiq/manual-release-2/";
        };
      };
    in {
      "m-labs.hk" = mainWebsite;
      "www.m-labs.hk" = mainWebsite;
      "lab.m-labs.hk" = {
        addSSL = true;
        useACMEHost = "nixbld.m-labs.hk";
        locations."/munin/".alias = "/var/www/munin/";
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
      "conda.m-labs.hk" = {
        forceSSL = true;
        useACMEHost = "nixbld.m-labs.hk";
        locations."/artiq-beta/" = {
          alias = "${hydraWwwOutputs}/artiq-conda-channel-beta/";
          extraConfig = ''
            autoindex on;
            index bogus_index_file;
          '';
        };
        locations."/artiq/" = {
          alias = "${hydraWwwOutputs}/artiq-conda-channel/";
          extraConfig = ''
            autoindex on;
            index bogus_index_file;
          '';
        };
      };
      "git.m-labs.hk" = {
        forceSSL = true;
        useACMEHost = "nixbld.m-labs.hk";
        locations."/".proxyPass = "http://127.0.0.1:3001";
        extraConfig = ''
          client_max_body_size 300M;
        '';
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
        locations."/mattermost-github".extraConfig = ''
          include ${pkgs.nginx}/conf/uwsgi_params;
          uwsgi_pass unix:${config.services.uwsgi.runDir}/uwsgi-mgi.sock;
        '';
        locations."/rfq".extraConfig = ''
          include ${pkgs.nginx}/conf/uwsgi_params;
          uwsgi_pass unix:${config.services.uwsgi.runDir}/uwsgi-rfq.sock;
        '';
      };
      "forum.m-labs.hk" = {
        forceSSL = true;
        useACMEHost = "nixbld.m-labs.hk";
        root = "/var/www/flarum/public";
        locations."~ \.php$".extraConfig = ''
          fastcgi_pass unix:${config.services.phpfpm.pools.flarum.socket};
          fastcgi_index index.php;
        '';
        extraConfig = ''
          index index.php;
          include /var/www/flarum/.nginx.conf;
        '';
      };
      "perso.m-labs.hk" = {
        addSSL = true;
        useACMEHost = "nixbld.m-labs.hk";
        root = "/var/www/perso";
      };
      "nmigen.org" = {
        addSSL = true;
        useACMEHost = "nixbld.m-labs.hk";
        locations."/".extraConfig = ''
          return 307 https://m-labs.hk/gateware/nmigen/;
        '';
      };
      "www.nmigen.org" = {
        addSSL = true;
        useACMEHost = "nixbld.m-labs.hk";
        locations."/".extraConfig = ''
          return 307 https://m-labs.hk/gateware/nmigen/;
        '';
      };

      "git.openhardware.hk" = {
        forceSSL = true;
        useACMEHost = "nixbld.m-labs.hk";
        locations."/".proxyPass = "http://127.0.0.1:3002";
        extraConfig = ''
          client_max_body_size 300M;
        '';
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
        rfq = import ./rfq/uwsgi-config.nix { inherit config pkgs; };
      };
    };
  };
  services.mysql = {
    enable = true;
    package = pkgs.mariadb;
  };
  services.phpfpm.pools.flarum = {
    user = "nobody";
    settings = {
      "listen.owner" = "nginx";
      "listen.group" = "nginx";
      "listen.mode" = "0600";
      "pm" = "dynamic";
      "pm.max_children" = 5;
      "pm.start_servers" = 2;
      "pm.min_spare_servers" = 1;
      "pm.max_spare_servers" = 3;
      "pm.max_requests" = 500;
    };
  };

  services.homu = {
    enable = true;
    config = "/etc/nixos/secret/homu.toml";
  };

  mailserver = {
    enable = true;
    localDnsResolver = false;  # conflicts with dnsmasq
    # Some mail servers do reverse DNS lookups to filter spam.
    # Getting a proper reverse DNS record from ISP is difficult, so use whatever already exists.
    fqdn = "42-200-147-171.static.imsbiz.com";
    domains = [ "nmigen.org" ];
    loginAccounts = (import /etc/nixos/secret/email_accounts.nix);
    certificateScheme = 3;
  };
  security.acme.certs."${config.mailserver.fqdn}".extraDomains = {
    "mail.nmigen.org" = null;
  };

  containers.openhardwarehk = {
    autoStart = true;
    config =
      { config, pkgs, ... }:
      {
        services.gitea = {
          enable = true;
          httpPort = 3002;
          rootUrl = "https://git.openhardware.hk/";
          appName = "Open Hardware HK";
          cookieSecure = true;
          disableRegistration = true;
          extraConfig =
          ''
          [attachment]
          ALLOWED_TYPES = */*
          '';
        };
      };
  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "18.09"; # Did you read the comment?
}
