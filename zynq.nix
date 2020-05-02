let
  pkgs = import <nixpkgs> {},
  artiq-zynq = import <artiq-zynq> { mozillaOverlay = import <mozillaOverlay>; },
in
builtins.mapAttrs (key: value: pkgs.lib.hydraJob value) artiq-zynq
