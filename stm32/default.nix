{ # Use master branch of the overlay by default
  mozillaOverlay ? import (builtins.fetchTarball https://github.com/mozilla/nixpkgs-mozilla/archive/master.tar.gz),
  rustManifest ? ./channel-rust-nightly.toml
}:

let
  pkgs = import <nixpkgs> { overlays = [ mozillaOverlay ]; };
  rustPlatform = pkgs.recurseIntoAttrs (pkgs.callPackage ./rustPlatform.nix {
    inherit rustManifest;
  });
  buildStm32Firmware = { name, src, patchPhase ? "", checkPhase ? "" }:
    let
      cargoSha256Drv = pkgs.runCommand "${name}-cargosha256" { } ''cp "${src}/cargosha256.nix" $out'';
    in
      rustPlatform.buildRustPackage rec {
        inherit name;
        version = "0.0.0";

        inherit src;
        cargoSha256 = (import cargoSha256Drv);

        inherit patchPhase;
        buildInputs = [ pkgs.llvm ];
        buildPhase = ''
          export CARGO_HOME=$(mktemp -d cargo-home.XXX)
          cargo build --release
        '';

        inherit checkPhase;
        installPhase = ''
          mkdir -p $out $out/nix-support
          cp target/thumbv7em-none-eabihf/release/${name} $out/${name}.elf
          echo file binary-dist $out/${name}.elf >> $out/nix-support/hydra-build-products
          llvm-objcopy -O binary target/thumbv7em-none-eabihf/release/${name} $out/${name}.bin
          echo file binary-dist $out/${name}.bin >> $out/nix-support/hydra-build-products
        '';
      };
in
  {
    stabilizer = buildStm32Firmware {
      name = "stabilizer";
      src = <stabilizerSrc>;
      patchPhase = ''
        substituteInPlace src/main.rs \
          --replace "net::wire::IpAddress::v4(10, 0, 16, 99)," \
                    "net::wire::IpAddress::v4(192, 168, 1, 76),"
      '';
    };
    thermostat = buildStm32Firmware {
      name = "thermostat";
      src = <thermostatSrc>;
      checkPhase = ''
        cargo test --target=${pkgs.rust.toRustTarget pkgs.stdenv.targetPlatform}
      '';
    };
  }
