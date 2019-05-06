{ stdenv, git, fetchgit }:
let
  artiq-version = stdenv.mkDerivation {
    name = "artiq-version";
    src = import ./artiq-src.nix { inherit fetchgit; };
    buildPhase = ''
      REV=`${git}/bin/git rev-parse HEAD`
      COMMITCOUNT=`${git}/bin/git rev-list --count HEAD`
    '';
    installPhase = ''
      echo -n 5.$COMMITCOUNT.`cut -c1-8 <<< $REV`-beta > $out
    '';
  };
in
  builtins.readFile artiq-version
