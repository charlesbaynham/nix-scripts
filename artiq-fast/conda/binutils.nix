{ pkgs, version, src, target }:

let
  fake-src = pkgs.runCommand "conda-fake-source-binutils-${target}" { }
    ''
    mkdir -p $out/fake-conda;

    cat << EOF > $out/fake-conda/meta.yaml
    package:
      name: binutils-${target}
      version: ${version}

    source:
      url: ${src}

    # Note: libiconv is also a build dependency, but the conda garbage won't find it
    # if installed from a file (even if it shows up in conda list), as is the case 
    # when using this script.
    requirements:
      run:
        - libiconv

    EOF

    cat << EOF > $out/fake-conda/build.sh
    #!/bin/bash
    set -e

    mkdir build
    cd build
    ../configure --target=${target} --prefix=\$PREFIX
    make
    make install

    # this is a copy of prefixed executables
    rm -rf $PREFIX/${target}

    EOF
    chmod 755 $out/fake-conda/build.sh
    '';
in
  import ./build.nix { inherit pkgs; } {
    name = "conda-binutils-${target}";
    src = fake-src;
  }
