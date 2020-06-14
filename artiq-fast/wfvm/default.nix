{ pkgs ? import <nixpkgs> {} }:

{
  makeWindowsImage = attrs: import ./win.nix ({ inherit pkgs; } // attrs);
  layers = (import ./layers { inherit pkgs; });
}
