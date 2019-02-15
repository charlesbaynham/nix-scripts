{ pkgs ? import <nixpkgs> {}}:
{ artiqSrc, boardBinaries, target, variant }:

with pkgs;

let
  fakeCondaSource = runCommand "fake-condasrc-artiq-board-${target}-${variant}" { }
    ''
    cp --no-preserve=mode,ownership -R ${artiqSrc} $out
    mkdir $out/fake-conda;

    cat << EOF > $out/fake-conda/meta.yaml
    package:
      name: artiq-board-${target}-${variant}
      version: 5e.{{ environ["GIT_FULL_HASH"][:8] }}

    source:
      git_url: ..

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
  conda-board = import ./conda-build.nix { inherit pkgs; } {
    name = "conda-artiq-board-${target}-${variant}";
    src = fakeCondaSource;
    recipe = "fake-conda";
  };
in
  conda-board
