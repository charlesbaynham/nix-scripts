{ pkgs, asyncserial, artiq }:
{
  korad_ka3005p = pkgs.python3Packages.buildPythonPackage rec {
    version = "1.0";
    name = "korad_ka3005p-${version}";
    buildInputs = [ asyncserial artiq ];
    src = pkgs.fetchFromGitHub {
      owner = "m-labs";
      repo = "korad_ka3005p";
      rev = "e0adec6c577d7d1b832a2b1bf20e89ac393ca27e";
      sha256 = "18092zgjh63qrg6lg9mzsbr2yri7k7wb97mip5xq3zrcabmmpbk3";
    };
  };
}
