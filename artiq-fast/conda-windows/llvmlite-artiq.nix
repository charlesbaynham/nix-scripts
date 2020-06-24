{ pkgs, conda-windows-llvm-or1k, version, src }:

let
  wfvm = import ../wfvm { inherit pkgs; };
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
    name = "build-llvmlite-artiq";
    image = wfvm.makeWindowsImage { installCommands = with wfvm.layers; [ anaconda3 msvc msvc-ide-unbreak ]; };
    script = ''
      ln -s ${conda-vs2015_runtime} ${conda-vs2015_runtime-filename}
      ln -s ${conda-cmake} ${conda-cmake-filename}
      ${wfvm.utils.win-exec}/bin/win-exec "mkdir fake-channel && mkdir fake-channel\win-64"
      ${wfvm.utils.win-put}/bin/win-put ${conda-vs2015_runtime-filename} ./fake-channel/win-64
      ${wfvm.utils.win-put}/bin/win-put ${conda-cmake-filename} ./fake-channel/win-64
      ${wfvm.utils.win-put}/bin/win-put ${conda-windows-llvm-or1k}/win-64/llvm-or1k-*.tar.bz2 ./fake-channel/win-64
      ${wfvm.utils.win-exec}/bin/win-exec ".\Anaconda3\scripts\activate && conda index fake-channel"

      cat > meta.yaml << EOF
      package:
        name: llvmlite-artiq
        version: ${version}

      source:
        url: ../src.tar

      requirements:
        build:
          - cmake
          - llvm-or1k
      EOF

      cat > bld.bat << EOF
      @rem Let CMake know about the LLVM install path, for find_package()
      set CMAKE_PREFIX_PATH=%LIBRARY_PREFIX%

      @rem Ensure there are no build leftovers (CMake can complain)
      if exist ffi\build rmdir /S /Q ffi\build

      python setup.py install \
        --prefix=%PREFIX% \
        --single-version-externally-managed \
        --record=record.txt \
        --no-compile
      if errorlevel 1 exit 1
      EOF

      ${wfvm.utils.win-exec}/bin/win-exec "mkdir llvmlite-artiq"
      ${wfvm.utils.win-put}/bin/win-put meta.yaml llvmlite-artiq
      ${wfvm.utils.win-put}/bin/win-put bld.bat llvmlite-artiq
      ln -s ${src} src
      tar chf src.tar src
      ${wfvm.utils.win-put}/bin/win-put src.tar .

      ${wfvm.utils.win-exec}/bin/win-exec ".\Anaconda3\scripts\activate && conda build --no-anaconda-upload --no-test -c file:///C:/users/wfvm/fake-channel --override-channels llvmlite-artiq"

      ${wfvm.utils.win-get}/bin/win-get "Anaconda3/conda-bld/win-64/llvmlite-artiq-${version}-0.tar.bz2"
    '';
  };
in
  pkgs.runCommand "conda-windows-llvmlite-artiq" { buildInputs = [ build ]; } ''
    wfvm-run-build-llvmlite-artiq
    mkdir -p $out/win-64 $out/nix-support
    cp llvmlite-artiq-*.tar.bz2 $out/win-64
    echo file conda $out/win-64/*.tar.bz2 >> $out/nix-support/hydra-build-products
    ''
