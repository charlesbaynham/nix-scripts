{
  pkgs ? import <nixpkgs> {},
  artiq-zynq ? import <artiq-zynq> { mozillaOverlay = import <mozillaOverlay>; },
}:
artiq-zynq
