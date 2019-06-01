{ # Use master branch of the overlay by default
  mozillaOverlay ? import (builtins.fetchTarball https://github.com/mozilla/nixpkgs-mozilla/archive/master.tar.gz),
  rustManifest ? builtins.fetchurl "https://static.rust-lang.org/dist/channel-rust-nightly.toml"
}:

let
  pkgs = import <nixpkgs> { overlays = [ mozillaOverlay ]; };
  rustPlatform = pkgs.recurseIntoAttrs (pkgs.callPackage ./rustPlatform.nix {
    inherit rustManifest;
  });
  buildStm32Firmware = { name, src, cargoSha256 }:
    rustPlatform.buildRustPackage rec {
      inherit name;
      version = "0.0.0";

      inherit src cargoSha256;

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
      src = <stabilizerSrc>;
      cargoSha256 = "184pr64z71h5wi0n9k2ddjyzklbg1cw5vly4ppgck2q6zlb3qbm4";
    };
    thermostat = buildStm32Firmware {
      name = "thermostat";
      src = <thermostatSrc>;
      cargoSha256 = "1i9p5d5n01ajbp8lmavyway6vr1mmy107qnccff9glvr91rqx352";
    };
  }
