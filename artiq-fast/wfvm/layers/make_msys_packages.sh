#!/usr/bin/env bash

set -e

nix-build -E "
let
  pkgs = import <nixpkgs> {};
  wfvm = import ../default.nix { inherit pkgs; };
in
  wfvm.utils.wfvm-run {
    name = \"get-msys-packages\";
    image = wfvm.makeWindowsImage { installCommands = [ wfvm.layers.msys2 ]; };
    script = ''
      cat > getmsyspackages.bat << EOF
      set MSYS=C:\\MSYS64
      set ARCH=32
      set TOOLPREF=mingw-w64-i686-
      set TRIPLE=x86_64-pc-mingw32
      set PATH=%MSYS%\usr\bin;%MSYS%\mingw%ARCH%\bin;%PATH%
      pacman -Sp %TOOLPREF%gcc %TOOLPREF%binutils make autoconf automake libtool texinfo > packages.txt
      EOF
      \${wfvm.utils.win-put}/bin/win-put getmsyspackages.bat
      \${wfvm.utils.win-exec}/bin/win-exec getmsyspackages
      \${wfvm.utils.win-get}/bin/win-get packages.txt
    '';
  }
"

./result/bin/wfvm-run-get-msys-packages

echo "{ pkgs } : [" > msys_packages.nix
while read package; do
	hash=$(nix-prefetch-url $package)
	echo "
(pkgs.fetchurl {
  url = \"$package\";
  sha256 = \"$hash\";
})" >> msys_packages.nix
done < packages.txt
echo "]" >> msys_packages.nix

rm result getmsyspackages.bat packages.txt
