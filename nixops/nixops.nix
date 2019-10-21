{
  rpi-1 = import ./rpi.nix { host = "rpi-1"; };
  rpi-2 = import ./rpi.nix { host = "rpi-2"; };
  juno = import ./desktop.nix { host = "juno"; };
}
