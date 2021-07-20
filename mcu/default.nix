{ # Use master branch of the overlay by default
  mozillaOverlay ? import (builtins.fetchTarball https://github.com/mozilla/nixpkgs-mozilla/archive/master.tar.gz),
  rustManifest ? ./channel-rust-nightly.toml
}:

let
  pkgs = import <nixpkgs> { overlays = [ mozillaOverlay ]; };
  rustPlatform = pkgs.recurseIntoAttrs (pkgs.callPackage ./rustPlatform.nix {
    inherit rustManifest;
  });
  buildStm32Firmware = { name, src, cargoDepsName ? name, patchPhase ? "", extraNativeBuildInputs ? [], checkPhase ? "", doCheck ? true, binaryName ? name, extraCargoBuildArgs ? "" }:
    let
      cargoSha256Drv = pkgs.runCommand "${name}-cargosha256" { } ''
        cp "${src}/cargosha256.nix" $out
        '';
    in
      rustPlatform.buildRustPackage rec {
        inherit name cargoDepsName;
        version = "0.0.0";

        inherit src;
        cargoSha256 = (import cargoSha256Drv);

        inherit patchPhase;
        nativeBuildInputs = [ pkgs.llvm ] ++ extraNativeBuildInputs;
        buildPhase = ''
          export CARGO_HOME=$(mktemp -d cargo-home.XXX)
          cargo build --release --bin ${binaryName} ${extraCargoBuildArgs}
        '';

        inherit checkPhase doCheck;
        # binaryName defaults to the `name` arg (i.e. the Rust package name);
        # it is used as the Cargo binary filename
        installPhase = ''
          mkdir -p $out $out/nix-support
          cp target/thumbv7em-none-eabihf/release/${binaryName} $out/${name}.elf
          echo file binary-dist $out/${name}.elf >> $out/nix-support/hydra-build-products
          llvm-objcopy -O binary target/thumbv7em-none-eabihf/release/${binaryName} $out/${name}.bin
          echo file binary-dist $out/${name}.bin >> $out/nix-support/hydra-build-products
        '';

        dontFixup = true;
      };
  migen = (import ../artiq-fast/pkgs/python-deps.nix { inherit (pkgs) lib fetchgit fetchFromGitHub python3Packages; misoc-new = true; }).migen;
in
  pkgs.lib.attrsets.mapAttrs'
    (name: value: pkgs.lib.attrsets.nameValuePair ("stabilizer-" + name)
    (buildStm32Firmware ({
      name = "stabilizer-" + name;
      # If binaryName is not specified, use the attribute name as binaryName by default.
      binaryName = name;
      cargoDepsName = "stabilizer";
      src = <stabilizerSrc>;
      patchPhase = ''
        substituteInPlace src/hardware/configuration.rs \
          --replace "IpAddress::v4(10, 34, 16, 103)" \
                    "IpAddress::v4(192, 168, 1, 76)" \
          --replace "Ipv4Address::new(10, 34, 16, 1)" \
                    "Ipv4Address::new(192, 168, 1, 1)"
      '';
      doCheck = false;
    } // value))) {
      dual-iir = {};
      dual-iir-pounder_v1_1 = {
        binaryName = "dual-iir";
        extraCargoBuildArgs = "--features pounder_v1_1";
      };
      lockin-external = {};
      lockin-external-pounder_v1_1 = {
        binaryName = "lockin-external";
        extraCargoBuildArgs = "--features pounder_v1_1";
      };
      lockin-internal = {};
      lockin-internal-pounder_v1_1 = {
        binaryName = "lockin-internal";
        extraCargoBuildArgs = "--features pounder_v1_1";
      };
    } //
  {
    thermostat = buildStm32Firmware {
      name = "thermostat";
      src = <thermostatSrc>;
      checkPhase = ''
        cargo test --target=${pkgs.rust.toRustTarget pkgs.stdenv.targetPlatform}
      '';
    };
    humpback-dds = buildStm32Firmware {
      name = "humpback-dds";
      src = <humpbackDdsSrc>;
      extraNativeBuildInputs = [
        (pkgs.python3.withPackages(ps: [ migen ]))
        pkgs.yosys
        pkgs.nextpnr
        pkgs.icestorm
      ];
    };
    # openMMC build system breaks if host compiler is not available, so do not use stdenvNoCC here
    sayma-mmc = pkgs.stdenv.mkDerivation {
      name = "sayma-mmc";
      src = <saymaMmcSrc>;
      phases = [ "unpackPhase" "buildPhase" "installPhase" ];
      nativeBuildInputs = [ pkgs.cmake pkgs.gcc-arm-embedded ];
      buildPhase =
        ''
        mkdir build
        cd build
        cmake .. -DBOARD=sayma -DBOARD_RTM=sayma -DVERSION= -DTARGET_CONTROLLER=LPC1776 -DCMAKE_BUILD_TYPE=Debug
        make
        '';
      installPhase =
        ''
        mkdir $out
        cp out/* $out
        mkdir -p $out $out/nix-support
        echo file binary-dist $out/openMMC.axf >> $out/nix-support/hydra-build-products
        echo file binary-dist $out/openMMC.bin >> $out/nix-support/hydra-build-products
        '';
    };
  }
