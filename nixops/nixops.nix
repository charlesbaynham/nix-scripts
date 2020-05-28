{
  rpi-1 = import ./rpi.nix { host = "rpi-1"; rpi4 = false; };
  rpi-2 = import ./rpi.nix { host = "rpi-2"; rpi4 = false; };
  rpi-3 = import ./rpi.nix { host = "rpi-3"; rpi4 = true; };
  rpi-4 = import ./rpi.nix { host = "rpi-4"; rpi4 = true; };
  rpi-5 = import ./rpi.nix { host = "rpi-5"; rpi4 = true; };
  juno = import ./desktop.nix { host = "juno"; };
  zeus = import ./desktop.nix { host = "zeus"; };
  hera = import ./desktop.nix { host = "hera"; };
  hestia = import ./desktop.nix { host = "hestia"; };
  chiron = import ./desktop.nix { host = "chiron"; };
  cnc = import ./light.nix { host = "cnc"; };
}
