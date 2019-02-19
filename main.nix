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
  artiqpkgs = import "${generatedNix}/default.nix" { inherit pkgs; };
  python3pkgs = pkgs.callPackage "${generatedNix}/pkgs/python3Packages.nix" {};
  artiqVersion = import "${generatedNix}/pkgs/artiq-version.nix";
  jobs = builtins.mapAttrs (key: value: pkgs.lib.hydraJob value) artiqpkgs;
in
  jobs // {
    generated-nix = pkgs.lib.hydraJob generatedNix;
    channel = pkgs.releaseTools.channel rec {
      name = "main";
      src = generatedNix;
      constituents = builtins.attrValues jobs;
    };
    docs = pkgs.runCommand "docs"
      {
        buildInputs = [
          (pkgs.python3.withPackages(ps: [python3pkgs.sphinx-argparse python3pkgs.sphinxcontrib-wavedrom ps.sphinx_rtd_theme ps.sphinx]))
        ];
      }
      ''
      mkdir $out
      VERSIONEER_OVERRIDE=${artiqVersion} sphinx-build ${artiqSrc}/doc/manual $out/html
      mkdir $out/nix-support
      echo doc manual $out/html >> $out/nix-support/hydra-build-products
      '';
    extended-tests = pkgs.runCommand "extended-tests" {
      propagatedBuildInputs = [
          (pkgs.python3.withPackages(ps: [artiqpkgs.artiq artiqpkgs.artiq-board-kc705-nist_clock]))
          artiqpkgs.binutils-or1k
          artiqpkgs.openocd
          pkgs.iputils
        ];
    } "cp ${./extended-tests.py} $out;";
  }
