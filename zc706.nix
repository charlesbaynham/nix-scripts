{
  pkgs ? import <nixpkgs> {},
  artiq-zynq ? import <artiq-zynq> { mozillaOverlay = import <mozillaOverlay>; },
}:
  {
    test = artiq-zynq.zc706-sd-zip
  }
