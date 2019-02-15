{ pkgs }:
{ target, variant, boardBinaries }:

with pkgs;

let
  version = import ./pkgs/artiq-version.nix;
  fakeCondaSource = runCommand "fake-condasrc-artiq-board-${target}-${variant}" { }
    ''
    mkdir -p $out/fake-conda;

    cat << EOF > $out/fake-conda/meta.yaml
    package:
      name: artiq-board-${target}-${variant}
      version: ${version}

    build:
      noarch: python
      ignore_prefix_files: True

    outputs:
      - name: artiq-board-${target}-${variant}
        noarch: python
        files:
          - site-packages
        requirements:
          run:
            - artiq
        ignore_prefix_files: True

    about:
      home: https://m-labs.hk/artiq
      license: LGPL
      summary: 'Bitstream, BIOS and firmware for the ${target}-${variant} board variant'
    EOF

    cat << EOF > $out/fake-conda/build.sh
    #!/bin/bash
    set -e
    SOC_PREFIX=\$PREFIX/site-packages/artiq/binaries/${target}-${variant}
    mkdir -p \$SOC_PREFIX
    cp ${boardBinaries}/${pkgs.python3Packages.python.sitePackages}/artiq/binaries/${target}-${variant}/* \$SOC_PREFIX
    EOF
    chmod 755 $out/fake-conda/build.sh
    '';
  conda-artiq-board = import ./conda-build.nix { inherit pkgs; } {
    name = "conda-artiq-board-${target}-${variant}";
    src = fakeCondaSource;
    recipe = "fake-conda";
  };
in
  conda-artiq-board
