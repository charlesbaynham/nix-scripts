{
  pkgs ? import <nixpkgs> {}
  , impureMode ? false
}:

let
  win = (import ./default.nix { inherit pkgs; });

in
win.makeWindowsImage {

  # Custom base iso
  # windowsImage = pkgs.fetchurl {
  #   url = "https://software-download.microsoft.com/download/sg/17763.107.101029-1455.rs5_release_svc_refresh_CLIENT_LTSC_EVAL_x64FRE_en-us.iso";
  #   sha256 = "668fe1af70c2f7416328aee3a0bb066b12dc6bbd2576f40f812b95741e18bc3a";
  # };

  # User accounts
  users = {
    artiq = {
      password = "1234";
      # description = "Default user";
      # displayName = "Display name";
      groups = [
        "Administrators"
      ];
    };
  };

  # Build install script & skip building iso
  inherit impureMode;

  # impureShellCommands = [
  #   "powershell.exe echo Hello"
  # ];

  fullName = "M-Labs";
  organization = "m-labs";

  administratorPassword = "12345";

  # Auto login
  defaultUser = "artiq";

  # Imperative installation commands, to be installed incrementally
  installCommands = [

    {
      name = "Anaconda3";
      script = let
        Anaconda3 = pkgs.fetchurl {
          name = "Anaconda3.exe";
          url = "https://repo.anaconda.com/archive/Anaconda3-2019.03-Windows-x86_64.exe";
          sha256 = "1f9icm5rwab6l1f23a70dw0qixzrl62wbglimip82h4zhxlh3jfj";
        };
      in ''
        cp ${Anaconda3} ./Anaconda3.exe
        win put Anaconda3.exe 'C:\Users\artiq'
        win exec 'start /wait "" .\Anaconda3.exe /S /D=%UserProfile%\Anaconda3'
      '';
    }

  ];

  # services = {
  #   # Enable remote management
  #   WinRm = {
  #     Status = "Running";
  #     PassThru = true;
  #   };
  # };

  # License key
  # productKey = "iboughtthisone";

  # Locales
  # uiLanguage = "en-US";
  # inputLocale = "en-US";
  # userLocale = "en-US";
  # systemLocale = "en-US";

  # packages = [
  #   (
  #     win.pkgs.makeMSIPkg {
  #       # Note: File not in repository, it's meant as an example to subsitute
  #       name = "notepadplusplus";
  #       msi = ./Notepad++7.7.msi;
  #       # Custom cert
  #       # cert = ./notepad++-cert.cer
  #     }
  #   )
  #   (
  #     win.pkgs.makeCrossPkg {
  #       name = "hello";
  #       pkg = pkgs.pkgsCross.mingwW64.hello;
  #     }
  #   )
  # ];

}
