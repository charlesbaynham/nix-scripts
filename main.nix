{ pkgs ? import <nixpkgs> {}}:
let
  artiqSrc = builtins.toString <artiqSrc>;
  generatedNix = pkgs.runCommand "generated-nix" { }
    ''
    cp --no-preserve=mode,ownership -R ${./artiq} $out
    echo ${artiqSrc} > $out/pkgs/artiq-src.nix
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
          artiqSrc = import "${generatedNix}/pkgs/artiq-src.nix";
          boardBinaries = boardBinaries;
          target = board.target;
          variant = board.variant;
      };
  }) {} boards;

  jobs = {
    conda-artiq = import "${generatedNix}/conda-build.nix" { inherit pkgs; } {
      name = "conda-artiq";
      src = import "${generatedNix}/pkgs/artiq-src.nix";
      recipe = "conda/artiq";
    };
  } // boardJobs // artiqPkgs;
in
  jobs // {
    channel = pkgs.releaseTools.channel {
      name = "main";
      src = "${generatedNix}";
      constituents = builtins.attrValues jobs;
    };
  }
