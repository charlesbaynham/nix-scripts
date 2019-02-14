{ pkgs ? import <nixpkgs> {}, constituents}:
pkgs.releaseTools.channel {
  name = "main";
  src = ./.;
  inherit constituents;
}
