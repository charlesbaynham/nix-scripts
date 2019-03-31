{ pkgs ? import <nixpkgs> {}}:
with pkgs;
let
  pythonDeps = callPackage ./pkgs/python-deps.nix {};

  # this code was copied from nipxkgs rev. ffafe9 (nixcloud team) and slightly modified
  rust = callPackage ./pkgs/rust
    (stdenv.lib.optionalAttrs (stdenv.cc.isGNU && stdenv.hostPlatform.isi686) {
      stdenv = overrideCC stdenv gcc6; # with gcc-7: undefined reference to `__divmoddi4'
    });
  llvm-src = callPackage ./fetch-llvm-clang.nix {};

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
    inherit stdenv lib fetchgit python3Packages texlive texinfo;
    inherit (pythonDeps) sphinx-argparse sphinxcontrib-wavedrom;
  };
in
  rec {
    inherit (rust) rustc;
    inherit (pythonDeps) asyncserial levenshtein pythonparser quamash pyqtgraph-qt5 misoc migen microscope jesd204b lit outputcheck sphinx-argparse wavedrom sphinxcontrib-wavedrom;
    binutils-or1k = callPackage ./pkgs/binutils-or1k.nix {};
    llvm-or1k = callPackage ./pkgs/llvm-or1k.nix { inherit llvm-src; };
    llvmlite-artiq = callPackage ./pkgs/llvmlite-artiq.nix { inherit llvm-or1k; };
    libartiq-support = callPackage ./pkgs/libartiq-support.nix { inherit rustc; };
    artiq = callPackage ./pkgs/artiq.nix { inherit binutils-or1k; inherit llvm-or1k; inherit llvmlite-artiq; };
    artiq-env = (pkgs.python3.withPackages(ps: [ artiq ])).overrideAttrs (oldAttrs: { name = "${pkgs.python3.name}-artiq-env-${artiq.version}"; });
    openocd = callPackage ./pkgs/openocd.nix {};
    conda-artiq = import ./conda-artiq.nix { inherit pkgs; };
  } // boardPackages // manualPackages
