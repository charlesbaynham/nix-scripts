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
  # https://github.com/m-labs/artiq/issues/23
  hidapi = pkgs.hidapi.overrideAttrs (oa: {
      src = pkgs.fetchFromGitHub {
        owner = "signal11";
        repo = "hidapi";
        rev = "a6a622ffb680c55da0de787ff93b80280498330f";
        sha256 = "17n7c4v3jjrnzqwxpflggxjn6vkzscb32k4kmxqjbfvjqnx7qp7j";
      };
    });
in
  (dualPackage {
    name = "korad_ka3005p";
    version = "1.0";
    src = pkgs.fetchFromGitHub {
      owner = "m-labs";
      repo = "korad_ka3005p";
      rev = "51df56fcb5270b4f41bb37dc5338dd66eef21565";
      sha256 = "17dsf1bfaiy26wvn97lpxpypnx3crg45r2n6764mc7234gk2k0j4";
    };
    pythonOptions = { propagatedBuildInputs = [ asyncserial artiq ]; };
    condaOptions = { dependencies = [ "asyncserial" ]; };
  }) // (dualPackage {
    name = "novatech409b";
    version = "1.0";
    src = pkgs.fetchFromGitHub {
      owner = "m-labs";
      repo = "novatech409b";
      rev = "ad1dbfd5287d3910bc61bcd4db4df045c3ca53ab";
      sha256 = "16292n8kswk91gdxvf450hkh38lk31v8rgmfrl2mnfdladahg1ax";
    };
    pythonOptions = { propagatedBuildInputs = [ asyncserial artiq ]; };
    condaOptions = { dependencies = [ "asyncserial" ]; };
  }) // (dualPackage {
    name = "lda";
    version = "1.0";
    src = pkgs.fetchFromGitHub {
      owner = "m-labs";
      repo = "lda";
      rev = "c7a011f9b235c86f9c98a8aeb335acb00d525d7d";
      sha256 = "1dg37911v3pg97d14yhk648xrz5g0yv176csqbcv0iv3v1nvsyhd";
    };
    pythonOptions = {
      propagatedBuildInputs = [ artiq ];
      postPatch = ''
        substituteInPlace lda/hidapi.py \
        --replace "hidapi_lib_path = None"\
                  "hidapi_lib_path = '${hidapi}/lib/libhidapi-libusb.so.0'"
      '';
    };
  }) // (dualPackage {
    name = "thorlabs_tcube";
    version = "1.0";
    src = pkgs.fetchFromGitHub {
      owner = "m-labs";
      repo = "thorlabs_tcube";
      rev = "350aa142c0843647800b5052a9de7ef66b812898";
      sha256 = "1js9h02pay62vxdpkzsjphnf1p0yzdjky1x8csz7lh5kbyahl9vr";
    };
    pythonOptions = { propagatedBuildInputs = [ asyncserial artiq ]; };
    condaOptions = { dependencies = [ "asyncserial" ]; };
  }) // (dualPackage {
    name = "newfocus8742";
    version = "0.1";
    src = pkgs.fetchFromGitHub {
      owner = "quartiq";
      repo = "newfocus8742";
      rev = "31a92595d1cb77d9256b891ec17eed0fbeceb1bc";
      sha256 = "1dww0y83d4i6nma1q5hnaagih94c32bxlla5p6a5a8zkc4x2pky9";
    };
    pythonOptions = {
      propagatedBuildInputs = [ pkgs.python3Packages.pyusb artiq ];
      # no unit tests so do a simple smoke test
      checkPhase = "python -m newfocus8742.aqctl_newfocus8742 --version";
    };
  }) // (dualPackage {
    name = "hut2";
    version = "0.1";
    src = pkgs.fetchFromGitHub {
      owner = "quartiq";
      repo = "hut2";
      rev = "acfd62dcd60d37250e2d1b691344c6e65b6e83eb";
      sha256 = "0dpx3c5aclj7gki6iaybjbx9rqrxnwccpxcvjwp594ccbcswvclr";
    };
    pythonOptions = {
      propagatedBuildInputs = [ artiq ];
      # no unit tests without hardware so do a simple smoke test
      checkPhase = "python -m hut2.aqctl_hut2 --version";
    };
  }) // {
    toptica-lasersdk = pkgs.python3Packages.buildPythonPackage rec {
      version = "2.0.0";
      name = "toptica-lasersdk-${version}";
      format = "wheel";
      src = pkgs.fetchurl {
        url = "https://files.pythonhosted.org/packages/6b/e2/5c98407215884c2570453a78bc0d6f0bbe619f06593847ccd6a2f1d3fe59/toptica_lasersdk-2.0.0-py3-none-any.whl";
        sha256 = "1k5d9ah8qzp75hh63nh9l5dk808v9ybpmzlhrdc3sxmas3ajv8s7";
      };
      propagatedBuildInputs = [ pkgs.python3Packages.pyserial ];
    };
  }
