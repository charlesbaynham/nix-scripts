# Install Vivado in /opt and add to /etc/nixos/configuration.nix:
#  nix.sandboxPaths = ["/opt"];

{ pkgs ? import <nixpkgs> {}
, artiq-fast
}:

let
  artiqSrc = import (artiq-fast + "/pkgs/artiq-src.nix") { fetchgit = pkgs.fetchgit; };
  artiqpkgs = import artiq-fast { inherit pkgs; };
  pythonEnv = pkgs.python3.withPackages (ps: with ps; [
    jinja2 jsonschema numpy artiqpkgs.migen artiqpkgs.microscope artiqpkgs.misoc artiqpkgs.jesd204b artiqpkgs.artiq
  ]);
  fetchcargo = import (artiq-fast + "/fetchcargo.nix") {
    inherit (pkgs) stdenv cacert git;
    inherit (artiqpkgs) cargo cargo-vendor;
  };
  cargoDeps = fetchcargo rec {
    name = "artiq-firmware-cargo-deps";
    src = "${artiqSrc}/artiq/firmware";
    sha256 = import (artiqSrc + "/artiq/firmware/cargosha256.nix");
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
, extraInstallCommands ? ""
, ...
}:
let
  name = "artiq-board-${target}-${variant}-${artiqpkgs.artiq.version}-xxx";
  installPath = "${pkgs.python3Packages.python.sitePackages}/artiq/board-support/${target}-${variant}";
in
# Board packages are Python modules so that they get added to the ARTIQ Python
# environment, and artiq_flash finds them.
pkgs.stdenv.mkDerivation {
  name = "artiq-board-${target}-${variant}-${artiqpkgs.artiq.version}";
  inherit src;
  phases = [ "buildPhase" "installPhase" ];
  nativeBuildInputs = [
    pkgs.gnumake pkgs.which pythonEnv
    artiqpkgs.cargo
    artiqpkgs.rustc
    artiqpkgs.binutils-or1k
    artiqpkgs.llvm-or1k
  ];
  buildInputs = [ pythonEnv ];
  buildPhase =
    ''
    export CARGO_HOME=${cargoVendored}
    export TARGET_AR=or1k-linux-ar
    ${buildCommand} --no-compile-gateware --gateware-identifier-str=unprogrammed
    '';
  installPhase =
    ''
    mkdir -p $out
    cp -ar artiq_${target}/${variant}/gateware $out

    TARGET_DIR=$out/${pkgs.python3Packages.python.sitePackages}/artiq/board-support/${target}-${variant}
    mkdir -p $TARGET_DIR
    if [ -e artiq_${target}/${variant}/software/bootloader/bootloader.bin ]
    then cp artiq_${target}/${variant}/software/bootloader/bootloader.bin $TARGET_DIR
    fi
    if [ -e artiq_${target}/${variant}/software/runtime ]
    then cp artiq_${target}/${variant}/software/runtime/runtime.{elf,fbi} $TARGET_DIR
    else cp artiq_${target}/${variant}/software/satman/satman.{elf,fbi} $TARGET_DIR
    fi
    ${extraInstallCommands}
    '';
  # don't mangle ELF files as they are not for NixOS
  dontFixup = true;
}
