{ pkgs ? import <nixpkgs> {}}:

let
  sinaraSystemsSrc = <sinaraSystemsSrc>;

  generatedNix = pkgs.runCommand "generated-nix" { buildInputs = [ pkgs.nix pkgs.git ]; }
    ''
    mkdir $out

    cp -a ${<artiq-fast>} $out/fast

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
      variants = [
        "berkeley"
        "berkeley2"
        "duke"
        "duke2"
        "duke3"
        "hub"
        "hustmaster"
        "hustsatellite"
        "ist"
        "luh"
        "mitll"
        "mitll2"
        "mpik"
        "nrc"
        "nudt"
        "ptb"
        "ptb2"
        "ptb3"
        "su"
        "sysu"
        "tsinghua"
        "tsinghua2"
        "ubirmingham"
        "ucr"
        "unsw"
        "unsw2"
        "ustc"
        "vlbaimaster"
        "vlbaisatellite"
        "wipm"
        "wipm2"
        "wipm3"
      ];

      artiq-fast = import ./fast { inherit pkgs; };
      artiq-board = import ./fast/artiq-board.nix { inherit pkgs; };
      conda-artiq-board = import ./fast/conda-artiq-board.nix { inherit pkgs; };
      src = pkgs.fetchgit {
        url = "https://git.m-labs.hk/M-Labs/sinara-systems.git";
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
          } // (pkgs.lib.optionalAttrs ((builtins.fromJSON (builtins.readFile json)).base == "standalone") {
            "device-db-\''${target}-\''${variant}" = pkgs.stdenv.mkDerivation {
              name = "device-db-\''${target}-\''${variant}";
              buildInputs = [ artiq-fast.artiq ];
              phases = [ "buildPhase" ];
              buildPhase = "
                mkdir \$out
                artiq_ddb_template \''${json} -o \$out/device_db.py
                mkdir \$out/nix-support
                echo file device_db_template \$out/device_db.py >> \$out/nix-support/hydra-build-products
                ";
            };
          })) {} variants;
    in
      artiq-fast // generic-kasli // {
        artiq-board-sayma-satellite = artiq-board {
          target = "sayma";
          variant = "satellite";
          buildCommand = "python -m artiq.gateware.targets.sayma_rtm && python -m artiq.gateware.targets.sayma_amc -V satellite";
          extraInstallCommands = "cp artiq_sayma/rtm_gateware/rtm.bit \$TARGET_DIR";
        };
        artiq-board-metlino-master = artiq-board {
          target = "metlino";
          variant = "master";
          buildCommand = "python -m artiq.gateware.targets.metlino";
        };
      }
    EOF
    '';
  pythonDeps = import ./artiq-full/pythonDeps.nix { inherit pkgs; };
  manualPackages = import ./artiq-full/manual.nix {
    inherit (pkgs) stdenv lib fetchgit git python3Packages texlive texinfo;
    inherit (pythonDeps) sphinxcontrib-wavedrom;
  };
  jobs = builtins.mapAttrs (key: value: pkgs.lib.hydraJob value) (import generatedNix { inherit pkgs; }) // {
    # This is in the example in the ARTIQ manual - precompile it to speed up
    # installation for users.
    matplotlib-qt = pkgs.lib.hydraJob (pkgs.python3Packages.matplotlib.override { enableQt = true; });
    # For Raspberry Pi JTAG servers
    openocd-aarch64 = pkgs.lib.hydraJob ((import <nixpkgs> { system = "aarch64-linux"; }).callPackage ./artiq-fast/pkgs/openocd.nix {});
  };
in
  jobs // {
    channel = pkgs.releaseTools.channel {
      name = "sinara-systems";
      src = generatedNix;
      constituents = builtins.attrValues jobs;
    };
  }
