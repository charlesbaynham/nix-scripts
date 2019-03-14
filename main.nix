{ pkgs ? import <nixpkgs> {}}:
let
  artiqSrc = <artiqSrc>;
  generatedNix = pkgs.runCommand "generated-nix" { buildInputs = [ pkgs.nix pkgs.git ]; }
    ''
    cp --no-preserve=mode,ownership -R ${./artiq} $out
    REV=`git --git-dir ${artiqSrc}/.git rev-parse HEAD`
    HASH=`nix-hash --type sha256 --base32 ${artiqSrc}`
    cat > $out/pkgs/artiq-src.nix << EOF
    { fetchgit }:
    fetchgit {
      url = "git://github.com/m-labs/artiq.git";
      rev = "$REV";
      sha256 = "$HASH";
      leaveDotGit = true;
    }
    EOF
    echo \"5e.`cut -c1-8 <<< $REV`\" > $out/pkgs/artiq-version.nix
    '';
  generateTestOkHash = pkgs.runCommand "generate-test-ok-hash" { buildInputs = [ pkgs.nix ]; }
    ''
    TMPDIR=`mktemp -d`
    cp ${generatedNix}/pkgs/artiq-version.nix $TMPDIR/passed
    HASH=`nix-hash --type sha256 --base32 $TMPDIR`
    echo \"$HASH\" > $out
    '';
  artiqpkgs = import "${generatedNix}/default.nix" { inherit pkgs; };
  artiqVersion = import "${generatedNix}/pkgs/artiq-version.nix";
  jobs = builtins.mapAttrs (key: value: pkgs.lib.hydraJob value) artiqpkgs;
in
  jobs // {
    generated-nix = pkgs.lib.hydraJob generatedNix;  # used by sinara-systems
    channel = pkgs.releaseTools.channel rec {
      name = "main";
      src = generatedNix;
      constituents = builtins.attrValues jobs;
    };

    # HACK: Abuse fixed-output derivations to escape the sandbox and run the hardware
    # unit tests, all integrated in the Hydra interface.
    # One major downside of this hack is the tests are only run when generateTestOkHash
    # changes, i.e. when the ARTIQ version changes (and not the dependencies).
    # Impure derivations, when they land in Nix/Hydra, should improve the situation.
    kc705-tests = pkgs.stdenv.mkDerivation {
      name = "kc705-tests";
      outputHashAlgo = "sha256";
      outputHashMode = "recursive";
      outputHash = import generateTestOkHash;
      buildInputs = [
        (pkgs.python3.withPackages(ps: [ ps.paramiko artiqpkgs.artiq artiqpkgs.artiq-board-kc705-nist_clock ]))
        artiqpkgs.binutils-or1k
        artiqpkgs.openocd
        pkgs.iputils
      ];
      phases = [ "buildPhase" ];
      buildPhase =
      ''
      # set HOME to make SSH private key accessible
      export HOME=/home/hydra-queue-runner
      echo XXX listing
      ls ~/.ssh
      artiq_flash -t kc705 -H rpi
      sleep 15
      # ping: socket: Operation not permitted
      #ping kc705-1 -c10 -w30
      export ARTIQ_ROOT=`python -c "import artiq; print(artiq.__path__[0])"`/examples/kc705_nist_clock",
      export ARTIQ_LOW_LATENCY=1
      python -m unittest discover -v artiq.test.coredevice
      mkdir $out
      cp ${generatedNix}/pkgs/artiq-version.nix $out/passed
      '';
    };
  }
