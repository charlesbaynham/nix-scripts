{ stdenv, fetchgit, git, rustc }:
stdenv.mkDerivation rec {
  pname = "libartiq-support";
  version = import ./artiq-version.nix { inherit stdenv fetchgit git; };

  src = import ./artiq-src.nix { inherit fetchgit; };

  buildInputs = [ rustc ];
  phases = [ "buildPhase" ];
  buildPhase =
  ''
  mkdir $out
  rustc ${src}/artiq/test/libartiq_support/lib.rs --out-dir $out -Cpanic=unwind -g
  '';
}
