{ pkgs, version, src, target }:

let
  wfvm = import ../wfvm { inherit pkgs; };
  libiconv-filename = "libiconv-1.15-h0c8e037_1006.tar.bz2";
  libiconv = pkgs.fetchurl {
    url = "https://anaconda.org/conda-forge/libiconv/1.15/download/win-64/${libiconv-filename}";
    sha256 = "1jaxnpg5y5pkhvpp9kaq0kpvz7jlj5hynp567q35l7hpfk6xxghh";
  };
  build = wfvm.utils.wfvm-run {
    name = "build-binutils";
    image = wfvm.makeWindowsImage { installCommands = with wfvm.layers; [ anaconda3 msys2 msys2-packages ]; };
    script = ''
      ln -s ${libiconv} ${libiconv-filename}
      ${wfvm.utils.win-put}/bin/win-put ${libiconv-filename}
      ${wfvm.utils.win-exec}/bin/win-exec ".\Anaconda3\scripts\activate && conda create -n build ${libiconv-filename}"

      cat > meta.yaml << EOF
      package:
        name: binutils-${target}
        version: ${version}

      source:
        url: ../src.tar.bz2

      requirements:
        run:
          - libiconv

      EOF

      cat > bld.bat << EOF
      set MSYS=C:\MSYS64
      set TOOLPREF=mingw-w64-x86_64-
      set TRIPLE=x86_64-pc-mingw64
      set PATH=%MSYS%\usr\bin;%MSYS%\mingw64\bin;%PATH%

      mkdir build
      cd build
      set CFLAGS=-I%PREFIX:\=/%/Library/include/
      set LDFLAGS=-L%PREFIX:\=/%/Library/lib/
      sh ../configure --build=%TRIPLE% ^
        --prefix="%PREFIX:\=/%/Library" ^
        --target=${target}
      if errorlevel 1 exit 1

      make -j4
      if errorlevel 1 exit 1

      make install
      if errorlevel 1 exit 1

      rem this is a copy of prefixed executables
      rmdir /S /Q %PREFIX%\Library\${target}
      EOF

      ${wfvm.utils.win-exec}/bin/win-exec "mkdir binutils"
      ${wfvm.utils.win-put}/bin/win-put meta.yaml binutils
      ${wfvm.utils.win-put}/bin/win-put bld.bat binutils
      ln -s ${src} src.tar.bz2
      ${wfvm.utils.win-put}/bin/win-put src.tar.bz2 .

      ${wfvm.utils.win-exec}/bin/win-exec ".\Anaconda3\scripts\activate build && conda build --no-anaconda-upload --no-test binutils"

      ${wfvm.utils.win-get}/bin/win-get ".\Anaconda3\conda-bld\win-64\binutils-${target}-${version}-0.tar.bz2"
    '';
  };
in
  pkgs.runCommand "conda-windows-binutils-${target}" { buildInputs = [ build ]; } ''
    wfvm-run-build-binutils
    mkdir -p $out/win-64 $out/nix-support
    cp *.tar.bz2 $out/win-64
    echo file conda $out/win-64/*.tar.bz2 >> $out/nix-support/hydra-build-products
    ''
