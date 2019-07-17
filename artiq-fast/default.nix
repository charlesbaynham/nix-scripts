{ pkgs ? import <nixpkgs> {}}:
with pkgs;
let
  pythonDeps = callPackage ./pkgs/python-deps.nix {};

  boards = [
    { target = "kasli"; variant = "tester"; }
    { target = "kc705"; variant = "nist_clock"; }
  ];
  boardPackages = pkgs.lib.lists.foldr (board: start:
    let
      boardBinaries = import ./artiq-board.nix { inherit pkgs; } {
        target = board.target;
        variant = board.variant;
      };
    in
      start // {
        "artiq-board-${board.target}-${board.variant}" = boardBinaries;
        "conda-artiq-board-${board.target}-${board.variant}" = import ./conda-artiq-board.nix { inherit pkgs; } {
          target = board.target;
          variant = board.variant;
          boardBinaries = boardBinaries;
        };
      }) {} boards;
  manualPackages = import ./pkgs/artiq-manual.nix {
    inherit stdenv lib fetchgit git python3Packages texlive texinfo;
    inherit (pythonDeps) sphinxcontrib-wavedrom;
  };
  mainPackages = rec {
    inherit (pythonDeps) asyncserial levenshtein pythonparser quamash pyqtgraph-qt5 misoc migen microscope jesd204b lit outputcheck wavedrom sphinxcontrib-wavedrom;
    binutils-or1k = callPackage ./pkgs/binutils-or1k.nix {};
    llvm-or1k = callPackage ./pkgs/llvm-or1k.nix {};
    rustc = callPackage ./pkgs/rust
      ((stdenv.lib.optionalAttrs (stdenv.cc.isGNU && stdenv.hostPlatform.isi686) {
         stdenv = overrideCC stdenv gcc6; # with gcc-7: undefined reference to `__divmoddi4'
       }) //
       { inherit llvm-or1k; });
    llvmlite-artiq = callPackage ./pkgs/llvmlite-artiq.nix { inherit llvm-or1k; };
    libartiq-support = callPackage ./pkgs/libartiq-support.nix { inherit rustc; };
    artiq = callPackage ./pkgs/artiq.nix { inherit binutils-or1k llvm-or1k llvmlite-artiq libartiq-support lit outputcheck; };
    artiq-env = (pkgs.python3.withPackages(ps: [ artiq ])).overrideAttrs (oldAttrs: { name = "${pkgs.python3.name}-artiq-env-${artiq.version}"; });
    openocd = callPackage ./pkgs/openocd.nix {};
    conda-artiq = import ./conda-artiq.nix { inherit pkgs; };
  } // boardPackages // manualPackages;
  extraPackages = import ./artiq-extras.nix { inherit pkgs; inherit (mainPackages) asyncserial artiq; };
in
  mainPackages // extraPackages