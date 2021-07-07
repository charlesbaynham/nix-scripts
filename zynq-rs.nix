let
  pkgs = import <nixpkgs> {};
  zynq-rs = import <zynq-rs>;
in
  (
    builtins.mapAttrs (key: value: pkgs.lib.hydraJob value) zynq-rs
  )
