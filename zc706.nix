{
  pkgs ? import <nixpkgs> {},
  artiq-zynq ? import <artiq-zynq> { mozillaOverlay = import <mozillaOverlay>; },
}:
builtins.mapAttrs pkgs.lib.hydraJob artiq-zynq
