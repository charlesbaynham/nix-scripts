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
    in
      ''
      ln -s ${Anaconda3} ./Anaconda3.exe
      win-put Anaconda3.exe .
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
      win-put msys2.exe .
      win-put auto-install.js .
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
          (map (package: ''win-put ${package} 'msyspackages' '') msys-packages);
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
      win-put installmsyspackages.bat .
      win-exec installmsyspackages
      '';
  };
}
