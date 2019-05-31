{ # Use master branch of the overlay by default
  mozillaOverlay ? import (builtins.fetchTarball https://github.com/mozilla/nixpkgs-mozilla/archive/master.tar.gz),
  rustManifest ? builtins.fetchurl "https://static.rust-lang.org/dist/channel-rust-nightly.toml"
}:

let
  pkgs = import <nixpkgs> { overlays = [ mozillaOverlay ]; };
  rustPlatform = pkgs.recurseIntoAttrs (pkgs.callPackage ./rustPlatform.nix {
    inherit rustManifest;
  });
  fetchcargo = import ./fetchcargo.nix {
    inherit (pkgs) stdenv cacert git cargo-vendor;
    inherit (rustPlatform.rust) cargo;
  };
  buildStm32Firmware = { name, src, cargoSha256 }:
    let
      firmwareDeps = fetchcargo { inherit name src; sha256 = cargoSha256; };
    in
      rustPlatform.buildRustPackage rec {
        inherit name;
        version = "0.0.0";

        inherit src cargoSha256;

        buildInputs = [ firmwareDeps ];
        patchPhase = ''
          cat >> .cargo/config <<EOF
          [source.crates-io]
          replace-with = "vendored-sources"

          [source.vendored-sources]
          directory = "${firmwareDeps}"
          EOF
        '';

        buildPhase = ''
          export CARGO_HOME=$(mktemp -d cargo-home.XXX)
          cargo build --release
        '';

        doCheck = false;
        installPhase = ''
          mkdir -p $out $out/nix-support
          cp target/thumbv7em-none-eabihf/release/${name} $out/${name}.elf
          echo file binary-dist ${name}.elf >> $out/nix-support/hydra-build-products
        '';
      };
in
  {
    stabilizer = buildStm32Firmware {
      name = "stabilizer";
      src = /home/sb/stabilizer;
      cargoSha256 = "1m4cxf6c4lh28xv4iagp20ni97cya1f12yg58q0m733qahk8gncb";
    };
    thermostat = buildStm32Firmware {
      name = "thermostat";
      src = /home/sb/thermostat;
      cargoSha256 = "1i9p5d5n01ajbp8lmavyway6vr1mmy107qnccff9glvr91rqx352";
    };
  }
