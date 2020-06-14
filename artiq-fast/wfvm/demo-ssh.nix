{ pkgs ? import <nixpkgs> {} }:

let
  wfvm = (import ./default.nix { inherit pkgs; });
in
  wfvm.utils.wfvm-run {
    name = "demo-ssh";
    image = import ./demo-image.nix { inherit pkgs; };
    display = true;
    script = "${pkgs.openssh}/bin/ssh -p 2022 wfvm@localhost";
  }
