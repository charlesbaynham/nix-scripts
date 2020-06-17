{ pkgs }:
{
  anaconda3 = {
    name = "Anaconda3";
    script = let
      Anaconda3 = pkgs.fetchurl {
        name = "Anaconda3.exe";
        url = "https://repo.anaconda.com/archive/Anaconda3-2020.02-Windows-x86_64.exe";
        sha256 = "0n31l8l89jrjrbzbifxbjnr3g320ly9i4zfyqbf3l9blf4ygbhl3";
      };
    in ''
      ln -s ${Anaconda3} ./Anaconda3.exe
      win-put Anaconda3.exe 'C:\Users\wfvm'
      echo Running Anaconda installer...
      win-exec 'start /wait "" .\Anaconda3.exe /S /D=%UserProfile%\Anaconda3'
      echo Anaconda installer finished
    '';
  };
  msys2 = {
    name = "MSYS2";
    buildInputs = [ pkgs.expect ];
    script = let
      msys2 = pkgs.fetchurl {
        name = "msys2.exe";
        url = "https://github.com/msys2/msys2-installer/releases/download/2020-06-02/msys2-x86_64-20200602.exe";
        sha256 = "1mswlfybvk42vdr4r85dypgkwhrp5ff47gcbxgjqwq86ym44xzd4";
      };
      msys2-auto-install = pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/msys2/msys2-installer/master/auto-install.js";
        sha256 = "0ww48xch2q427c58arg5llakfkfzh3kb32kahwplp0s7jc8224g7";
      };
    in ''
      ln -s ${msys2} ./msys2.exe
      ln -s ${msys2-auto-install} ./auto-install.js
      win-put msys2.exe 'C:\Users\wfvm'
      win-put auto-install.js 'C:\Users\wfvm'
      echo Running MSYS2 installer...
      # work around MSYS2 installer bug that prevents it from closing at the end of unattended install
      expect -c 'set timeout 600; spawn win-exec ".\\msys2.exe --script auto-install.js -v InstallPrefix=C:\\msys64"; expect FinishedPageCallback { close }'
      echo MSYS2 installer finished
    '';
  };
  msys2-packages = {
    name = "MSYS2-packages";
    script = let
      msys-packages = import ./msys_packages.nix { inherit pkgs; };
      msys-packages-put = pkgs.lib.strings.concatStringsSep "\n"
          (map (package: ''win-put ${package} 'C:\Users\wfvm\msyspackages' '') msys-packages);
    in
      # Windows command line is so shitty it can't even do glob expansion. Why do people use Windows?
      ''
      win-exec 'mkdir msyspackages'
      ${msys-packages-put}
      cat > installmsyspackages.bat << EOF
      set MSYS=c:\msys64
      set ARCH=64
      set PATH=%MSYS%\usr\bin;%MSYS%\mingw%ARCH%\bin;%PATH%
      bash -c "pacman -U --noconfirm C:/Users/wfvm/msyspackages/*"
      EOF
      win-put installmsyspackages.bat 'C:\Users\wfvm'
      win-exec installmsyspackages
      '';
  };
  cmake = {
    name = "CMake";
    script = let
      cmake = pkgs.fetchurl {
        name = "cmake.msi";
        url = "https://github.com/Kitware/CMake/releases/download/v3.18.0-rc1/cmake-3.18.0-rc1-win64-x64.msi";
        sha256 = "1n32jzbg9w3vfbvyi9jqijz97gn1zsk1w5226wlrxd2a9d4w1hrn";
      };
    in
      ''
      ln -s ${cmake} cmake.msi
      win-put cmake.msi
      win-exec "msiexec.exe /q /i cmake.msi ADD_CMAKE_TO_PATH=System"
      '';
  };
  msvc = {
    name = "MSVC";
    script = let
      msvc-wine = pkgs.fetchFromGitHub {
        owner = "mstorsjo";
        repo = "msvc-wine";
        rev = "b953f996401c19df3039c04e4ac7f962e435a4b2";
        sha256 = "12rqx0r3d836x4k1ccda5xmzsd2938v5gmrp27awmzv1j3wplfsq";
      };
      vs = pkgs.stdenv.mkDerivation {
        name = "vs";

        outputHashAlgo = "sha256";
        outputHashMode = "recursive";
        outputHash = "1ngq7mg02kzfysh559j3fkjh2hngmay4jjar55p2db4d9rkvqh22";

        src = msvc-wine;

        phases = [ "buildPhase" ];
        buildInputs = [ pkgs.cacert (pkgs.python3.withPackages(ps: [ ps.simplejson ps.six ])) pkgs.msitools ];
        buildPhase = "python $src/vsdownload.py --accept-license --dest $out";
      };
    in
      ''
      win-put ${vs}/VC/Tools/MSVC 'C:\'
      win-exec 'setx PATH C:\MSVC\14.26.28801\bin\Hostx64\x64;%PATH% /m'
      '';
  };
}
