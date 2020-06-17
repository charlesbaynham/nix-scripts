{ host, rpi4 }:

{ config, pkgs, ... }:
let
  m-labs = import (fetchTarball https://nixbld.m-labs.hk/channel/custom/artiq/full/artiq-full/nixexprs.tar.xz) { inherit pkgs; };
in
{
  deployment.targetHost = host;
  nixpkgs.system = "aarch64-linux";

  boot.loader.grub.enable = false;

  boot.loader.generic-extlinux-compatible.enable = !rpi4;
  boot.loader.raspberryPi = pkgs.lib.mkIf rpi4 {
    enable = true;
    version = 4;
  };
  boot.kernelPackages = pkgs.lib.mkIf rpi4 pkgs.linuxPackages_latest;

  fileSystems = if rpi4 then {
    "/boot" = {
      device = "/dev/disk/by-label/FIRMWARE";
      fsType = "vfat";
    };
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
    };
  } else {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
    };
  };

  services.openssh.enable = true;
  services.openssh.passwordAuthentication = false;

  networking.hostName = host;
  time.timeZone = "Asia/Hong_Kong";

  users.extraGroups.plugdev = { };
  users.mutableUsers = false;
  users.defaultUserShell = pkgs.fish;
  users.extraUsers = (import ./common-users.nix) // {
    nix = {
      isNormalUser = true;
    };
  };
  security.sudo.wheelNeedsPassword = false;
  services.udev.packages = [ m-labs.openocd ];

  documentation.enable = false;
  environment.systemPackages = with pkgs; [
    psmisc wget vim git usbutils lm_sensors file telnet mosh tmux xc3sprog m-labs.openocd screen gdb minicom picocom
    (import ./fish-nix-shell)
  ];
  programs.fish.enable = true;
  programs.fish.promptInit = ''
    fish-nix-shell --info-right | source
  '';
  programs.wireshark.enable = true;

  nix.binaryCachePublicKeys = ["nixbld.m-labs.hk-1:5aSRVA5b320xbNvu30tqxVPXpld73bhtOeH6uAjRyHc="];
  nix.binaryCaches = ["https://cache.nixos.org" "https://nixbld.m-labs.hk"];
  nix.trustedUsers = ["root" "nix"];
}
