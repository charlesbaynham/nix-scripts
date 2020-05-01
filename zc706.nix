{
  pkgs ? import <nixpkgs> {},
  artiq-zynq ? import <artiq-zynq/default.nix> { mozillaOverlay = import <mozillaOverlay>; },
}:
  {
    test = artiq-zynq.zc706-sd-zip;
  }
