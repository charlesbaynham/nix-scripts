{ config, pkgs, lib, ... }:
let
  m-labs = import (fetchTarball https://nixbld.m-labs.hk/channel/custom/artiq/main/channel/nixexprs.tar.xz) {};
in
{
  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;
 
  boot.kernelPackages = pkgs.linuxPackages_latest;
  
  boot.kernelParams = ["cma=32M console=ttyS1,115200n8"];
    
  fileSystems = {
    "/boot" = {
      device = "/dev/disk/by-label/NIXOS_BOOT";
      fsType = "vfat";
    };
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
    };
  };

  services.openssh.enable = true;

  networking.hostName = "rpi-1";
  time.timeZone = "Asia/Hong_Kong";

  users.extraGroups.plugdev = { };
  users.extraUsers.sb = {
    isNormalUser = true;
    extraGroups = ["wheel" "plugdev" "dialout"];
    uid = 1000;
  };
  security.sudo.wheelNeedsPassword = false;
  services.udev.packages = [ m-labs.openocd ];

  environment.systemPackages = with pkgs; [
    wget vim git usbutils mosh tmux xc3sprog m-labs.openocd
  ];

  nix.binaryCachePublicKeys = ["nixbld.m-labs.hk-1:5aSRVA5b320xbNvu30tqxVPXpld73bhtOeH6uAjRyHc="];
  nix.binaryCaches = ["https://cache.nixos.org" "https://nixbld.m-labs.hk"];
}
