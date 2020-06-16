{ pkgs, conda-windows-llvm-or1k, version, src }:

# See: https://github.com/valtron/llvm-stuff/wiki/Build-llvmlite-with-MSYS2

let
  wfvm = import ../wfvm { inherit pkgs; };
  build = wfvm.utils.wfvm-run {
    name = "build-llvmlite-artiq";
    image = wfvm.makeWindowsImage { installCommands = with wfvm.layers; [ anaconda3 msys2 msys2-packages ]; };
    script = ''
      ${wfvm.utils.win-put}/bin/win-put "${conda-windows-llvm-or1k}/win-64/llvm-or1k-*.tar.bz2" ".\llvm-or1k.tar.bz2"
      ${wfvm.utils.win-exec}/bin/win-exec ".\Anaconda3\scripts\activate && conda create -n build llvm-or1k.tar.bz2"

      cat > meta.yaml << EOF
      package:
        name: llvmlite-artiq
        version: ${version}

      source:
        url: ../src.tar
      EOF

      cat > bld.bat << EOF
      set MSYS=C:\MSYS64
      set PATH=%MSYS%\usr\bin;%MSYS%\mingw64\bin;%PATH%

      python setup.py install \
        --prefix=\$PREFIX \
        --single-version-externally-managed \
        --record=record.txt \
        --no-compile
      EOF

      ${wfvm.utils.win-exec}/bin/win-exec "mkdir llvmlite-artiq"
      ${wfvm.utils.win-put}/bin/win-put meta.yaml ".\llvmlite-artiq"
      ${wfvm.utils.win-put}/bin/win-put bld.bat ".\llvmlite-artiq"
      cp --no-preserve=mode,ownership -R ${src} src
      patch -d src -p1 < ${./llvmlite-msys.diff}
      tar chf src.tar src
      ${wfvm.utils.win-put}/bin/win-put src.tar ".\src.tar"

      ${wfvm.utils.win-exec}/bin/win-exec ".\Anaconda3\scripts\activate build && conda build --no-anaconda-upload --no-test llvmlite-artiq"

      ${wfvm.utils.win-get}/bin/win-get ".\Anaconda3\conda-bld\win-64\llvmlite-artiq-${version}-0.tar.bz2"
    '';
  };
in
  pkgs.runCommand "conda-windows-llvmlite-artiq" { buildInputs = [ build ]; } ''
    wfvm-run-build-llvmlite-artiq
    mkdir -p $out/win-64 $out/nix-support
    cp *.tar.bz2 $out/win-64
    echo file conda $out/win-64/*.tar.bz2 >> $out/nix-support/hydra-build-products
    ''
