{ pkgs ? import <nixpkgs> {}}:
with pkgs;
let
  artiq6 = pkgs.lib.strings.versionAtLeast mainPackages.artiq.version "6.0";
  pythonDeps = import ./pkgs/python-deps.nix { inherit (pkgs) lib fetchgit fetchFromGitHub python3Packages; misoc-new = artiq6; };

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
      }) {} boards;

  mainPackages = rec {
    inherit (pythonDeps) sipyco asyncserial pythonparser pyqtgraph-qt5 artiq-netboot misoc migen microscope jesd204b migen-axi lit outputcheck qasync;
    binutils-or1k = callPackage ./pkgs/binutils.nix { platform = "or1k"; target = "or1k-linux"; };
    binutils-arm = callPackage ./pkgs/binutils.nix { platform = "arm"; target = "armv7-unknown-linux-gnueabihf"; };
    llvm-or1k = callPackage ./pkgs/llvm-or1k.nix {};
    rustc = callPackage ./pkgs/rust/rustc-with-crates.nix
      ((lib.optionalAttrs (stdenv.cc.isGNU && stdenv.hostPlatform.isi686) {
         stdenv = overrideCC stdenv gcc6; # with gcc-7: undefined reference to `__divmoddi4'
       }) //
       { inherit llvm-or1k; });
    cargo = callPackage ./pkgs/rust/cargo.nix { inherit rustc; rustPlatform = rustPackages_1_45.rustPlatform; };
    cargo-vendor = callPackage ./pkgs/rust/cargo-vendor.nix {};
    llvmlite-artiq = callPackage ./pkgs/llvmlite-artiq.nix { inherit llvm-or1k; };
    libartiq-support = callPackage ./pkgs/libartiq-support.nix { inherit rustc; };
    artiq = callPackage ./pkgs/artiq.nix { inherit pythonDeps binutils-or1k binutils-arm llvm-or1k llvmlite-artiq libartiq-support lit outputcheck; };
    artiq-env = (pkgs.python3.withPackages(ps: [ artiq ])).overrideAttrs (oldAttrs: { name = "${pkgs.python3.name}-artiq-env-${artiq.version}"; });
    openocd = callPackage ./pkgs/openocd.nix { autoreconfHook = pkgs.autoreconfHook269 or pkgs.autoreconfHook; };
  };

  condaNoarch = {
    conda-pythonparser = import ./conda/build.nix { inherit pkgs; } {
      pname = "conda-pythonparser";
      inherit (pythonDeps.pythonparser) version;
      src = import ./conda/fake-source.nix { inherit pkgs; } {
        name = "pythonparser";
        inherit (pythonDeps.pythonparser) version src;
        extraSrcCommands = "patch -p1 < ${./pkgs/pythonparserver.patch}";
        dependencies = ["regex"];
      };
    };
    conda-sipyco = import ./conda/build.nix { inherit pkgs; } {
      pname = "conda-sipyco";
      inherit (pythonDeps.sipyco) version;
      src = import ./conda/fake-source.nix { inherit pkgs; } {
        name = "sipyco";
        inherit (pythonDeps.sipyco) version src;
        dependencies = ["numpy"];
      };
    };
    conda-quamash = import ./conda/build.nix { inherit pkgs; } {
      pname = "conda-quamash";
      inherit (pkgs.python3Packages.quamash) version;
      src = import ./conda/fake-source.nix { inherit pkgs; } {
        name = "quamash";
        inherit (pkgs.python3Packages.quamash) version src;
      };
     };
    conda-qasync = import ./conda/build.nix { inherit pkgs; } {
      pname = "conda-qasync";
      inherit (pythonDeps.qasync) version;
      src = import ./conda/fake-source.nix { inherit pkgs; } {
        name = "qasync";
        inherit (pythonDeps.qasync) version src;
      };
    };
    conda-bscan-spi-bitstreams = import ./conda/bscan-spi-bitstreams.nix {
      inherit pkgs;
      inherit (mainPackages.openocd) bscan_spi_bitstreams;
    };
    conda-artiq = import ./conda/artiq.nix { inherit pkgs; };
    conda-asyncserial = import ./conda/build.nix { inherit pkgs; } {
      pname = "conda-asyncserial";
      inherit (pythonDeps.asyncserial) version;
      src = import ./conda/fake-source.nix { inherit pkgs; } {
        name = "asyncserial";
        inherit (pythonDeps.asyncserial) version src;
        dependencies = ["pyserial"];
      };
    };
  };

  condaLinux = rec {
    conda-binutils-or1k = import ./conda/binutils.nix {
      inherit pkgs;
      inherit (mainPackages.binutils-or1k) version src;
      target = "or1k-linux";
    };
    conda-binutils-arm = import ./conda/binutils.nix {
      inherit pkgs;
      inherit (mainPackages.binutils-arm) version src;
      target = "armv7-unknown-linux-gnueabihf";
    };
    conda-llvm-or1k = import ./conda/llvm-or1k.nix {
      inherit pkgs;
      inherit (mainPackages.llvm-or1k) version;
      src = mainPackages.llvm-or1k.llvm-src;
    };
    conda-llvmlite-artiq = import ./conda/llvmlite-artiq.nix {
      inherit pkgs conda-llvm-or1k;
      inherit (mainPackages.llvmlite-artiq) version src;
    };
  };

  condaWindowsLegacy = {
    conda-windows-binutils-or1k = import ./conda-windows/redistribute.nix {
      inherit pkgs;
      name = "binutils-or1k";
      filename = "binutils-or1k-linux-2.27-h93a10e1_6.tar.bz2";
      baseurl = "https://anaconda.org/m-labs/binutils-or1k-linux/2.27/download/win-64/";
      sha256 = "0gbks36hfsx3893mihj0bdmg5vwccrq5fw8xp9b9xb8p5pr8qhzx";
    };
    conda-windows-llvm-or1k = import ./conda-windows/redistribute.nix {
      inherit pkgs;
      name = "llvm-or1k";
      filename = "llvm-or1k-6.0.0-25.tar.bz2";
      baseurl = "https://anaconda.org/m-labs/llvm-or1k/6.0.0/download/win-64/";
      sha256 = "06mnrg79rn9ni0d5z0x3jzb300nhqhbc2h9qbq5m50x3sgm8km63";
    };
    conda-windows-llvmlite-artiq = import ./conda-windows/redistribute.nix {
      inherit pkgs;
      name = "llvmlite-artiq";
      filename = "llvmlite-artiq-0.23.0.dev-py35_5.tar.bz2";
      baseurl = "https://anaconda.org/m-labs/llvmlite-artiq/0.23.0.dev/download/win-64/";
      sha256 = "10w24w5ljvan06pbvwqj4pzal072jnyynmwm42dn06pq88ryz9wj";
    };
  };

  condaWindowsExperimental = rec {
    conda-windows-binutils-or1k = import ./conda-windows/binutils.nix {
      inherit pkgs;
      inherit (mainPackages.binutils-or1k) version src;
      target = "or1k-linux";
    };
    conda-windows-binutils-arm = import ./conda-windows/binutils.nix {
      inherit pkgs;
      inherit (mainPackages.binutils-or1k) version src;
      target = "armv7-unknown-linux-gnueabihf";
    };
    conda-windows-llvm-or1k = import ./conda-windows/llvm-or1k.nix {
      inherit pkgs;
      inherit (mainPackages.llvm-or1k) version;
      src = mainPackages.llvm-or1k.llvm-src;
    };
    conda-windows-llvmlite-artiq = import ./conda-windows/llvmlite-artiq.nix {
      inherit pkgs conda-windows-llvm-or1k;
      inherit (mainPackages.llvmlite-artiq) version src;
    };
  };

  condaWindows = if artiq6 then condaWindowsExperimental else condaWindowsLegacy;
in
  boardPackages // mainPackages // condaNoarch // condaLinux // condaWindows
