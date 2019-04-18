{ pkgs ? import <nixpkgs> {},
  diskImage ? "/opt/windows/c.img",
  qemuMem ? "2G",
  testTimeout ? 180,
}:

with pkgs;

let
  windowsRunner = overrides:
    import ./run-test.nix {
      inherit pkgs diskImage qemuMem testTimeout;
    };
in

stdenv.mkDerivation {
  name = "windows-test";
  src = ./.;

  phases = [ "installPhase" "checkPhase" ];
  installPhase = "touch $out";
  doCheck = true;
  checkPhase = ''
    ${windowsRunner { testCommand = "set ARTIQ_ROOT=%cd%\\anaconda\\envs\\artiq-env\\Lib\\site-packages\\artiq\\examples\\kc705_nist_clock&&set ARTIQ_LOW_LATENCY=1&&python -m unittest discover -v artiq.test"; }}/bin/run.sh
  '';
}
