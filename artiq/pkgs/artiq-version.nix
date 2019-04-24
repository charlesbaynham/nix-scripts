{ stdenv, git, fetchgit }:
let
  artiq-version = stdenv.mkDerivation {
    name = "artiq-version";
    src = import ./artiq-src.nix { inherit fetchgit; };
    buildPhase = ''
      REV=`${git}/bin/git rev-parse HEAD`
    '';
    installPhase = ''
      echo -n 5e.`cut -c1-8 <<< $REV` > $out
    '';
  };
in
  builtins.readFile artiq-version
