{ pkgs ? import <nixpkgs> {}}:

let
  sinaraSystemsSrc = <sinaraSystemsSrc>;

  generatedNix = pkgs.runCommand "generated-nix" { buildInputs = [ pkgs.nix pkgs.git ]; }
    ''
    mkdir $out
    REV=`git --git-dir ${sinaraSystemsSrc}/.git rev-parse HEAD`
    HASH=`nix-hash --type sha256 --base32 ${sinaraSystemsSrc}`
    cat > $out/default.nix << EOF
    { pkgs ? import <nixpkgs> {}}:

    let
      target = "kasli";
      variants = ["berkeley" "mitll2" "mitll" "nudt" "sysu" "tsinghua2" "tsinghua" "ubirmingham" "unsw" "ustc" "wipm"];

      artiq-board = import <m-labs/artiq-board.nix> { inherit pkgs; };
      conda-artiq-board = import <m-labs/conda-artiq-board.nix> { inherit pkgs; };
      src = pkgs.fetchgit {
        url = "git://github.com/m-labs/sinara-systems.git";
        rev = "$REV";
        sha256 = "$HASH";
        leaveDotGit = true;
      };
    in
      pkgs.lib.lists.foldr (variant: start:
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
         }) {} variants
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
