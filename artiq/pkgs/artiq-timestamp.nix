let pkgs = import <nixpkgs> {};
in
with pkgs;
let
  artiq-timestamp = stdenv.mkDerivation {
    name = "artiq-timestamp";
    src = import ./artiq-src.nix { inherit fetchgit; };
    buildInputs = [ git ];
    buildPhase = ''
      TIMESTAMP=`${git}/bin/git log -1 --format=%ct`
    '';
    installPhase = ''
      echo \"$TIMESTAMP\" > $out
    '';
  };
in
  builtins.readFile artiq-timestamp
