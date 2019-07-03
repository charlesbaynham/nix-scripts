{ pkgs ? import <nixpkgs> {} }:

let
  jobs = import ./urukul/default.nix { inherit pkgs; };
in
  builtins.mapAttrs (key: value: pkgs.lib.hydraJob value) jobs
