{ pkgs ? import <nixpkgs> {}}:

let
  artiq-board = import <mainChannel/artiq-board.nix> { inherit pkgs; };
  conda-artiq-board = import <mainChannel/conda-artiq-board.nix> { inherit pkgs; };

  target = "kasli";

  variants = ["berkeley" "mitll2" "mitll" "nudt" "sysu" "tsinghua2" "tsinghua" "unsw" "ustc" "wipm"];
  sinaraSystemsPkgs = pkgs.lib.lists.foldr (variant: start:
    let
      json = <sinaraSystemsSrc> + "/${variant}.json";
      boardBinaries = conda-artiq-board {
        inherit target variant;
        buildCommand = "python -m artiq.gateware.targets.kasli_generic ${json}";
      };
    in
      start // {
        "artiq-board-${target}-${variant}" = boardBinaries;
        "conda-artiq-board-${target}-${variant}" = conda-artiq-board {
          boardBinaries = boardBinaries;
          inherit target variant;
      };
     }) {} variants;
  jobs = builtins.mapAttrs (key: value: pkgs.lib.hydraJob value) sinaraSystemsPkgs;
in
  jobs
