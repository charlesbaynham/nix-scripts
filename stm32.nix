# For running on Hydra
{ pkgs ? import <nixpkgs> {},
  rustManifest ? ./channel-rust-nightly.toml
}:

let
  jobs = callPackage ./default.nix {
    inherit rustManifest;
    mozillaOverlay = import <mozillaOverlay>;
  };
in
  builtins.mapAttrs (key: value: pkgs.lib.hydraJob value) jobs
