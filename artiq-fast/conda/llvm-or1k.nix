{ pkgs, version, src }:

let
  fake-src = pkgs.runCommand "conda-fake-source-llvm-or1k" { }
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
      name: llvm-or1k
      version: ${version}

    # Use the nixpkgs cmake to build, so we are less bothered by conda idiocy.

    source:
      url: ../src.tar

    EOF

    cat << EOF > $out/fake-conda/build.sh
    mkdir build
    cd build
    cmake .. \$COMPILER32 \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_PREFIX=\$PREFIX \
      -DLLVM_BUILD_LLVM_DYLIB=ON \
      -DLLVM_LINK_LLVM_DYLIB=ON \
      -DLLVM_TARGETS_TO_BUILD=X86\;ARM \
      -DLLVM_EXPERIMENTAL_TARGETS_TO_BUILD=OR1K \
      -DLLVM_ENABLE_ASSERTIONS=OFF \
      -DLLVM_INSTALL_UTILS=ON \
      -DLLVM_INCLUDE_TESTS=OFF \
      -DLLVM_INCLUDE_DOCS=OFF \
      -DLLVM_INCLUDE_EXAMPLES=OFF
    make -j2
    make install

    EOF
    chmod 755 $out/fake-conda/build.sh
    '';
in
  import ./build.nix { inherit pkgs; } {
    name = "conda-llvm-or1k";
    src = fake-src;
  }
