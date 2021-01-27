{ pkgs ? import <nixpkgs> {}
, artiq-fast ? <artiq-fast>
}:

let
  sinaraSystemsSrc = <sinaraSystemsSrc>;
  generatedNix = pkgs.runCommand "generated-nix" { buildInputs = [ pkgs.nix pkgs.git ]; }
    ''
    mkdir $out
    cp ${./artiq-board.nix} $out/artiq-board.nix
    cp ${../artiq-full/artiq-targets.nix} $out/artiq-targets.nix
    cp -a ${artiq-fast} $out/fast

    REV=`git --git-dir ${sinaraSystemsSrc}/.git rev-parse HEAD`
    echo -n $REV > $out/sinara-rev.txt
    SINARA_SRC_CLEAN=`mktemp -d`
    cp -a ${sinaraSystemsSrc}/. $SINARA_SRC_CLEAN
    chmod -R 755 $SINARA_SRC_CLEAN/.git
    chmod 755 $SINARA_SRC_CLEAN
    rm -rf $SINARA_SRC_CLEAN/.git
    HASH=`nix-hash --type sha256 --base32 $SINARA_SRC_CLEAN`
    echo -n $HASH > $out/sinara-hash.txt

    cat > $out/default.nix << EOF
    { pkgs ? import <nixpkgs> {}
    }:

    let
      sinaraSystemsSrc = pkgs.fetchgit {
        url = "https://git.m-labs.hk/M-Labs/sinara-systems.git";
        rev = "$REV";
        sha256 = "$HASH";
      };
      artiq-fast = import ./fast { inherit pkgs; };
      artiq-board = import ./artiq-board.nix {
        inherit pkgs;
        artiq-fast = ./fast;
      };
    in
      builtins.mapAttrs (_: conf: pkgs.lib.hydraJob (artiq-board conf)) (
        import ./artiq-targets.nix {
          inherit pkgs sinaraSystemsSrc;
          artiqVersion = artiq-fast.artiq.version;
        }
      )
    EOF
    '';
  artiq-board-generated = import generatedNix {
    inherit pkgs;
  };
in
artiq-board-generated // {
  generated-nix = pkgs.lib.hydraJob generatedNix;
}
