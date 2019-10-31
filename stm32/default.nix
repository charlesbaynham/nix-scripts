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
        echo file binary-dist $out/${name}.elf >> $out/nix-support/hydra-build-products
      '';
    };
in
  {
    stabilizer = buildStm32Firmware {
      name = "stabilizer";
      src = <stabilizerSrc>;
      cargoSha256 = "0mf9bcp88riaszpwv6adgpaxyngpacycwfix45fcgvr3lb7mnl22";
    };
    thermostat = buildStm32Firmware {
      name = "thermostat";
      src = <thermostatSrc>;
      cargoSha256 = "08kk6ja9g4j4apa02n02gxpjm62s27aabx33lg0dmzxgr1v5xlr1";
    };
  }
