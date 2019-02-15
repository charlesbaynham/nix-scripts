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
  jobs = builtins.mapAttrs (key: value: pkgs.lib.hydraJob value) artiqpkgs;
in
  jobs // {
    channel = pkgs.releaseTools.channel {
      name = "main";
      src = generatedNix;
      constituents = builtins.attrValues jobs;
    };
  }
