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
        "${name}-manual-html" = pkgs.stdenv.mkDerivation {
          name = "${name}-manual-html-${version}";
          inherit version src;
          buildInputs = (with pkgs.python3Packages; [ sphinx sphinx_rtd_theme sphinx-argparse ]) ++ [ artiq ];
          preBuild = ''
            export SOURCE_DATE_EPOCH=${import ./fast/pkgs/artiq-timestamp.nix { inherit (pkgs) stdenv fetchgit git; }}
            cd doc
          '';
          makeFlags = [ "html" ];
          installPhase =
            let
              dest = "$out/share/doc/${name}-manual";
            in
              ''
              mkdir -p ${dest}
              cp -r _build/html ${dest}/

              mkdir -p $out/nix-support/
              echo doc manual ${dest}/html index.html >> $out/nix-support/hydra-build-products
              '';
        };
        "conda-${name}" = import ./fast/conda-build.nix { inherit pkgs; } {
          name = "conda-${name}";
          src = import ./fast/conda-fake-source.nix { inherit pkgs; } ({
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
      rev = "e8c02ade175b842972f76a27919a4aaf8190de90";
      sha256 = "1svgnx52amvy9xl0b2wkz0ii4ycjvjv96ac0g07zkxabdqm5ff65";
    };
    pythonOptions = { propagatedBuildInputs = [ asyncserial artiq ]; };
    condaOptions = { dependencies = [ "asyncserial" ]; };
  }) // (dualPackage {
    name = "novatech409b";
    version = "1.0";
    src = pkgs.fetchFromGitHub {
      owner = "m-labs";
      repo = "novatech409b";
      rev = "442e82e2234c0bf951da2084a77861f8977755c8";
      sha256 = "032qgg48dy2k31vj0q8bfni0iy2kcyscd32bq60h701wvass6jv7";
    };
    pythonOptions = { propagatedBuildInputs = [ asyncserial artiq ]; };
    condaOptions = { dependencies = [ "asyncserial" ]; };
  }) // (dualPackage {
    name = "lda";
    version = "1.0";
    src = pkgs.fetchFromGitHub {
      owner = "m-labs";
      repo = "lda";
      rev = "4329da1497f496839ce20beebce0d79ed453941f";
      sha256 = "00c15a03xy9vbca0j2zfy89l3ghbdmmv5wqfksm6pdwy4z036cwa";
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
      rev = "b72e7ba7de8355bd93dd20d53b6f15386dff229d";
      sha256 = "1lqwqflwbfdykmhf6g0pwgiq7i2vf67ybj4l8n3jn16vny21b41s";
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
  }) // rec {
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
    toptica-lasersdk-artiq = pkgs.python3Packages.buildPythonPackage rec {
      version = "0.1";
      name = "toptica-lasersdk-artiq-${version}";
      src = pkgs.fetchFromGitHub {
        owner = "quartiq";
        repo = "lasersdk-artiq";
        rev = "d38bb985e7ddffc9ac9d94fe136cac10947bfd72";
        sha256 = "03a09lc81l2l787yjm0xjpnjvs5x77ndmks3xxh25yyxdhsdf1fl";
      };
      postPatch = ''
        substituteInPlace lasersdk_artiq/aqctl_laser.py \
          --replace "toptica.lasersdk.async.client" \
                    "toptica.lasersdk.asyncio.client"
        substituteInPlace lasersdk_artiq/test.py \
          --replace "toptica.lasersdk.async.client" \
                    "toptica.lasersdk.asyncio.client"
      '';
      propagatedBuildInputs = [ toptica-lasersdk artiq ];
    };
  } // (dualPackage {
    name = "highfinesse-net";
    version = "0.1";
    src = pkgs.fetchFromGitHub {
      owner = "quartiq";
      repo = "highfinesse-net";
      rev = "6864ae5da5cbc67953b968010115db951e52a272";
      sha256 = "1k8xacgam5xghxvljvdzpsdhhq86fra13hkvdy7y301s9nyp30s4";
    };
    pythonOptions = {
      propagatedBuildInputs = [ artiq ];
      # no unit tests without hardware so do a simple smoke test
      checkPhase = "python -m highfinesse_net.aqctl_highfinesse_net --version";
    };
  })
