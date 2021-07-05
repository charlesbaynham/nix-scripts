{ pkgs, conda-llvm-or1k, version, src }:

let
  condaBuilderEnv = import ./builder-env.nix { inherit pkgs; };
  fake-src = pkgs.runCommand "conda-fake-source-llvmlite-artiq" { }
    ''
    mkdir -p $out/fake-conda;

    # work around yet more idiotic conda behavior - build breaks if write permissions aren't set on source files.
    cp --no-preserve=mode,ownership -R ${src} workaround-conda
    pushd workaround-conda
    tar cf $out/src.tar .
    popd
    rm -rf workaround-conda

    cat << EOF > $out/fake-conda/meta.yaml
    package:
      name: llvmlite-artiq
      version: ${version}

    source:
      url: ../src.tar

    # Again, we don't specify build dependencies since the conda garbage mistakenly thinks
    # that they are not there if they have been installed from files.
    requirements:
      run:
        - python<3.9
        - ncurses [linux]
    EOF

    cat << EOF > $out/fake-conda/build.sh
    #!/bin/bash
    set -e

    export LD_LIBRARY_PATH=/lib
    python setup.py install \
      --prefix=\$PREFIX \
      --single-version-externally-managed \
      --record=record.txt \
      --no-compile

    EOF
    chmod 755 $out/fake-conda/build.sh
    '';
in
  pkgs.stdenv.mkDerivation {
    name = "conda-llvmlite-artiq";
    src = fake-src;
    buildCommand =
      ''
      HOME=`pwd`
      mkdir $out
      cat << EOF > conda-commands.sh
      set -e

      conda create --prefix ./conda_tmp ${conda-llvm-or1k}/*/*.tar.bz2
      conda init
      source .bashrc
      conda activate ./conda_tmp

      conda build --no-anaconda-upload --no-test --output-folder $out $src/fake-conda
      EOF
      ${condaBuilderEnv}/bin/conda-builder-env conda-commands.sh

      mkdir -p $out/nix-support
      echo file conda $out/*/*.tar.bz2 >> $out/nix-support/hydra-build-products
      '';
  }
