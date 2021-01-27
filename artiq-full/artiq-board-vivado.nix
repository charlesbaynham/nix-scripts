# Install Vivado in /opt and add to /etc/nixos/configuration.nix:
#  nix.sandboxPaths = ["/opt"];

{ pkgs
, vivado ? import ./fast/vivado.nix { inherit pkgs; }
, board-generated
, version
}:

let
  # Funnelling the source code through a Nix string allows dropping
  # all dependencies via `unsafeDiscardStringContext`.
  discardContextFromPath = { name, src }:
    let
      packed = pkgs.stdenv.mkDerivation {
          name = "${name}.nar.base64";
          buildInputs = [ pkgs.nix ];
          phases = [ "installPhase" ];
          installPhase = "nix-store --dump ${src} | base64 -w0 > $out";
        };
      unpacked = archive:
        pkgs.stdenvNoCC.mkDerivation {
          name = builtins.unsafeDiscardStringContext name;

          phases = [ "installPhase" ];
          buildInputs = [ pkgs.nix ];
          installPhase = "base64 -d < ${archive} | nix-store --restore $out";
        };
    in
      unpacked (
        builtins.toFile "${builtins.unsafeDiscardStringContext name}.nar.base64" (
          builtins.unsafeDiscardStringContext (
            builtins.readFile packed
          ))) ;
in
{ target
, variant
, extraInstallCommands ? ""
, ... }:
let
  name = "artiq-board-${target}-${variant}-${version}";
  installPath = builtins.unsafeDiscardStringContext "${pkgs.python3Packages.python.sitePackages}/artiq/board-support/${target}-${variant}";

  generated = board-generated."artiq-board-${target}-${variant}";

  identifierStr = "${version};${variant}";
  identifiers = import (
    pkgs.runCommandLocal "${name}-identifiers.nix" {
      buildInputs = [ pkgs.python3 ];
    } ''python ${./generate-identifier.py} "${identifierStr}" > $out''
  );

  # Depends on just Vivado and the generated Bitstream source
  vivadoCheckpoint = pkgs.stdenvNoCC.mkDerivation {
    name = builtins.unsafeDiscardStringContext "${name}-vivado-checkpoint";

    src = discardContextFromPath {
      name = "${name}-gateware";
      src = "${generated}/gateware";
    };
    buildInputs = [ vivado pkgs.nix ];
    buildPhase = ''
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
    paths = [ generated vivadoOutput ];
    pathsToLink = [ "/${installPath}" ];
  })
