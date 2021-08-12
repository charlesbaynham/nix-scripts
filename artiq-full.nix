{ pkgs ? import <nixpkgs> {}
, a6p ? <a6p>
}:

let
  sinaraSystemsRev = builtins.readFile <artiq-board-generated/sinara-rev.txt>;
  sinaraSystemsHash = builtins.readFile <artiq-board-generated/sinara-hash.txt>;
  sinaraSystemsSrc =
    if a6p
    then pkgs.fetchgit {
      url = "https://git.m-labs.hk/M-Labs/sinara-systems.git";
      rev = sinaraSystemsRev;
      sha256 = sinaraSystemsHash;
    }
    else <sinaraSystemsSrc>;
  artiq-fast =
    if a6p
    then <artiq-board-generated/fast>
    else <artiq-fast>;
  artiqVersion = import (artiq-fast + "/pkgs/artiq-version.nix") {
    inherit (pkgs) stdenv git fetchgit;
  };
  targets = import ./artiq-full/artiq-targets.nix {
    inherit pkgs artiqVersion sinaraSystemsSrc;
  };
  kasliVariants = map ({ variant, ... }: variant) (
    builtins.filter ({ target, ... }: target == "kasli") (
      builtins.attrValues targets
    )
  );
  standaloneVariants = map ({ variant, ... }: variant) (
    builtins.filter ({ target, standalone ? false, ... }: target == "kasli" && standalone) (
      builtins.attrValues targets
    )
  );
  serializedTargets = pkgs.lib.generators.toPretty {} (
    map (conf:
      if conf ? buildCommand
      then conf // {
        buildCommand = builtins.replaceStrings ["$"] ["\\\\\\$"]  conf.buildCommand;
      }
      else conf
    ) (builtins.attrValues targets)
  );

  generatedNix = pkgs.runCommand "generated-nix" { buildInputs = [ pkgs.nix pkgs.git ]; }
    ''
    mkdir $out

    ${if a6p
      then ''
        cp -a ${<artiq-board-generated>} $out/board-generated
        ln -s board-generated/fast $out/fast
      ''
      else "cp -a ${<artiq-fast>} $out/fast"}
    cp ${./artiq-full}/artiq-board-vivado.nix $out
    cp ${./artiq-full}/generate-identifier.py $out
    cp ${./artiq-full}/conda-artiq-board.nix $out
    cp ${./artiq-full}/extras.nix $out
    cp ${./artiq-full}/*.patch $out

    ${if a6p
      then ''
        REV=${sinaraSystemsRev}
        HASH=${sinaraSystemsHash}
      ''
      else ''
        REV=`git --git-dir ${sinaraSystemsSrc}/.git rev-parse HEAD`
        SINARA_SRC_CLEAN=`mktemp -d`
        cp -a ${sinaraSystemsSrc}/. $SINARA_SRC_CLEAN
        chmod -R 755 $SINARA_SRC_CLEAN/.git
        chmod 755 $SINARA_SRC_CLEAN
        rm -rf $SINARA_SRC_CLEAN/.git
        HASH=`nix-hash --type sha256 --base32 $SINARA_SRC_CLEAN`
      ''}
    cat > $out/default.nix << EOF
    { pkgs ? import <nixpkgs> {}}:

    let
      artiq-fast = import ${if a6p then "./board-generated" else "."}/fast { inherit pkgs; };
      ddbDeps = [
        artiq-fast.artiq
        (pkgs.python3.withPackages (ps: [ ps.jsonschema ]))
      ];

      kasliVariants = [${builtins.concatStringsSep " " (
        builtins.map (variant: "\"${variant}\"") kasliVariants
      )}];
      standaloneVariants = [${builtins.concatStringsSep " " (
        builtins.map (variant: "\"${variant}\"") standaloneVariants
      )}];

      vivado = import ${if a6p then "./board-generated" else "."}/fast/vivado.nix {
        inherit pkgs;
      };
      artiq-board =
        ${if a6p
        then ''
          import ./artiq-board-vivado.nix {
            inherit pkgs vivado;
            version = artiq-fast.artiq.version;
            board-generated = import ./board-generated {
              inherit pkgs;
            };
          }
        ''
        else ''
          import ./fast/artiq-board.nix {
            inherit pkgs vivado;
          }
        ''};
      conda-artiq-board = import ./conda-artiq-board.nix { inherit pkgs; };
      src = pkgs.fetchgit {
        url = "https://git.m-labs.hk/M-Labs/sinara-systems.git";
        rev = "$REV";
        sha256 = "$HASH";
      };
      artiq-targets = pkgs.lib.lists.foldr (conf: start:
        let
          inherit (conf) target variant;
          json = src + "/\''${variant}.json";
          boardBinaries = artiq-board (conf // {
            src = json;
          });
        in
          start // {
            "artiq-board-\''${target}-\''${variant}" = boardBinaries;
            "conda-artiq-board-\''${target}-\''${variant}" = conda-artiq-board {
              boardBinaries = boardBinaries;
              inherit target variant;
            };
          } // (pkgs.lib.optionalAttrs (
            target == "kasli" &&
             builtins.elem variant standaloneVariants
          ) {
            "device-db-\''${target}-\''${variant}" = pkgs.stdenv.mkDerivation {
              name = "device-db-\''${target}-\''${variant}";
              buildInputs = ddbDeps;
              phases = [ "buildPhase" ];
              buildPhase = "
                mkdir \$out
                artiq_ddb_template \''${json} -o \$out/device_db.py
                mkdir \$out/nix-support
                echo file device_db_template \$out/device_db.py >> \$out/nix-support/hydra-build-products
                ";
            };
          })
      ) {} ${serializedTargets};
      drtio-systems = {
        ${pkgs.lib.optionalString a6p ''
          ap = {
            master = "apmaster";
            satellites = {
              "1" = "apsatellite1";
              "2" = "apsatellite2";
            };
          };
          berkeley3 = {
            master = "berkeley3master";
            satellites = {
              "1" = "berkeley3satellite";
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
          stfc = {
            master = "stfcmaster";
            satellites = {
              "1" = "stfcsatellite";
            };
          };
          ubirmingham3 = {
            master = "ubirmingham3master";
            satellites = {
              "1" = "ubirmingham3satellite";
            };
          };
          wipm7 = {
            master = "wipm7master";
            satellites = {
              "1" = "wipm7satellite";
            };
          };
        ''}
      };
      drtio-ddbs = pkgs.lib.attrsets.mapAttrs'
        (system: crates: pkgs.lib.attrsets.nameValuePair ("device-db-" + system)
        (pkgs.stdenv.mkDerivation {
          name = "device-db-\''${system}";
          buildInputs = ddbDeps;
          phases = [ "buildPhase" ];
          buildPhase = "
            mkdir \$out
            artiq_ddb_template \
              \''${pkgs.lib.strings.concatStringsSep " " (pkgs.lib.attrsets.mapAttrsToList (dest: desc: "-s " + dest + " " + (src + "/\''${desc}.json")) crates.satellites) } \
              \''${src}/\''${crates.master}.json -o \$out/device_db.py
            mkdir \$out/nix-support
            echo file device_db_template \$out/device_db.py >> \$out/nix-support/hydra-build-products
            ";
        })) drtio-systems;
      extras = import ./extras.nix { inherit pkgs; inherit (artiq-fast) sipyco asyncserial artiq; };
    in
      artiq-fast // artiq-targets // drtio-ddbs // extras // rec {
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
      }
    EOF
    '';
  pythonDeps = import ./artiq-full/python-deps.nix { inherit pkgs; };
  sipycoManualPackages = import ./artiq-full/sipyco-manual.nix {
    inherit (pkgs) stdenv lib python3Packages texlive texinfo;
    inherit (import artiq-fast { inherit pkgs; }) sipyco;
  };
  artiqManualPackages = import ./artiq-full/artiq-manual.nix {
    inherit (pkgs) stdenv lib fetchgit git python3Packages texlive texinfo;
    inherit (pythonDeps) sphinxcontrib-wavedrom;
    inherit artiq-fast;
  };
  artiq-full = import generatedNix { inherit pkgs; };
  exampleUserEnv = import ./artiq-full/example-user-env.nix { inherit pkgs artiq-full; };
  jobs = artiq-full // sipycoManualPackages // artiqManualPackages // exampleUserEnv;
in
  builtins.mapAttrs (key: value: pkgs.lib.hydraJob value) jobs // {
    artiq-full = pkgs.releaseTools.channel {
      name = "artiq-full";
      src = generatedNix;
      constituents = [];
    };
    conda-channel = import ./artiq-full/conda-channel.nix { inherit pkgs artiq-fast; } { inherit jobs; };
  }
