{ pkgs, version, src }:

let
  wfvm = import ../../wfvm.nix { inherit pkgs; };
  conda-vs2015_runtime-filename = "vs2015_runtime-14.16.27012-hf0eaf9b_2.tar.bz2";
  conda-vs2015_runtime = pkgs.fetchurl {
    url = "https://anaconda.org/anaconda/vs2015_runtime/14.16.27012/download/win-64/${conda-vs2015_runtime-filename}";
    sha256 = "1gbm6i6nkp8linmak5mm42hj1nzqd5ppak8kv1n3wfn52p21ngvs";
  };
  conda-cmake-filename = "cmake-3.17.2-h33f27b4_0.tar.bz2";
  conda-cmake = pkgs.fetchurl {
    url = "https://anaconda.org/anaconda/cmake/3.17.2/download/win-64/${conda-cmake-filename}";
    sha256 = "0lg782pj2i9h20rwfkwwskis038r98b3z4c9j1a6ih95rc6m2acn";
  };
  build = wfvm.utils.wfvm-run {
    name = "build-llvm-or1k";
    image = wfvm.makeWindowsImage { installCommands = with wfvm.layers; [ anaconda3 msvc msvc-ide-unbreak ]; };
    script = ''
      # Create a fake channel so that the conda garbage doesn't complain about not finding the packages it just installed.
      ln -s ${conda-vs2015_runtime} ${conda-vs2015_runtime-filename}
      ln -s ${conda-cmake} ${conda-cmake-filename}
      ${wfvm.utils.win-exec}/bin/win-exec "mkdir fake-channel && mkdir fake-channel\win-64"
      ${wfvm.utils.win-put}/bin/win-put ${conda-vs2015_runtime-filename} ./fake-channel/win-64
      ${wfvm.utils.win-put}/bin/win-put ${conda-cmake-filename} ./fake-channel/win-64
      ${wfvm.utils.win-exec}/bin/win-exec ".\Anaconda3\scripts\activate && conda index fake-channel"

      cat > meta.yaml << EOF
      package:
        name: llvm-or1k
        version: ${version}

      source:
        url: ../src.tar

      requirements:
        build:
          - cmake
      EOF

      cat > bld.bat << EOF
      set BUILD_TYPE=Release
      set CMAKE_GENERATOR=Visual Studio 15 2017 Win64

      mkdir build
      cd build
      cmake .. -G "%CMAKE_GENERATOR%" ^
        -Thost=x64 ^
        -DCMAKE_BUILD_TYPE="%BUILD_TYPE%" ^
        -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
        -DLLVM_BUILD_LLVM_DYLIB=ON ^
        -DLLVM_TARGETS_TO_BUILD=X86;ARM ^
        -DLLVM_EXPERIMENTAL_TARGETS_TO_BUILD=OR1K ^
        -DLLVM_ENABLE_ASSERTIONS=OFF ^
        -DLLVM_INSTALL_UTILS=ON ^
        -DLLVM_INCLUDE_TESTS=OFF ^
        -DLLVM_INCLUDE_DOCS=OFF ^
        -DLLVM_INCLUDE_EXAMPLES=OFF
      if errorlevel 1 exit 1
      cmake --build . --config "%BUILD_TYPE%" --parallel 4
      if errorlevel 1 exit 1
      cmake --build . --config "%BUILD_TYPE%" --target install
      if errorlevel 1 exit 1
      EOF

      ${wfvm.utils.win-exec}/bin/win-exec "mkdir llvm-or1k"
      ${wfvm.utils.win-put}/bin/win-put meta.yaml llvm-or1k
      ${wfvm.utils.win-put}/bin/win-put bld.bat llvm-or1k
      ln -s ${src} src
      tar chf src.tar src
      ${wfvm.utils.win-put}/bin/win-put src.tar .

      ${wfvm.utils.win-exec}/bin/win-exec ".\Anaconda3\scripts\activate && conda build --no-anaconda-upload --no-test -c file:///C:/users/wfvm/fake-channel --override-channels llvm-or1k"

      ${wfvm.utils.win-get}/bin/win-get "Anaconda3/conda-bld/win-64/llvm-or1k-${version}-0.tar.bz2"
    '';
  };
in
  pkgs.runCommand "conda-windows-llvm-or1k" { buildInputs = [ build ]; } ''
    wfvm-run-build-llvm-or1k
    mkdir -p $out/win-64 $out/nix-support
    cp llvm-or1k-*.tar.bz2 $out/win-64
    echo file conda $out/win-64/*.tar.bz2 >> $out/nix-support/hydra-build-products
    ''
