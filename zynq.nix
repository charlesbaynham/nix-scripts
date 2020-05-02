{
  pkgs ? import <nixpkgs> {},
  artiq-zynq ? import <artiq-zynq> { mozillaOverlay = import <mozillaOverlay>; },
}:
builtins.mapAttrs (key: value: pkgs.lib.hydraJob value) (
  pkgs.lib.filterAttrs (key: value: builtins.substring 0 6 key == "zc706-")
    artiq-zynq
)
