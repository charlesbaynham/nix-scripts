{ pkgs, asyncserial, artiq }:
let
  korad_ka3005p_version = "1.0";
  korad_ka3005p_src = pkgs.fetchFromGitHub {
    owner = "m-labs";
    repo = "korad_ka3005p";
    rev = "e0adec6c577d7d1b832a2b1bf20e89ac393ca27e";
    sha256 = "18092zgjh63qrg6lg9mzsbr2yri7k7wb97mip5xq3zrcabmmpbk3";
  };
in rec {
  korad_ka3005p = pkgs.python3Packages.buildPythonPackage rec {
    version = korad_ka3005p_version;
    name = "korad_ka3005p-${version}";
    buildInputs = [ asyncserial artiq ];
    src = korad_ka3005p_src;
  };
  conda-korad_ka3005p = import ./conda-build.nix { inherit pkgs; } {
    name = "conda-korad_ka3005p";
    src = import ./conda-fake-source.nix { inherit pkgs; } {
      name = "korad_ka3005p";
      version = korad_ka3005p_version;
      src = korad_ka3005p_src;
      dependencies = [ "asyncserial" ];
    };
  };
}
