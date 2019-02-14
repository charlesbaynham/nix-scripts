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
    ${artiqSrc}
    EOF
    '';
  artiqPkgs = import "${generatedNix}/default.nix" { inherit pkgs; };

  boards = [
    { target = "kasli"; variant = "tester"; }
    { target = "kc705"; variant = "nist_clock"; }
  ];
  boardJobs = pkgs.lib.lists.foldr (board: start:
    let
      boardBinaries = import "${generatedNix}/artiq-board.nix" { inherit pkgs; } {
        target = board.target;
        variant = board.variant;
      };
    in
      start // {
        "artiq-board-${board.target}-${board.variant}" = boardBinaries;
        "conda-artiq-board-${board.target}-${board.variant}" = import "${generatedNix}/conda-board.nix" { inherit pkgs; } {
          artiqSrc = import "${generatedNix}/pkgs/artiq-src.nix" { fetchgit = pkgs.fetchgit; };
          boardBinaries = boardBinaries;
          target = board.target;
          variant = board.variant;
      };
  }) {} boards;

  jobs = {
    conda-artiq = import "${generatedNix}/conda-build.nix" { inherit pkgs; } {
      name = "conda-artiq";
      src = import "${generatedNix}/pkgs/artiq-src.nix" { fetchgit = pkgs.fetchgit; };
      recipe = "conda/artiq";
    };
  } // boardJobs // artiqPkgs;
in
  jobs // {
    channel = pkgs.releaseTools.channel {
      name = "main";
      src = ./.;
      constituents = builtins.attrValues jobs;
    };
  }
