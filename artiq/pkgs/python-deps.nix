{ stdenv, fetchFromGitHub, python, python3Packages }:

rec {
  # User dependencies
  asyncserial = python3Packages.buildPythonPackage rec {
    name = "asyncserial";
    src = fetchFromGitHub {
      owner = "m-labs";
      repo = "asyncserial";
      rev = "d95bc1d6c791b0e9785935d2f62f628eb5cdf98d";
      sha256 = "0yzkka9jk3612v8gx748x6ziwykq5lr7zmr9wzkcls0v2yilqx9k";
    };
    propagatedBuildInputs = with python3Packages; [ pyserial ];
    doCheck = false;
  };

  levenshtein = python3Packages.buildPythonPackage rec {
    name = "levenshtein";
    src = fetchFromGitHub {
      owner = "ztane";
      repo = "python-Levenshtein";
      rev = "854e61a05bb8b750e990add96df412cd5448b75e";
      sha256 = "1yf21kg1g2ivm5a4dx1jra9k0c33np54d0hk5ymnfyc4f6pg386q";
    };
    doCheck = false;
  };

  pythonparser = python3Packages.buildPythonPackage rec {
    name = "pythonparser";
    src = fetchFromGitHub {
      owner = "m-labs";
      repo = "pythonparser";
      rev = "5b391fe86f43bb9f4f96c5bc0532e2a112db2936";
      sha256 = "1gw1fk4y2l6bwq0fg2a9dfc1rvq8cv492dyil96amjdhsxvnx35b";
    };
    patches = [ ./python37hack.patch ];
    propagatedBuildInputs = with python3Packages; [ regex ];
  };

  quamash = python3Packages.buildPythonPackage rec {
    name = "quamash";
    src = fetchFromGitHub {
      owner = "harvimt";
      repo = "quamash";
      rev = "e513b30f137415c5e098602fa383e45debab85e7";
      sha256 = "117rp9r4lz0kfz4dmmpa35hp6nhbh6b4xq0jmgvqm68g9hwdxmqa";
    };
    propagatedBuildInputs = with python3Packages; [ pyqt5 ];
    doCheck = false;
  };

  pyqtgraph-qt5 = python3Packages.buildPythonPackage rec {
    name = "pyqtgraph_qt5-${version}";
    version = "0.10.0";
    doCheck = false;
    src = fetchFromGitHub {
      owner = "pyqtgraph";
      repo = "pyqtgraph";
      rev = "1426e334e1d20542400d77c72c132b04c6d17ddb";
      sha256 = "1079haxyr316jf0wpirxdj0ry6j8mr16cqr0dyyrd5cnxwl7zssh";
    };
    propagatedBuildInputs = with python3Packages; [ scipy numpy pyqt5 pyopengl ];
  };

  # TODO: use python3Packages.pyftdi starting with NixOS 19.09 or later
  # Upstream PR: https://github.com/NixOS/nixpkgs/pull/61256
  pyftdi = python3Packages.buildPythonPackage rec {
    name = "pyftdi";
    src = fetchFromGitHub {
      owner = "eblot";
      repo = "pyftdi";
      rev = "8e6f0bab6cff3eb60d2dbe578d0c5a2d1a9e135c";
      sha256 = "0mw79fjnvswa0j3bzr0y906rz1vjbr8lwy0albgvsfr0ngwbajqy";
    };
    propagatedBuildInputs = with python3Packages; [ pyusb pyserial ];
  };


  # Development/firmware dependencies
  misoc = python3Packages.buildPythonPackage rec {
    name = "misoc";
    
    src = fetchFromGitHub {
      owner = "m-labs";
      repo = "misoc";
      rev = "6e9c1a894312a81b534482949cbfc5f47842edd9";
      sha256 = "0y4jh60bmpzzh06k2gzxl3pqzbvvg8ipz029hvmi8d05hzf4kcf3";
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
      rev = "83b209e3a1d2a933909d7662bff11b06631f970c";
      sha256 = "05lngn8n9v613x4kzizbdc4w96kyc8ywv7l946mq680jb3zjjsgn";
    };

    propagatedBuildInputs = with python3Packages; [ colorama sphinx sphinx_rtd_theme ];

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
      rev = "bcbc5346c71ad8f7a1a0b7771a9d126b18fdf558";
      sha256 = "1hslm2nn2z1bl84ya4fsab3pvcdmbziwn7zkai0cm3bv525fjxxd";
    };

    propagatedBuildInputs = with python3Packages; [ pyserial prettytable msgpack migen ];

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

  # not using the nixpkgs version because it is Python 2 and an "application"
  lit = python3Packages.buildPythonPackage rec {
    pname = "lit";
    version = "0.7.1";

    src = python3Packages.fetchPypi {
      inherit pname version;
      sha256 = "ecef2833aef7f411cb923dac109c7c9dcc7dbe7cafce0650c1e8d19c243d955f";
    };

    # Non-standard test suite. Needs custom checkPhase.
    doCheck = false;

    meta = with stdenv.lib; {
      description = "Portable tool for executing LLVM and Clang style test suites";
      homepage = http://llvm.org/docs/CommandGuide/lit.html;
      license = licenses.ncsa;
    };
  };

  outputcheck = python3Packages.buildPythonApplication rec {
    pname = "outputcheck";
    version = "0.4.2";

    src = fetchFromGitHub {
      owner = "stp";
      repo = "OutputCheck";
      rev = "e0f533d3c5af2949349856c711bf4bca50022b48";
      sha256 = "1y27vz6jq6sywas07kz3v01sqjd0sga9yv9w2cksqac3v7wmf2a0";
    };
    prePatch = "echo ${version} > RELEASE-VERSION";

    meta = with stdenv.lib; {
      description = "A tool for checking tool output inspired by LLVM's FileCheck";
      homepage    = "https://github.com/stp/OutputCheck";
      license     = licenses.bsd3;
    };
  };


  # Documentation building dependencies
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
    version = "2.0.0";

    src = python3Packages.fetchPypi {
      inherit pname version;
      sha256 = "0nk36zqq5ipxqx9izz2iazb3iraasanv3nm05bjr21gw42zgkz22";
    };

    buildInputs = [ python3Packages.setuptools_scm ];
    propagatedBuildInputs = [ wavedrom ] ++ (with python3Packages; [ sphinx xcffib cairosvg ]);
    doCheck = false;

    meta = with stdenv.lib; {
      description = "A Sphinx extension that allows including WaveDrom diagrams";
      homepage    = "https://pypi.org/project/sphinxcontrib-wavedrom/";
      license     = licenses.mit;
    };
  };
}
