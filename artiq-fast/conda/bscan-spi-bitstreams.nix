{ pkgs, bscan_spi_bitstreams }:

let
  src = pkgs.runCommand "conda-fake-source-bscan_spi_bitstreams" { }
    ''
    mkdir -p $out/fake-conda;

    # work around yet more idiotic conda behavior - build breaks if write permissions aren't set on source files.
    cp --no-preserve=mode,ownership -L -R ${bscan_spi_bitstreams} workaround-conda
    pushd workaround-conda
    tar cf $out/src.tar .
    popd
    rm -rf workaround-conda

    cat << EOF > $out/fake-conda/meta.yaml
    package:
      name: bscan-spi-bitstreams
      version: "0.10.0"

    source:
      url: ../src.tar

    build:
      noarch: generic
      binary_relocation: false
      script:
        - "mkdir -p \$PREFIX/share/bscan-spi-bitstreams"
        - "cp *.bit \$PREFIX/share/bscan-spi-bitstreams"

    EOF
    '';
in
  import ./build.nix { inherit pkgs; } {
    name = "conda-bscan_spi_bitstreams";
    inherit src;
  }
