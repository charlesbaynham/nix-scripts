{ pkgs }:
let
  wfvm = import ./.. { inherit pkgs; };
in
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
      win-put cmake.msi .
      win-exec "msiexec.exe /q /i cmake.msi ADD_CMAKE_TO_PATH=System"
      '';
  };
  msvc = {
    # https://docs.microsoft.com/en-us/visualstudio/install/create-an-offline-installation-of-visual-studio?view=vs-2019
    name = "MSVC";
    script = let
      bootstrapper = pkgs.fetchurl {
        url = "https://download.visualstudio.microsoft.com/download/pr/df6c2f11-eae3-4d3c-a0a8-9aec3421235b/313d838f54928b8e7138d6efc8387e5dfbcc0271f326bf0f60b9aaf57073cff5/vs_Community.exe";
        sha256 = "1xfgfdqgbamrc07vy9pkf41crysxgqwcivyn71qqx2wjaj7q6g9i";
      };
      # This touchy-feely "community" piece of trash seems deliberately crafted to break Wine, so we use the VM to run it.
      download-vs = wfvm.utils.wfvm-run {
        name = "download-vs";
        image = wfvm.makeWindowsImage { };
        isolateNetwork = false;
        script = 
          ''
          ln -s ${bootstrapper} vs_Community.exe
          ${wfvm.utils.win-put}/bin/win-put vs_Community.exe
          rm vs_Community.exe
          ${wfvm.utils.win-exec}/bin/win-exec "vs_Community.exe --quiet --layout vslayout --add Microsoft.VisualStudio.Workload.NativeDesktop --includeRecommended --lang en-US"
          ${wfvm.utils.win-get}/bin/win-get vslayout
          '';
      };
      cache = pkgs.stdenv.mkDerivation {
        name = "vs";

        outputHashAlgo = "sha256";
        outputHashMode = "recursive";
        outputHash = "0v2ivq7d5smbgi5iwkczr5zcsk4gg0jq7h0flj4r7lbk6lck7v2p";

        phases = [ "buildPhase" ];
        buildInputs = [ download-vs ];
        buildPhase =
          ''
          mkdir $out
          cd $out
          wfvm-run-download-vs
          '';
      };
    in
      ''
      echo ${cache}
      ln -s ${cache}/vslayout vslayout
      win-put vslayout .
      win-exec ".\vslayout\vs_community.exe --quiet --noweb --add Microsoft.VisualStudio.Workload.NativeDesktop --includeRecommended --lang en-US"
      '';
  };
}
