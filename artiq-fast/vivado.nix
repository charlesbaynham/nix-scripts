# Install Vivado in /opt and add to /etc/nixos/configuration.nix:
#  nix.sandboxPaths = ["/opt"];

{ pkgs, vivadoPath ? "/opt/Xilinx/Vivado_Lab/2020.1" }:

pkgs.buildFHSUserEnv {
  name = "vivado";
  targetPkgs = pkgs: (
    with pkgs; [
      ncurses5
      zlib
      libuuid
      xorg.libSM
      xorg.libICE
      xorg.libXrender
      xorg.libX11
      xorg.libXext
      xorg.libXtst
      xorg.libXi
    ]
  );
  profile = "source ${vivadoPath}/settings64.sh";
  runScript = "vivado_lab";
}
