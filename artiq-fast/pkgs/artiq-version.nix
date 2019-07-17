{ stdenv, git, fetchgit }:
let
  artiq-version = stdenv.mkDerivation {
    name = "artiq-version";
    src = import ./artiq-src.nix { inherit fetchgit; };
    buildPhase = ''
      REV=`${git}/bin/git rev-parse HEAD`
      MAJOR_VERSION=`cat MAJOR_VERSION`
      COMMIT_COUNT=`${git}/bin/git rev-list --count HEAD`
    '';
    installPhase = ''
      echo -n $MAJOR_VERSION.$COMMIT_COUNT.`cut -c1-8 <<< $REV`.beta > $out
    '';
  };
in
  builtins.readFile artiq-version
