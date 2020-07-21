{ pkgs, version, src, target }:

let
  wfvm = import ../wfvm.nix { inherit pkgs; };
  repeat = s:
    let go = n:
          if n > 0
          then s + go (n - 1)
          else "";
    in go;
  outName = "windows-binutils-${target}-${version}.tar.bz2";
  # add padding for later PREFIX replacement in `conda build`
  prefix = "/c/Users/wfvm/binutils_" + repeat "0" 80;
  build = wfvm.utils.wfvm-run {
    name = "build-binutils";
    image = wfvm.makeWindowsImage { installCommands = with wfvm.layers; [ msys2 (msys2-packages (import ../conda-windows/msys_packages.nix { inherit pkgs; } )) ]; };
    script = ''
      tar xjf ${src}
      patch -d binutils-${version} -p1 < ${./binutils-hack-libiconv.patch}
      tar cjf src.tar.bz2 binutils-${version}
      ${wfvm.utils.win-put}/bin/win-put src.tar.bz2 .

      cat > build-binutils.bat << EOF
      set MSYS=c:\msys64
      set PATH=%MSYS%\usr\bin;%MSYS%\mingw64\bin;%PATH%
      tar xjf src.tar.bz2
      bash -c "cd binutils-${version} && ./configure --build=x86_64-pc-mingw64 --prefix=${prefix}/Library --target=${target} && make -j$NIX_BUILD_CORES && make install"
      rm -r ${prefix}/Library/or1k-linux
      cp %MSYS%/mingw64/bin/libiconv-2.dll ${prefix}/Library/bin/
      tar cjf ${outName} -C ${prefix} .
      EOF
      ${wfvm.utils.win-put}/bin/win-put build-binutils.bat .
      ${wfvm.utils.win-exec}/bin/win-exec build-binutils

      ${wfvm.utils.win-get}/bin/win-get ${outName}
    '';
  };
in
pkgs.runCommand outName {
  buildInputs = [ build ];
  passthru = { inherit prefix; };
} ''
    wfvm-run-build-binutils
    cp ${outName} $out
  ''
