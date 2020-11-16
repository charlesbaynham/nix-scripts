{ pkgs ? import <nixpkgs> {}}:

let
  sinaraSystemsSrc = <sinaraSystemsSrc>;

  generatedNix = pkgs.runCommand "generated-nix" { buildInputs = [ pkgs.nix pkgs.git ]; }
    ''
    mkdir $out

    cp -a ${<artiq-fast>} $out/fast
    cp ${./artiq-full/conda-artiq-board.nix} $out/conda-artiq-board.nix
    cp ${./artiq-full/extras.nix} $out/extras.nix

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
      artiq-fast = import ./fast { inherit pkgs; };

      target = "kasli";
      variants = [
        "afmaster"
        "afsatellite"
        "berkeley3"
        "csu"
        "femto1"
        "femto2"
        "femto3"
        "freiburg1"
        "griffith"
        "hub"
        "hw"
        "innsbruck2"
        "ist"
        "liaf"
        "luh2"
        "luh3"
        "mikes"
        "mit"
        "mitll3"
        "mitll4master"
        "mitll4satellite"
        "mpik"
        "mpq"
        "nict"
        "nist"
        "nist2"
        "no"
        "npl1"
        "npl2"
        "oklahoma"
        "olomouc"
        "opticlock"
        "oregon"
        "osaka"
        "ptb"
        "ptb3master"
        "ptb3satellite"
        "ptb4"
        "ptb5"
        "ptb6"
        "ptbal"
        "ptbin"
        "purpleberry"
        "qe"
        "qleds"
        "rice"
        "saymamaster"
        "siegen"
        "sydney"
        "uaarhus"
        "ubirmingham"
        "ucsd"
        "ugranada"
        "unlv"
        "ustc2"
        "ustc3"
        "vlbaimaster"
        "vlbaisatellite"
        "wipm"
        "wipm5master"
        "wipm5satellite"
        "wipm6"
      ] ++ (pkgs.lib.lists.optionals (pkgs.lib.strings.versionAtLeast artiq-fast.artiq.version "6.0") [
        "atomionics"
        "bonn1master"
        "bonn1satellite"
        "hw2master"
        "hw2satellite"
        "luh"
        "ptb3master"
        "ptb3satellite"
        "purduemaster"
        "purduesatellite"
        "siom"
        "uamsterdam"
      ]);

      vivado = import ./fast/vivado.nix { inherit pkgs; };
      artiq-board = import ./fast/artiq-board.nix { inherit pkgs vivado; };
      conda-artiq-board = import ./conda-artiq-board.nix { inherit pkgs; };
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
            src = json;
            buildCommand = "python -m artiq.gateware.targets.kasli_generic \$src";
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
      drtio-systems = {
        af = {
          master = "afmaster";
          satellites = {
            "1" = "afsatellite";
          };
        };
        mitll4 = {
          master = "mitll4master";
          satellites = {
            "1" = "mitll4satellite";
          };
        };
        vlbai = {
          master = "vlbaimaster";
          satellites = {
            "1" = "vlbaisatellite";
          };
        };
        wipm5 = {
          master = "wipm5master";
          satellites = {
            "1" = "wipm5satellite";
          };
        };
      } // (pkgs.lib.optionalAttrs (pkgs.lib.strings.versionAtLeast artiq-fast.artiq.version "6.0") {
        bonn1 = {
          master = "bonn1master";
          satellites = {
            "1" = "bonn1satellite";
          };
        };
        hw2 = {
          master = "hw2master";
          satellites = {
            "1" = "hw2satellite";
          };
        };
        ptb3 = {
          master = "ptb3master";
          satellites = {
            "1" = "ptb3satellite";
          };
        };
        purdue = {
          master = "purduemaster";
          satellites = {
            "1" = "purduesatellite";
          };
        };
      });
      drtio-ddbs = pkgs.lib.attrsets.mapAttrs'
        (system: crates: pkgs.lib.attrsets.nameValuePair ("device-db-" + system)
        (pkgs.stdenv.mkDerivation {
          name = "device-db-\''${system}";
          buildInputs = [ artiq-fast.artiq ];
          phases = [ "buildPhase" ];
          buildPhase = "
            mkdir \$out
            artiq_ddb_template \
              \''${pkgs.lib.strings.concatStringsSep " " (pkgs.lib.attrsets.mapAttrsToList (dest: desc: "-s " + dest + " " + src + "/" + desc + ".json") crates.satellites) } \
              \''${src}/\''${crates.master}.json -o \$out/device_db.py
            mkdir \$out/nix-support
            echo file device_db_template \$out/device_db.py >> \$out/nix-support/hydra-build-products
            ";
        })) drtio-systems;
      extras = import ./extras.nix { inherit pkgs; inherit (artiq-fast) sipyco asyncserial artiq; };
    in
      artiq-fast // generic-kasli // drtio-ddbs // extras // rec {
        artiq-board-sayma-rtm = artiq-board {
          target = "sayma";
          variant = "rtm";
          buildCommand = "python -m artiq.gateware.targets.sayma_rtm";
        };
        artiq-board-sayma-satellite = artiq-board {
          target = "sayma";
          variant = "satellite";
          buildCommand = "python -m artiq.gateware.targets.sayma_amc";
        };
        artiq-board-metlino-master = artiq-board {
          target = "metlino";
          variant = "master";
          buildCommand = "python -m artiq.gateware.targets.metlino";
        };
        artiq-board-kc705-nist_qc2 = artiq-board {
          target = "kc705";
          variant = "nist_qc2";
        };

        conda-artiq-board-sayma-rtm = conda-artiq-board {
          target = "sayma";
          variant = "rtm";
          boardBinaries = artiq-board-sayma-rtm;
        };
        conda-artiq-board-sayma-satellite = conda-artiq-board {
          target = "sayma";
          variant = "satellite";
          boardBinaries = artiq-board-sayma-satellite;
        };
        conda-artiq-board-metlino-master = conda-artiq-board {
          target = "metlino";
          variant = "master";
          boardBinaries = artiq-board-metlino-master;
        };
        conda-artiq-board-kasli-tester = conda-artiq-board {
          target = "kasli";
          variant = "tester";
          boardBinaries = artiq-fast.artiq-board-kasli-tester;
        };
        conda-artiq-board-kc705-nist_clock = conda-artiq-board {
          target = "kc705";
          variant = "nist_clock";
          boardBinaries = artiq-fast.artiq-board-kc705-nist_clock;
        };
        conda-artiq-board-kc705-nist_qc2 = conda-artiq-board {
          target = "kc705";
          variant = "nist_qc2";
          boardBinaries = artiq-board-kc705-nist_qc2;
        };
      }
    EOF
    '';
  pythonDeps = import ./artiq-full/python-deps.nix { inherit pkgs; };
  sipycoManualPackages = import ./artiq-full/sipyco-manual.nix {
    inherit (pkgs) stdenv lib python3Packages texlive texinfo;
    inherit (import <artiq-fast> { inherit pkgs; }) sipyco;
  };
  artiqManualPackages = import ./artiq-full/artiq-manual.nix {
    inherit (pkgs) stdenv lib fetchgit git python3Packages texlive texinfo;
    inherit (pythonDeps) sphinxcontrib-wavedrom;
  };
  jobs = (import generatedNix { inherit pkgs; }) // sipycoManualPackages // artiqManualPackages // {
    # This is in the example in the ARTIQ manual - precompile it to speed up
    # installation for users.
    matplotlib-qt = pkgs.lib.hydraJob (pkgs.python3Packages.matplotlib.override { enableQt = true; });
  };
in
  builtins.mapAttrs (key: value: pkgs.lib.hydraJob value) jobs // {
    artiq-full = pkgs.releaseTools.channel {
      name = "artiq-full";
      src = generatedNix;
      constituents = [];
    };
    conda-channel = import ./artiq-full/conda-channel.nix { inherit pkgs; } { inherit jobs; };
  }
