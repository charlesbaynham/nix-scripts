#!/usr/bin/env bash

# Obtain the list with e.g. pacman -Sp %TOOLPREF%gcc %TOOLPREF%binutils make autoconf automake libtool texinfo

read -r -d '' packages << EOM
http://repo.msys2.org/mingw/i686/mingw-w64-i686-libiconv-1.16-1-any.pkg.tar.xz 
http://repo.msys2.org/mingw/i686/mingw-w64-i686-zlib-1.2.11-7-any.pkg.tar.xz
http://repo.msys2.org/mingw/i686/mingw-w64-i686-binutils-2.34-3-any.pkg.tar.zst
http://repo.msys2.org/mingw/i686/mingw-w64-i686-headers-git-8.0.0.5905.066f1b3c-1-any.pkg.tar.zst
http://repo.msys2.org/mingw/i686/mingw-w64-i686-crt-git-8.0.0.5905.066f1b3c-1-any.pkg.tar.zst
http://repo.msys2.org/mingw/i686/mingw-w64-i686-isl-0.22.1-1-any.pkg.tar.xz
http://repo.msys2.org/mingw/i686/mingw-w64-i686-gmp-6.2.0-1-any.pkg.tar.xz
http://repo.msys2.org/mingw/i686/mingw-w64-i686-mpfr-4.0.2-2-any.pkg.tar.xz
http://repo.msys2.org/mingw/i686/mingw-w64-i686-mpc-1.1.0-1-any.pkg.tar.xz
http://repo.msys2.org/mingw/i686/mingw-w64-i686-libwinpthread-git-8.0.0.5906.c9a21571-1-any.pkg.tar.zst
http://repo.msys2.org/mingw/i686/mingw-w64-i686-gcc-libs-10.1.0-3-any.pkg.tar.zst
http://repo.msys2.org/mingw/i686/mingw-w64-i686-windows-default-manifest-6.4-3-any.pkg.tar.xz
http://repo.msys2.org/mingw/i686/mingw-w64-i686-winpthreads-git-8.0.0.5906.c9a21571-1-any.pkg.tar.zst
http://repo.msys2.org/mingw/i686/mingw-w64-i686-zstd-1.4.5-1-any.pkg.tar.zst
http://repo.msys2.org/mingw/i686/mingw-w64-i686-gcc-10.1.0-3-any.pkg.tar.zst
http://repo.msys2.org/msys/x86_64/make-4.3-1-x86_64.pkg.tar.xz
http://repo.msys2.org/msys/x86_64/m4-1.4.18-2-x86_64.pkg.tar.xz
http://repo.msys2.org/msys/x86_64/diffutils-3.7-1-x86_64.pkg.tar.xz
http://repo.msys2.org/msys/x86_64/autoconf-2.69-5-any.pkg.tar.xz
http://repo.msys2.org/msys/x86_64/automake1.6-1.6.3-2-any.pkg.tar.xz
http://repo.msys2.org/msys/x86_64/automake1.7-1.7.9-2-any.pkg.tar.xz
http://repo.msys2.org/msys/x86_64/automake1.8-1.8.5-3-any.pkg.tar.xz
http://repo.msys2.org/msys/x86_64/automake1.9-1.9.6-2-any.pkg.tar.xz
http://repo.msys2.org/msys/x86_64/automake1.10-1.10.3-3-any.pkg.tar.xz
http://repo.msys2.org/msys/x86_64/automake1.11-1.11.6-3-any.pkg.tar.xz
http://repo.msys2.org/msys/x86_64/automake1.12-1.12.6-3-any.pkg.tar.xz
http://repo.msys2.org/msys/x86_64/automake1.13-1.13.4-4-any.pkg.tar.xz
http://repo.msys2.org/msys/x86_64/automake1.14-1.14.1-3-any.pkg.tar.xz
http://repo.msys2.org/msys/x86_64/automake1.15-1.15.1-1-any.pkg.tar.xz
http://repo.msys2.org/msys/x86_64/automake1.16-1.16.1-1-any.pkg.tar.xz
http://repo.msys2.org/msys/x86_64/automake-wrapper-11-1-any.pkg.tar.xz
http://repo.msys2.org/msys/x86_64/libltdl-2.4.6-9-x86_64.pkg.tar.xz
http://repo.msys2.org/msys/x86_64/tar-1.32-1-x86_64.pkg.tar.xz
http://repo.msys2.org/msys/x86_64/libtool-2.4.6-9-x86_64.pkg.tar.xz
http://repo.msys2.org/msys/x86_64/texinfo-6.7-1-x86_64.pkg.tar.xz
EOM

echo "{ pkgs } : ["
for package in $packages; do
	hash=$(nix-prefetch-url $package)
	echo "
(pkgs.fetchurl {
  url = \"$package\";
  sha256 = \"$hash\";
})"
done
echo "]"
