{ pkgs, version, src }:

let
  wfvm = import ../wfvm { inherit pkgs; };
  build = wfvm.utils.wfvm-run {
    name = "build-llvm-or1k";
    image = wfvm.makeWindowsImage { installCommands = with wfvm.layers; [ anaconda3 msys2 msys2-packages ]; };
    script = ''
      ${wfvm.utils.win-exec}/bin/win-exec ".\Anaconda3\scripts\activate && conda create -n build --offline"

      cat > meta.yaml << EOF
      package:
        name: llvm-or1k
        version: ${version}

      source:
        url: ../src.tar

      EOF

      cat > bld.bat << EOF
      set MSYS=C:\MSYS64
      set PATH=%MSYS%\usr\bin;%MSYS%\mingw64\bin;%PATH%

      set BUILD_TYPE=Release
      set CMAKE_GENERATOR=MinGW Makefiles

      mkdir build
      cd build
      cmake .. -G "%CMAKE_GENERATOR%" ^
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

      ${wfvm.utils.win-exec}/bin/win-exec ".\Anaconda3\scripts\activate build && conda build --no-anaconda-upload --no-test llvm-or1k"

      ${wfvm.utils.win-get}/bin/win-get ".\Anaconda3\conda-bld\win-64\llvm-or1k-${version}-0.tar.bz2"
    '';
  };
in
  pkgs.runCommand "conda-windows-llvm-or1k" { buildInputs = [ build ]; } ''
    wfvm-run-build-llvm-or1k
    mkdir -p $out/win-64 $out/nix-support
    cp *.tar.bz2 $out/win-64
    echo file conda $out/win-64/*.tar.bz2 >> $out/nix-support/hydra-build-products
    ''
