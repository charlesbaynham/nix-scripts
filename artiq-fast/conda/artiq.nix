{ pkgs }:

let
  version = import ../pkgs/artiq-version.nix (with pkgs; { inherit stdenv fetchgit git; });
  fakeCondaSource = import ./fake-source.nix { inherit pkgs; } {
    name = "artiq";
    inherit version;
    src = import ../pkgs/artiq-src.nix { fetchgit = pkgs.fetchgit; };
    dependencies = import ./artiq-deps.nix;
    extraYaml =
    ''
    about:
      home: https://m-labs.hk/artiq
      license: LGPL
      summary: 'A leading-edge control system for quantum information experiments'
    '';
  };
  conda-artiq = import ./build.nix { inherit pkgs; } {
    name = "conda-artiq";
    src = fakeCondaSource;
  };
in
  conda-artiq
