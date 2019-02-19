{ pkgs, stdenv, fetchFromGitHub, python, python3Packages }:

rec { 
  asyncserial = python3Packages.buildPythonPackage rec {
    name = "asyncserial";

    src = fetchFromGitHub {
      owner = "m-labs";
      repo = "asyncserial";
      rev = "d95bc1d6c791b0e9785935d2f62f628eb5cdf98d";
      sha256 = "0yzkka9jk3612v8gx748x6ziwykq5lr7zmr9wzkcls0v2yilqx9k";
      fetchSubmodules = true;
    };

    propagatedBuildInputs = with python3Packages; [ pyserial ] ++ (with pkgs; [ ]);

    meta = with stdenv.lib; {
      description = "asyncio support for pyserial";
      homepage    = "https://m-labs.hk";
      license     = licenses.bsd2;
      platforms   = platforms.unix;
    };
  };
  misoc = python3Packages.buildPythonPackage rec {
    name = "misoc";
    
    src = fetchFromGitHub {
      owner = "m-labs";
      repo = "misoc";
      rev = "8e033c2cb77f78c95d2b2e08125324891d07fa34";
      sha256 = "0pv1akhvr85iswqmhzcqh9gfnyha11k68qmhqizma8fdccvvzm4y";
      fetchSubmodules = true;
    };

    # TODO: fix misoc bitrot and re-enable tests
    doCheck = false;
    
    propagatedBuildInputs = with python3Packages; [ pyserial jinja2 numpy asyncserial migen ];

    meta = with stdenv.lib; {
      description = "A high performance and small footprint system-on-chip based on Migen";
      homepage    = "https://m-labs.hk/migen";
      license     = licenses.bsd2;
      platforms   = platforms.unix;
    };
  };
  migen = python3Packages.buildPythonPackage rec {
    name = "migen";

    src = fetchFromGitHub {
      owner = "m-labs";
      repo = "migen";
      rev = "afe4405becdbc76539f0195c319367187012b05e";
      sha256 = "1f288a7ll1d1gjmml716wsjf1jyq9y903i2312bxb8pwrg7fwgvz";
    };

    # TODO: fix migen platform issues and re-enable tests
    doCheck = false;

    propagatedBuildInputs = with python3Packages; [ colorama sphinx sphinx_rtd_theme ] ++ (with pkgs; [ verilator ]);

    meta = with stdenv.lib; {
      description = "A Python toolbox for building complex digital hardware";
      homepage    = "https://m-labs.hk/migen";
      license     = licenses.bsd2;
      platforms   = platforms.unix;
    };
  };
  microscope = python3Packages.buildPythonPackage rec {
    name = "microscope";

    src = fetchFromGitHub {
      owner = "m-labs";
      repo = "microscope";
      rev = "02cffc360ec5a234c589de6cb9616b057ed22253";
      sha256 = "09yvgk16xfv5r5cf55vcg0f14wam42w53r4snlalcyw5gkm0rlhq";
    };

    propagatedBuildInputs = with python3Packages; [ pyserial prettytable msgpack-python migen ];

    meta = with stdenv.lib; {
      description = "Finding the bacteria in rotting FPGA designs";
      homepage    = "https://m-labs.hk/migen";
      license     = licenses.bsd2;
      platforms   = platforms.unix;
    };
  };
  jesd204b = python3Packages.buildPythonPackage rec {
    name = "jesd204b";

    src = fetchFromGitHub {
      owner = "m-labs";
      repo = "jesd204b";
      rev = "2fd6391c0a9197580d60f7d8a146191dc7337b03";
      sha256 = "1lhw8f0dp42xx4g6d7hyhqhrnd6i5ll4a1wcg265rqz3600i4009";
    };

    propagatedBuildInputs = with python3Packages; [ migen misoc ];

    meta = with stdenv.lib; {
      description = "JESD204B core for Migen/MiSoC";
      homepage    = "https://m-labs.hk/migen";
      license     = licenses.bsd2;
      platforms   = platforms.unix;
    };
  };

  # sphinx-argparse will be included in nixpkgs 19.03
  sphinx-argparse = python3Packages.buildPythonPackage rec {
    pname = "sphinx-argparse";
    version = "0.2.5";

    src = python3Packages.fetchPypi {
      inherit pname version;
      sha256 = "05wc8f5hb3jsg2vh2jf7jsyan8d4i09ifrz2c8fp6f7x1zw9iav0";
    };

    checkInputs = [ python3Packages.pytest ];
    checkPhase = "py.test";

    propagatedBuildInputs = [ python3Packages.sphinx ];

    meta = with stdenv.lib; {
      description = "A sphinx extension that automatically documents argparse commands and options";
      homepage = https://github.com/ribozz/sphinx-argparse;
      license = licenses.mit;
      maintainers = with maintainers; [ clacke ];
    };
  };

  wavedrom = python3Packages.buildPythonPackage rec {
    pname = "wavedrom";
    version = "0.1";

    src = python3Packages.fetchPypi {
      inherit pname version;
      sha256 = "006w683zlmmwcw5xz1n5dwg34ims5jg3gl2700ql4wr0myjz6710";
    };

    buildInputs = [ python3Packages.setuptools_scm ];
    propagatedBuildInputs = with python3Packages; [ svgwrite attrdict ];

    doCheck = false;

    meta = with stdenv.lib; {
      description = "WaveDrom compatible Python module and command line";
      homepage    = "https://pypi.org/project/wavedrom/";
      license     = licenses.mit;
    };
  };

  sphinxcontrib-wavedrom = python3Packages.buildPythonPackage rec {
    pname = "sphinxcontrib-wavedrom";
    version = "1.3.1";

    src = python3Packages.fetchPypi {
      inherit pname version;
      sha256 = "1q2hk630nz734cln2wwngjidlb7xyk6ly8qqlpsj259n9n2iab6v";
    };

    buildInputs = [ python3Packages.setuptools_scm ];
    propagatedBuildInputs = with python3Packages; [ sphinx wavedrom cairosvg xcffib ];

    meta = with stdenv.lib; {
      description = "A Sphinx extension that allows including WaveDrom diagrams";
      homepage    = "https://pypi.org/project/sphinxcontrib-wavedrom/";
      license     = licenses.mit;
    };
  };
}
