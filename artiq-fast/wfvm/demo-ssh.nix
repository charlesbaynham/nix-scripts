{ pkgs ? import <nixpkgs> {} }:

let
  wfvm = (import ./default.nix { inherit pkgs; });
in
  wfvm.utils.wfvm-run {
    name = "demo-ssh";
    image = import ./demo-image.nix { inherit pkgs; };
    script = ''
      ${pkgs.sshpass}/bin/sshpass -p1234 -- ${pkgs.openssh}/bin/ssh -p 2022 wfvm@localhost -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null
    '';
  }
