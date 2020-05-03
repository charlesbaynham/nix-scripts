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
  users.extraUsers.rj = {
    isNormalUser = true;
    extraGroups = ["wheel" "plugdev" "dialout"];
    openssh.authorizedKeys.keys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMUaB2G1jexxfkdlly3fdWslH54/s/bOuvk9AxqpjtAY robert-jordens-ed25519"];
  };
  users.extraUsers.astro = {
    isNormalUser = true;
    extraGroups = ["plugdev" "dialout" "wireshark" "wheel"];
    openssh.authorizedKeys.keys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGJJTSJdpDh82486uPiMhhyhnci4tScp5uUe7156MBC8 a"];
  };
  users.extraUsers.harry = {
    isNormalUser = true;
    extraGroups = ["plugdev" "dialout"];
    openssh.authorizedKeys.keys = ["ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDfZGegJYOV2qCdTf2R54thWt0UjH/ycarugV5UWrdql7w9yqaGwqeadRIVoz9IH++AB8NFxPzxMiQzOH5TI4r5hVjconslSeucMvh9u/GPJqQk94uZayodgfqCeBL5v8RqW4kJE1CHrSbKhzLrtWsTsju2XFidLGqBg1v7HWmSB6UqzqmQWqPLxDCi7/JW2ECuKjYlOJY+uzGFz5cxOtJO/lUNSXT3ZSWF/VLscuMmLsdyocdVwZANgPS7A0/wArlbZZMNw72CHuWsh8WVxarKIRwhoaBgXv7Oj3ohi6fVRGo1DOC3ucDGCDNjaQG2gbXGHEiPtrpz43I7BcCeJqNH harry@juno"];
  };
  users.extraUsers.jerry = {
    isNormalUser = true;
    extraGroups = ["plugdev" "dialout"];
    openssh.authorizedKeys.keys = ["ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC1vcq23Z221/OoiXombiXJYzQNTlgtWTXSnBI1jRDgcOfEX993jGIcC6NAa4czeqKu6kqEo+dqGMO872lPTo57KcBNmev+2J+WfvrRRu5uCkMcYWPA6peQq9VJ3+/YT8uShYN8KeDnlfuER8KrDo5RKX+SWk0NSgMXwdW5HD6bmRac1K6kydB+IGrltyUpph37vJEzF+OxPySiLQhWrwSQERYya+3fI/NsilffYa5qoDFmEfKwaSLIJ9zLbhTR7UPc0loQjyICOlGempbHwKK1YZJfidGIf5pHsW3wT3EnJzbMliQspXkw0KZyZij529TnoQkjGEsAsHI1es92/VP5 jerry@jerry-VivoBook-Flip-14-TP410UF"];
  };
  users.extraUsers.vince = {
    isNormalUser = true;
    extraGroups = ["plugdev" "dialout"];
    openssh.authorizedKeys.keys = ["ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCyjDbp6PUxNpYvtShXLnvqQp/le5cNBpxN2WdxCd929ejNigIbg4Y01Exnwd5hjCQ7FJeEj+cCzoJEW4ZLkE91pH/cqwHLkoClr0N5TYv7bFb91gOP0aaPItQyJIPjhiR2OwMgVWi2pA+g/voQeFv1WzIPWaSTVf71wGUZ956jnZxQwUFdZoaje2vnUtGjMbmbPSZia6Naf/mwLqJIvoGelJbhVUtgwFDEWNjq3T8pIkCBR8pYlFDb2r61IR6quGoJWzhPjyL61KLceZPmtXXQg/wfX+IEYRK+jImc3XHx6c8c2aHj4ySWlCzxv+5jHrlqgyd+vF39VcDYLqx3/1JT vince@Vince-CHENG"];
  };
  users.extraUsers.pca006132 = {
    isNormalUser = true;
    extraGroups = ["plugdev" "dialout"];
    openssh.authorizedKeys.keys = ["ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCqkGZIb57sjzcnYg6tJXrK1iPKnIP6iYkcc2h/cf4rknvOT9ZkeUra7hCTjQDCiC168Lxcdx2wQciuq2SypoUMFytQoLphGHKWpgLB6yoaQgwCUW+To55kJlbs/rOywfwaRAtiyNsCtf+1FTbl0X0mKNIibjDqVyawXaUhfDLNB0TPg1yhhHdi/fqDgq+9kI/2E++8k9TZ2SUZ6vLbERU0cRkGCrVhqR7QEV+Oqa0uFBvNzc+tp/L3BKUUOCiSThNOtUHR9mSx9/Yq31tQ/I+l+oDcJyDiQlrFvDTBRbaDiMDwTFZolsQ8pFR0aJXHOrWRP11LF/EibjqbiK6WHDG/2mTnkREgGOElbOhg4yypMg5KXPY3JhjNibXV8p4GHjRb9g59N7F0s+ez44uS85fXUVVf840+mOx7W+9hGxK5ALr1I5EjUz8q2/SsF4eYuD44xCPK5rrKP0BYjnEQcDQEe5aZ2KyX+aSBF8jeiZsXti6x3Jg7ces6zlBWOoBNOPqTug4eNtkNmmPaoAzVeiItTJZBUAehLUAzyRD+8aTyB4DWAvesHPan+uQb9HvPH0rgymSEGxTi5280VWwvEpKHTGbuB0eYNFffDYVW0Y6xx3K4mZi71r6yCRdC/tsQEyM7N/dtoknvf77+iXCpb5yVSj0j5IAIVhlyszVMiW2qmw=="];
  };
  users.extraUsers.ashafir = {
    isNormalUser = true;
    extraGroups = ["plugdev" "dialout"];
    openssh.authorizedKeys.keys = ["ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC63csV1jA//Dix4hb2dYxuYdtYaTRKrN5d4BfRD/mTui1V4reWBkc9kvqhpb4SarTnJFbQUkmkPoIp/rOKpmHoOQHHdAC2lTr9RluL1iT/TLWjKMU6BA60L49i/PwR8UE26EodHKV1OI7Se3JzD0Ta/yoRIRcIV261kzjv3F0Ag3TcX+FWQ6oj6iKk6drFUodTFWufvR1/qIKkTz4d4K4J7JcykLFuTYjg4koCuMDufGobAvGLbQL3haad9kdywBaHvrxX1gEh6hgbprFtDoNufJy+rKKRUGSVgs7GBxLSjQ/9Ylqmso+YV+6zyYcpgQhpElrQr00JiDrFB1JO+9uipL3rQOHjwTWC6Rht5GEAq/WuTMKmWQUg4UIkKXadELRY7RI7NvWEe4V0h4vEIM+XQpbFofDZ4+1aQhsn/AIt0Sa54YAJtU1Vurvj76o2srNFNX1B0LVKmkU8QZ4KGlmfl/QMKA4bFXoedh9C+3B2of0XJc5tCsl4jxbbSjagLfVSMsnTyu8hZpjAmtsWrlkmnF12HLgtrU6OuLQ8OxMcUgwbYmvqJSni02DZ4EE4lS4+mlgzpdezUmsnRGGiNN5DTEpAQdSs54FdE3oEUpYEpJFUz7B9JwWsVyz6p/tpPmm4N+lbeYYEFF2L3Y53cLyKRTWfpsH1WsiH10H+P7ltFQ=="];
  };

  services.udev.packages = [ m-labs.openocd ];

  documentation.enable = false;
  environment.systemPackages = with pkgs; [
    psmisc wget vim git usbutils lm_sensors file telnet mosh tmux xc3sprog m-labs.openocd screen gdb minicom picocom
  ];
  programs.fish.enable = true;
  users.defaultUserShell = pkgs.fish;

  nix.binaryCachePublicKeys = ["nixbld.m-labs.hk-1:5aSRVA5b320xbNvu30tqxVPXpld73bhtOeH6uAjRyHc="];
  nix.binaryCaches = ["https://cache.nixos.org" "https://nixbld.m-labs.hk"];
  nix.trustedUsers = ["root" "nix"];
}
