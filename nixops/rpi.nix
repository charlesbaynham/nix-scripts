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

  programs.wireshark.enable = true;

  users.extraUsers.nix = {
    isNormalUser = true;
  };

  users.extraGroups.plugdev = { };
  security.sudo.wheelNeedsPassword = false;
  users.extraUsers.sb = {
    isNormalUser = true;
    extraGroups = ["wheel" "plugdev" "dialout"];
    openssh.authorizedKeys.keys = ["ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDZGtCJoIRtRadaSBMx+MNX53nvEGUk9q/89ZpEH/jCRS+FRnBOH73C8YGvsJaiL5xUZiLjIW7SRUr40bKgvns1FJ3PNMPqvAh6fC98h5EnWAVtzKpYVXGPVvxGOqRJwvEHr6DGMJbP1lRl78zFt3PQaeEiJ5mCxlY4KenKbkBJpUWBAUa11VrNd+o7AMfF0pbNDxZCd213brbyb8saLnEx28HwdaUn//MMWnfSPDLGlod5dy4/hzj0Yk/o+4yaeIkfk1Z0FqtZif1N+VTqD5r0dfvIi38mmVYzbImy5X/hoPtLTMRb//6KZH5POwMP3ZazIq7Bl0cmGfDEu/p6/zJd sb@sb-ThinkPad-10"];
  };
  users.extraUsers.astro = {
    isNormalUser = true;
    extraGroups = ["plugdev" "dialout" "wireshark"];
    openssh.authorizedKeys.keys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGJJTSJdpDh82486uPiMhhyhnci4tScp5uUe7156MBC8 a"];
  };
  users.extraUsers.harry = {
    isNormalUser = true;
    extraGroups = ["plugdev" "dialout"];
    openssh.authorizedKeys.keys = ["ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDfZGegJYOV2qCdTf2R54thWt0UjH/ycarugV5UWrdql7w9yqaGwqeadRIVoz9IH++AB8NFxPzxMiQzOH5TI4r5hVjconslSeucMvh9u/GPJqQk94uZayodgfqCeBL5v8RqW4kJE1CHrSbKhzLrtWsTsju2XFidLGqBg1v7HWmSB6UqzqmQWqPLxDCi7/JW2ECuKjYlOJY+uzGFz5cxOtJO/lUNSXT3ZSWF/VLscuMmLsdyocdVwZANgPS7A0/wArlbZZMNw72CHuWsh8WVxarKIRwhoaBgXv7Oj3ohi6fVRGo1DOC3ucDGCDNjaQG2gbXGHEiPtrpz43I7BcCeJqNH harry@juno"];
  };
  users.extraUsers.konstantin = {
    isNormalUser = true;
    extraGroups = ["plugdev" "dialout"];
    openssh.authorizedKeys.keys = ["ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCiyF/90c4286ZeEBFbhpfoRkT+xaXM5QJ+uDXhfQ/015pMfhLTxXaX8xO/PvKjBhGx9DjTL57P3tXWQDOooKoE3cFSYunlVV1wQLXIbxRI8Hq8SQv2HJS3T4QJ9Wt5BCummQpz5XO2Rv/ih0By8ttWXXCoFCBOp1CfydQ/m4R7Nr1l7nFN3t4pBNiu2VFoEcedAj5/9LW+dJccAOHh7Jvr9sF0SB32ZdRYoC+9vUfsjVDx0dbEFNYMzS/TkpYwLYMVwfbxzn7jKMHnjpaM8gS4e9qkyFY2GcQBFebJW0PZbTNb6drHNsJ84tt7RXNikpdO2+ErILWV/MfdXwMCrIebFDOzl7bSufZcwpGSeYkUPneFbyGPH06hCaTUaJcYVk/59PMT33OCZL3E7swNbGn9VLxbpA4z4K4NQdP6n8+EPzi5czz+4FyyN8mIGKZjkNdDmLS61o0oKOWoxrQKNiAe4Ooy4hTB/jc5+UiNoiske/gdFJguV2Mr9de9eDU4QntfSLx0pthmc0rgdzPvyi8bVttL+vl0R5b3RL0FbcyjugOJLw3XrMXLxomZ/CyMncuis/iPYzZRMHEPvH0Uxd8rbnuTENF42pn96RHcHvlGLQ3fPlAgf6wXDA7Ecw0LBw20tPdHwooT/AM46+0OaFZTmq4WvZtAYMRnkUpmouKR7Q== konstantin@MBP.fritz.box"];
  };
  users.extraUsers.steinb = {
    isNormalUser = true;
    extraGroups = ["plugdev" "dialout"];
    openssh.authorizedKeys.keys = ["ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDAOatwhOkN9YBy8cj2AmNkhlfFd4iW1LF6ImKjBAijfV250YJgOvnzV/lqQxdHYQHNauU7f3kXx1SmrTi/AHsHaoAR0/tYIk57d+UrX9a+qVFSL6ackjzO2vi2nDCy+PBc5Tb3WfCPAICSAk6BZ07yM+SMXiSqwzsaOTMsKuJuwIi+PkmrYG/IvB39IFAi4XLffExyLqD7VxsfJeNp/alZSmw3i4nPJ2nmBX80U9sFw774VIxCRTD5s5uRcp8tDN7ywNot49m3J4wOtRyzLW0QQX7J6RuMsAEQ8bP7VOpWSrOVD+LJDRaN9GPJL6EIASmbRU5t3rKXdAjG0t6pBuR4gqOdOPtj+CUeO465P5A8BgvRE+BeBybVjjc2gFlDShhGxaWfOKWiA/fmbicVWocPWcBjabLMyvewH2JKgUPJ7wvpaAzhvrOktt+Kn2fHqtrvpGYfsPue4F67BmAijlnw2fCBdVlkbIPrFv9eOJI5GX25h6C08ESV3bwv0OqKLJoxP5cODuMrLV04dcOXpy7JLEaf+PcxLa1g65NPML3eL6TQpBVEKN794V/cXETcrwKYG7AYSLbBqqWbreYEJhCE6wntp6/xijBVEBFcf8wBdAzdQKWlAGbpttNwjJ+MYYy9kXc4SN3G33NfTctJeGm+Y7Bov8uh2G7vv6QR3L0/IQ== steinb@QF-stein-laptop"];
  };
  users.extraUsers.florent = {
    isNormalUser = true;
    extraGroups = ["plugdev" "dialout"];
    openssh.authorizedKeys.keys = ["ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDH3zGbV5zlJ2V8IsFkD2G8xpm03RsPCRKpvS5WLonogpfUO91zcgX1NVikNqB+EsyUvDtXBVu38esh31hoafXx050mqP6vtmjau4yBYOM0Z1Cp07b1oCQhMgeqkV3k2TJ69S5/fTzUYnneEv5yNhOPJucKwdDBqVdN1k/EEYx7WAlPSnpmnYB5xYlx+wB3YweNf9zFi3+4oadIYyKkdRD6+2HqqLxUVs4gVqVGilCIc4keMyrfOSmcK5MPPfhat+42WAkwZic26HJfZlQXujSPuMUnzizJ2BNUH5feDylkPCsSFJrhqoCvRESVaARAIb20IPo43qxN5YspqSzn4LV1frMjW66u/gl5X9psMEIsfNNUQ/KtKB70BzeRTJbIQY3FkKohLINPFKP76aPOvFx+T3MNvQ4MN/baqTPd8wnwggQa/srmdh/TBi2xeiOu83IRhhoy0gDRsrYipsuleVv8+xY1wEopFzVGG0iYrBueXDMuT8VSvgfh/REEqi7grp2RaG3GnkcWLWCARdsnPoaHPc5SANaKCwnxUalm79DHN1TzG/GNTwU2TXxCwCCNyD0E6oY5a5bByTC00e5mBRX0CqQTAlUacdztKb28kcGCOXb3kp//OD2O/yrca1tNqc/dF5y8LDMqEpy7EXQdK6kjiKeBnUjkAzmZ7y38PX5WHw== florent@enjoy-digital.fr"];
  };
  users.extraUsers.jerry = {
    isNormalUser = true;
    extraGroups = ["plugdev" "dialout"];
    openssh.authorizedKeys.keys = ["ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC1vcq23Z221/OoiXombiXJYzQNTlgtWTXSnBI1jRDgcOfEX993jGIcC6NAa4czeqKu6kqEo+dqGMO872lPTo57KcBNmev+2J+WfvrRRu5uCkMcYWPA6peQq9VJ3+/YT8uShYN8KeDnlfuER8KrDo5RKX+SWk0NSgMXwdW5HD6bmRac1K6kydB+IGrltyUpph37vJEzF+OxPySiLQhWrwSQERYya+3fI/NsilffYa5qoDFmEfKwaSLIJ9zLbhTR7UPc0loQjyICOlGempbHwKK1YZJfidGIf5pHsW3wT3EnJzbMliQspXkw0KZyZij529TnoQkjGEsAsHI1es92/VP5 jerry@jerry-VivoBook-Flip-14-TP410UF"];
  };

  services.udev.packages = [ m-labs.openocd ];

  documentation.enable = false;
  environment.systemPackages = with pkgs; [
    psmisc wget vim git usbutils lm_sensors file mosh tmux xc3sprog m-labs.openocd screen gdb minicom picocom
  ];

  nix.binaryCachePublicKeys = ["nixbld.m-labs.hk-1:5aSRVA5b320xbNvu30tqxVPXpld73bhtOeH6uAjRyHc="];
  nix.binaryCaches = ["https://cache.nixos.org" "https://nixbld.m-labs.hk"];
  nix.trustedUsers = ["root" "nix"];
}
