{ pkgs ? import <nixpkgs> {}}:

let
  sinaraSystemsSrc = <sinaraSystemsSrc>;

  generatedNix = pkgs.runCommand "generated-nix" { buildInputs = [ pkgs.nix pkgs.git ]; }
    ''
    mkdir $out
    REV=`git --git-dir ${sinaraSystemsSrc}/.git rev-parse HEAD`
    SINARA_SRC_CLEAN=`mktemp -d`
    cp -a ${sinaraSystemsSrc}/. $SINARA_SRC_CLEAN
    chmod -R 755 $SINARA_SRC_CLEAN/.git
    chmod 755 $SINARA_SRC_CLEAN
    rm -rf $SINARA_SRC_CLEAN/.git
    HASH=`nix-hash --type sha256 --base32 $SINARA_SRC_CLEAN`
    cat > $out/default.nix << EOF
    { pkgs ? import <nixpkgs> {}}:

    let
      target = "kasli";
      variants = ["berkeley" "ist" "mitll2" "mitll" "nrc" "nudt" "sysu" "tsinghua2" "tsinghua" "ubirmingham" "ucr" "unsw" "ustc" "wipm" "wipm2" "wipm3"];

      artiq = import <m-labs> { inherit pkgs; };
      artiq-board = import <m-labs/artiq-board.nix> { inherit pkgs; };
      conda-artiq-board = import <m-labs/conda-artiq-board.nix> { inherit pkgs; };
      src = pkgs.fetchgit {
        url = "git://github.com/m-labs/sinara-systems.git";
        rev = "$REV";
        sha256 = "$HASH";
      };
      generic-kasli = pkgs.lib.lists.foldr (variant: start:
        let
          json = builtins.toPath (src + "/\''${variant}.json");
          boardBinaries = artiq-board {
            inherit target variant;
            buildCommand = "python -m artiq.gateware.targets.kasli_generic \''${json}";
          };
        in
          start // {
            "artiq-board-\''${target}-\''${variant}" = boardBinaries;
            "conda-artiq-board-\''${target}-\''${variant}" = conda-artiq-board {
              boardBinaries = boardBinaries;
              inherit target variant;
            };
            "device-db-\''${target}-\''${variant}" = pkgs.stdenv.mkDerivation {
              name = "device-db-\''${target}-\''${variant}";
              buildInputs = [ artiq.artiq ];
              phases = [ "buildPhase" ];
              buildPhase = "
                mkdir \$out
                artiq_ddb_template \''${json} -o \$out/device_db.py
                mkdir \$out/nix-support
                echo file device_db_template \$out/device_db.py >> \$out/nix-support/hydra-build-products
                ";
            };
         }) {} variants;
    in
      generic-kasli // {
        artiq-board-sayma-satellite = artiq-board {
          target = "sayma";
          variant = "satellite";
          buildCommand = "python -m artiq.gateware.targets.sayma_rtm && python -m artiq.gateware.targets.sayma_amc -V satellite";
          extraInstallCommands = "cp artiq_sayma/rtm_gateware/rtm.bit \$TARGET_DIR";
        };
      }
    EOF
    '';
  jobs = builtins.mapAttrs (key: value: pkgs.lib.hydraJob value) (import generatedNix { inherit pkgs; });
in
  jobs // {
    channel = pkgs.releaseTools.channel {
      name = "sinara-systems";
      src = generatedNix;
      constituents = builtins.attrValues jobs;
    };
  }
