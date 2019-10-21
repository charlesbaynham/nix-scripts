{ host }:

{ config, pkgs, lib, ... }:
let
  m-labs = import (fetchTarball https://nixbld.m-labs.hk/channel/custom/artiq/full/artiq-full/nixexprs.tar.xz) {};
in
{
  deployment.targetHost = host;
  nixpkgs.system = "aarch64-linux";
    
  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;
 
  boot.kernelParams = ["cma=32M console=ttyS1,115200n8"];

  fileSystems = {
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
