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
  boot.kernelPackages = pkgs.lib.mkIf rpi4 pkgs.linuxPackages_rpi4;

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

  networking.hostName = host;
  time.timeZone = "Asia/Hong_Kong";

  users.extraGroups.plugdev = { };
  security.sudo.wheelNeedsPassword = false;
  users.extraUsers.sb = {
    isNormalUser = true;
    extraGroups = ["wheel" "plugdev" "dialout"];
  };
  users.extraUsers.astro = {
    isNormalUser = true;
    extraGroups = ["wheel" "plugdev" "dialout"];
  };
  users.extraUsers.nix = {
    isNormalUser = true;
  };
  services.udev.packages = [ m-labs.openocd ];

  documentation.enable = false;
  environment.systemPackages = with pkgs; [
    wget vim git usbutils lm_sensors file mosh tmux xc3sprog m-labs.openocd
  ];

  nix.binaryCachePublicKeys = ["nixbld.m-labs.hk-1:5aSRVA5b320xbNvu30tqxVPXpld73bhtOeH6uAjRyHc="];
  nix.binaryCaches = ["https://cache.nixos.org" "https://nixbld.m-labs.hk"];
  nix.trustedUsers = ["root" "nix"];
}
