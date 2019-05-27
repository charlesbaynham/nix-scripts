# Install Vivado in /opt and add to /etc/nixos/configuration.nix:
#  nix.sandboxPaths = ["/opt"];

{ pkgs }:
{ target
, variant
, buildCommand ? "python -m artiq.gateware.targets.${target} -V ${variant}"
, extraInstallCommands ? ""}:

let
  fetchcargo = import ./fetchcargo.nix {
    inherit (pkgs) stdenv cacert git cargo cargo-vendor;
  };
  artiqSrc = import ./pkgs/artiq-src.nix { fetchgit = pkgs.fetchgit; };
  cargoDeps = fetchcargo rec {
    name = "artiq-firmware-cargo-deps";
    src = "${artiqSrc}/artiq/firmware";
    sha256 = "1xzjn9i4rkd9124v2gbdplsgsvp1hlx7czdgc58n316vsnrkbr86";
  };

  cargoVendored = pkgs.stdenv.mkDerivation {
    name = "artiq-firmware-cargo-vendored";
    src = cargoDeps;
    phases = [ "unpackPhase" "installPhase" ];
    installPhase =
      ''
      mkdir -p $out/registry
      cat << EOF > $out/config
        [source.crates-io]
        registry = "https://github.com/rust-lang/crates.io-index"
        replace-with = "vendored-sources"

        [source."https://github.com/m-labs/libfringe"]
        git = "https://github.com/m-labs/libfringe"
        rev = "b8a6d8f"
        replace-with = "vendored-sources"

        [source.vendored-sources]
        directory = "$out/registry"
      EOF
      cp -R * $out/registry
      '';
  };

  buildenv = import ./artiq-dev.nix { inherit pkgs; };

in pkgs.python3Packages.buildPythonPackage rec {
  name = "artiq-board-${target}-${variant}-${version}";
  version = import ./pkgs/artiq-version.nix (with pkgs; { inherit stdenv fetchgit git; });
  phases = [ "buildPhase" "installCheckPhase" "installPhase" ];
  buildPhase = 
    ''
    ${buildenv}/bin/artiq-dev -c "export CARGO_HOME=${cargoVendored}; ${buildCommand}"
    '';
  checkPhase = ''
    # Search for PCREs in the Vivado output to check for errors
    check_log() {
      set +e
      grep -Pe "$1" artiq_${target}/${variant}/gateware/vivado.log
      FOUND=$?
      set -e
      if [ $FOUND != 1 ]; then
        exit 1
      fi
    }
    check_log "\d+ constraint not met\."
    check_log "Timing constraints are not met\."
    '';
  installPhase =
    ''
    TARGET_DIR=$out/${pkgs.python3Packages.python.sitePackages}/artiq/board-support/${target}-${variant}
    mkdir -p $TARGET_DIR
    cp artiq_${target}/${variant}/gateware/top.bit $TARGET_DIR
    cp artiq_${target}/${variant}/software/bootloader/bootloader.bin $TARGET_DIR
    if [ -e artiq_${target}/${variant}/software/runtime ]
    then cp artiq_${target}/${variant}/software/runtime/runtime.{elf,fbi} $TARGET_DIR
    else cp artiq_${target}/${variant}/software/satman/satman.{elf,fbi} $TARGET_DIR
    fi
    ${extraInstallCommands}
    '';
}
