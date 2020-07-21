set MSYS=C:\MSYS64
set PATH=%MSYS%\usr\bin;%MSYS%\mingw64\bin;%PATH%

cd %PREFIX%
tar xjf /c/Users/wfvm/src.tar.bz2
dir C:\Users\wfvm
python C:\Users\wfvm\patch_prefix.py "##PREFIX##" %PREFIX%
