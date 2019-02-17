{ pkgs }:

with pkgs;

let
  artiqSrc = import ./pkgs/artiq-src.nix { inherit fetchgit; };
  version = import ./pkgs/artiq-version.nix;
  fakeCondaSource = runCommand "fake-condasrc-artiq" { }
    ''
    mkdir -p $out/fake-conda;

    # work around yet more idiotic conda behavior - build breaks if write permissions aren't set on source files.
    cp --no-preserve=mode,ownership -R ${artiqSrc} workaround-conda
    pushd workaround-conda
    tar cf $out/src.tar .
    popd
    rm -rf workaround-conda

    cat << EOF > $out/fake-conda/meta.yaml
    package:
      name: artiq
      version: ${version}

    source:
      url: ../src.tar

    {% set data = load_setup_py_data() %}

    build:
      noarch: python
      entry_points:
        # NOTE: conda-build cannot distinguish between console and gui scripts
        {% for entry_point_type, entry_points in data.get("entry_points", dict()).items() -%}
        {% for entry_point in entry_points -%}
        - {{ entry_point }}
        {% endfor %}
        {% endfor %}
      ignore_prefix_files: True

    requirements:
      run:
        - python >=3.5.3,<3.6
        - llvmlite-artiq 0.23.0.dev py35_5
        - binutils-or1k-linux >=2.27
        - pythonparser >=1.1
        - openocd 0.10.0 6
        - lit
        - outputcheck
        - scipy
        - numpy
        - prettytable
        - asyncserial
        - h5py 2.8
        - python-dateutil
        - pyqt >=5.5
        - quamash
        - pyqtgraph 0.10.0
        - pygit2
        - aiohttp >=3
        - levenshtein

    about:
      home: https://m-labs.hk/artiq
      license: LGPL
      summary: 'A leading-edge control system for quantum information experiments'
    EOF

    cat << EOF > $out/fake-conda/build.sh
    #!/bin/bash
    set -e

    export VERSIONEER_OVERRIDE=${version}
    python setup.py install \
      --prefix=\$PREFIX \
      --single-version-externally-managed \
      --record=record.txt \
      --no-compile

    EOF
    chmod 755 $out/fake-conda/build.sh
    '';
  conda-artiq = import ./conda-build.nix { inherit pkgs; } {
    name = "conda-artiq";
    src = fakeCondaSource;
    recipe = "fake-conda";
  };
in
  conda-artiq
