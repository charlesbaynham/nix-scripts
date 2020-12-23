# Install Vivado in /opt and add to /etc/nixos/configuration.nix:
#  nix.sandboxPaths = ["/opt"];

{ pkgs
, vivado ? import ./fast/vivado.nix { inherit pkgs; }
}:

let
  version = import ./fast/pkgs/artiq-version.nix (with pkgs; { inherit stdenv fetchgit git; });
  artiqSrc = import ./fast/pkgs/artiq-src.nix { fetchgit = pkgs.fetchgit; };
  artiqpkgs = import ./fast/default.nix { inherit pkgs; };
  fetchcargo = import ./fast/fetchcargo.nix {
    inherit (pkgs) stdenv cacert git;
    inherit (artiqpkgs) cargo cargo-vendor;
  };
  cargoDeps = fetchcargo rec {
    name = "artiq-firmware-cargo-deps";
    src = "${artiqSrc}/artiq/firmware";
    sha256 = (import "${artiqSrc}/artiq/firmware/cargosha256.nix");
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
in
{ target
, variant
, src ? null
, buildCommand ? "python -m artiq.gateware.targets.${target} -V ${variant}"
, extraInstallCommands ? ""}:
let
  name = "artiq-board-${target}-${variant}-${version}";
  installPath = builtins.unsafeDiscardStringContext "${pkgs.python3Packages.python.sitePackages}/artiq/board-support/${target}-${variant}";
  pythonEnv = pkgs.python3.withPackages (ps: with ps; [
    jinja2 numpy artiqpkgs.migen artiqpkgs.microscope artiqpkgs.misoc artiqpkgs.jesd204b artiqpkgs.artiq
  ]);

  generatedSources =
    pkgs.stdenv.mkDerivation {
      name = "${name}-src";
      inherit version src;
      phases = [ "buildPhase" "installCheckPhase" "installPhase" "checkPhase" ];
      buildInputs = [ pythonEnv ];
      buildPhase =
        ''
        ${buildCommand} --no-compile-software --no-compile-gateware --gateware-identifier-str=unprogrammed
        '';
      installPhase =
        ''
        mkdir -p $out
        cp -ar artiq_${target}/${variant}/{gateware,software} $out
        substituteInPlace $out/software/Makefile \
          --replace /build/artiq_${target}/${variant}/software/ ""
        '';
    };
  # Board packages are Python modules so that they get added to the ARTIQ Python
  # environment, and artiq_flash finds them.
  software =
    pkgs.stdenv.mkDerivation {
      name = "${name}-software";
      src = generatedSources;
      nativeBuildInputs = [
        pkgs.gnumake pkgs.which pythonEnv
        artiqpkgs.cargo
        artiqpkgs.rustc
        artiqpkgs.binutils-or1k
        artiqpkgs.llvm-or1k
      ];
      buildPhase =
        ''
        export CARGO_HOME=${cargoVendored}
        export TARGET_AR=or1k-linux-ar

        make BUILDINC_DIRECTORY=`pwd`/include
        '';
      installPhase =
        ''
        TARGET_DIR=$out/${installPath}
        mkdir -p $TARGET_DIR

        if [ -e software/bootloader/bootloader.bin ]
        then cp software/bootloader/bootloader.bin $TARGET_DIR
        fi
        if [ -e software/runtime ]
        then cp software/runtime/runtime.{elf,fbi} $TARGET_DIR
        else cp software/satman/satman.{elf,fbi} $TARGET_DIR
        fi
        ${extraInstallCommands}
        '';
      # don't mangle ELF files as they are not for NixOS
      dontFixup = true;
    };

  identifierStr = "${version};${variant}";
  identifiers = import (
    pkgs.runCommandLocal "${name}-identifiers.nix" {
      buildInputs = [ pkgs.python3 ];
    } ''python ${./generate-identifier.py} "${identifierStr}" > $out''
  );

  vivadoInputArchive = pkgs.stdenv.mkDerivation {
    name = "${name}-vivado-input.nar.base64";
    buildInputs = [ pkgs.nix ];
    phases = [ "installPhase" ];
    installPhase = "nix-store --dump ${generatedSources}/gateware | base64 -w0 > $out";
  };

  # Funnelling the source code through a Nix string allows dropping
  # all dependencies via `unsafeDiscardStringContext`. The gateware
  # will then be rebuilt only when these contents have changed.
  pureVivadoInputArchive = builtins.toFile "${name}-vivado-input.nar.base64" (
    builtins.unsafeDiscardStringContext (
      builtins.readFile vivadoInputArchive
    ));

  # Depends on just Vivado and the generated Bitstream source
  vivadoCheckpoint = pkgs.stdenvNoCC.mkDerivation {
    name = builtins.unsafeDiscardStringContext "${name}-vivado-checkpoint";

    unpackPhase = "base64 -d < ${pureVivadoInputArchive} | nix-store --restore gateware";
    buildInputs = [ vivado pkgs.nix ];
    buildPhase = ''
      cd gateware
      vivado -mode batch -source top_route.tcl
    '';

    installPhase = ''
      mkdir -p $out

      chmod a+r top_route.dcp
      cp top_route.dcp $out
      cp top_bitstream.tcl $out
    '';
  };

  vivadoOutput = pkgs.stdenvNoCC.mkDerivation {
    name = builtins.unsafeDiscardStringContext "${name}-vivado-output";
    src = vivadoCheckpoint;
    buildInputs = [ vivado ];
    buildPhase =
      ''
      cat >top.tcl <<EOF
      open_checkpoint top_route.dcp
      '' +
      (pkgs.lib.concatMapStrings ({ cell, init }:
        ''
        set_property INIT ${init} [get_cell ${cell}]
        ''
      ) identifiers) +
      ''
      source "top_bitstream.tcl"
      EOF
      vivado -mode batch -source top.tcl
      '';
    installPhase = ''
      TARGET_DIR=$out/${installPath}
      mkdir -p $TARGET_DIR
      chmod a+r top.bit
      cp top.bit $TARGET_DIR/
    '';

    # temporarily disabled because there is currently always at least one Kasli bitstream
    # that fails timing and blocks the conda channel.
    doCheck = false;
    checkPhase = ''
      # Search for PCREs in the Vivado output to check for errors
      check_log() {
        set +e
        grep -Pe "$1" vivado.log
        FOUND=$?
        set -e
        if [ $FOUND != 1 ]; then
          exit 1
        fi
      }
      check_log "\d+ constraint not met\."
      check_log "Timing constraints are not met\."
    '';
  };
in
pkgs.python3Packages.toPythonModule (
  pkgs.buildEnv rec {
    inherit name;
    paths = [ software vivadoOutput ];
    pathsToLink = [ "/${installPath}" ];
  })
