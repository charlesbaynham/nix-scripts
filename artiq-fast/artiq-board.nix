# Install Vivado in /opt and add to /etc/nixos/configuration.nix:
#  nix.sandboxPaths = ["/opt"];

{ pkgs
, vivado ? import ./vivado.nix { inherit pkgs; }
}:

let
  artiqSrc = import ./pkgs/artiq-src.nix { fetchgit = pkgs.fetchgit; };
  artiqpkgs = import ./default.nix { inherit pkgs; };
  fetchcargo = import ./fetchcargo.nix {
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

# Board packages are Python modules so that they get added to the ARTIQ Python
# environment, and artiq_flash finds them.
pkgs.python3Packages.toPythonModule (pkgs.stdenv.mkDerivation rec {
  name = "artiq-board-${target}-${variant}-${version}";
  version = import ./pkgs/artiq-version.nix (with pkgs; { inherit stdenv fetchgit git; });
  inherit src;
  phases = [ "buildPhase" "installCheckPhase" "installPhase" "checkPhase" ];
  nativeBuildInputs = [
    vivado
    pkgs.gnumake
    artiqpkgs.cargo
    artiqpkgs.rustc
    artiqpkgs.binutils-or1k
    artiqpkgs.llvm-or1k
  ];
  buildInputs =
    [ (pkgs.python3.withPackages (ps: with ps; [
    jinja2 numpy artiqpkgs.migen artiqpkgs.microscope artiqpkgs.misoc artiqpkgs.jesd204b artiqpkgs.artiq
  ])) ];
  buildPhase = 
    ''
    export CARGO_HOME=${cargoVendored}
    export TARGET_AR=or1k-linux-ar
    ${buildCommand}
    '';
  # temporarily disabled because there is currently always at least one Kasli bitstream
  # that fails timing and blocks the conda channel.
  doCheck = false;
  checkPhase = ''
    # Search for PCREs in the Vivado output to check for errors
    check_log() {
      grep -Pe "$1" artiq_${target}/${variant}/gateware/vivado.log && exit 1 || true
    }
    check_log "\d+ constraint not met\."
    check_log "Timing constraints are not met\."
    '';
  installPhase =
    ''
    TARGET_DIR=$out/${pkgs.python3Packages.python.sitePackages}/artiq/board-support/${target}-${variant}
    mkdir -p $TARGET_DIR
    cp artiq_${target}/${variant}/gateware/top.bit $TARGET_DIR
    if [ -e artiq_${target}/${variant}/software/bootloader/bootloader.bin ]
    then cp artiq_${target}/${variant}/software/bootloader/bootloader.bin $TARGET_DIR
    fi
    if [ -e artiq_${target}/${variant}/software/runtime ]
    then cp artiq_${target}/${variant}/software/runtime/runtime.{elf,fbi} $TARGET_DIR
    else cp artiq_${target}/${variant}/software/satman/satman.{elf,fbi} $TARGET_DIR
    fi
    ${extraInstallCommands}
    '';
})
