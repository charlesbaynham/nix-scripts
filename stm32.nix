{ pkgs ? import <nixpkgs> {} }:

let
  jobs = import ./stm32/default.nix {
    mozillaOverlay = import <mozillaOverlay>;
  };
in
  builtins.mapAttrs (key: value: pkgs.lib.hydraJob value) jobs
