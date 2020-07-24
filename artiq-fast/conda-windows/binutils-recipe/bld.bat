set MSYS=C:\MSYS64
set TRIPLE=x86_64-w64-mingw32
set PATH=%MSYS%\usr\bin;%MSYS%\mingw64\bin;%PATH%

mkdir build
cd build
set CFLAGS=-I%PREFIX:\=/%/Library/include/
set LDFLAGS=-L%PREFIX:\=/%/Library/lib/
sh ../configure --build=%TRIPLE% ^
  --prefix="%PREFIX:\=/%/Library" ^
  --target=##TARGET##
if errorlevel 1 exit 1

make -j4
if errorlevel 1 exit 1

make install
if errorlevel 1 exit 1

rem this is a copy of prefixed executables
rmdir /S /Q %PREFIX%\Library\##TARGET##
