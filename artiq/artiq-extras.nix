{ pkgs, asyncserial, artiq }:
let
  dualPackage = (
    { name, version, src, pythonOptions ? {}, condaOptions ? {}}:
      {
        "${name}" = pkgs.python3Packages.buildPythonPackage ({
          inherit version;
          name = "${name}-${version}";
          inherit src;
        } // pythonOptions);
        "conda-${name}" = import ./conda-build.nix { inherit pkgs; } {
          name = "conda-${name}";
          src = import ./conda-fake-source.nix { inherit pkgs; } ({
            inherit name version src;
          } // condaOptions);
        };
      }
    );
in
  (dualPackage {
    name = "korad_ka3005p";
    version = "1.0";
    src = pkgs.fetchFromGitHub {
      owner = "m-labs";
      repo = "korad_ka3005p";
      rev = "e0adec6c577d7d1b832a2b1bf20e89ac393ca27e";
      sha256 = "18092zgjh63qrg6lg9mzsbr2yri7k7wb97mip5xq3zrcabmmpbk3";
    };
    pythonOptions = { propagatedBuildInputs = [ asyncserial artiq ]; };
    condaOptions = { dependencies = [ "asyncserial" ]; };
  }) // (dualPackage {
    name = "novatech409b";
    version = "1.0";
    src = pkgs.fetchFromGitHub {
      owner = "m-labs";
      repo = "novatech409b";
      rev = "c95c52ea3fdcc8459d84bd72bb54c3dc77883968";
      sha256 = "1lkdf1wwngwpmm4byaz1jbjpc9gnq3q8ig6hq305dn73cja99zn9";
    };
    pythonOptions = { propagatedBuildInputs = [ asyncserial artiq ]; };
    condaOptions = { dependencies = [ "asyncserial" ]; };
  }) // (dualPackage {
    name = "newfocus8742";
    version = "0.1";
    src = pkgs.fetchFromGitHub {
      owner = "quartiq";
      repo = "newfocus8742";
      rev = "2d97eb741f43bd5cb9eec92635101b70ad9c129c";
      sha256 = "0xzx1p6qn24ckbc8pyxzq8wxn64pvrbwm2l94mblij6dblksdgmv";
    };
    pythonOptions = {
      propagatedBuildInputs = [ artiq ];
      # no unit tests so do a simple smoke test
      checkPhase = "python -m newfocus8742.aqctl_newfocus8742 --version";
    };
  })
