{ pkgs ? import <nixpkgs> {} }:

{
  makeWindowsImage = attrs: import ./win.nix ({ inherit pkgs; } // attrs);
  pkgs = import ./pkgs.nix { inherit pkgs; };
}
