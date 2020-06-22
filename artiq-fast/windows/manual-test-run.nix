{ pkgs ? import <nixpkgs> {} }:

let
  artiqpkgs = import ../. { inherit pkgs; };
  run-test = import ./run-test.nix {
    inherit pkgs artiqpkgs;
    testCommand = "set ARTIQ_ROOT=%cd%\\Anaconda3\\envs\\artiq-env\\Lib\\site-packages\\artiq\\examples\\kc705_nist_clock&& python -m unittest discover -v sipyco.test && python -m unittest discover -v artiq.test";
  };
in
  run-test
