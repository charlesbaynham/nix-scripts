{  pkgs ? import <nixpkgs> {}, impureMode ? false }:

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
  installCommands = with win.layers; [ anaconda3 msys2 msys2-packages ];

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

}
