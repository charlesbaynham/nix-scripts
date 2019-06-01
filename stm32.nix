{ pkgs ? import <nixpkgs> {}, rustManifest ? ./channel-rust-nightly.toml }:

let
  jobs = pkgs.callPackage ./default.nix {
    inherit rustManifest;
    mozillaOverlay = import <mozillaOverlay>;
  };
in
  builtins.mapAttrs (key: value: pkgs.lib.hydraJob value) jobs
