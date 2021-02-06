{ pkgs ? import <nixpkgs> {} }:

let
  jobs = import ./mcu/default.nix {
    mozillaOverlay = import <mozillaOverlay>;
  };
in
  builtins.mapAttrs (key: value: pkgs.lib.hydraJob value) jobs
