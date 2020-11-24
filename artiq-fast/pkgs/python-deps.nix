{ stdenv, fetchgit, fetchFromGitHub, python3Packages, misoc-new }:

rec {
  # User dependencies
  sipyco = python3Packages.buildPythonPackage rec {
    name = "sipyco";
    version = "1.1";
    src = fetchFromGitHub {
      owner = "m-labs";
      repo = "sipyco";
      rev = "v${version}";
      sha256 = "09vyrzfhnbp65ybd7w2g96gvvnhzafpn72syls2kbg2paqjjf9gs";
    };
    propagatedBuildInputs = with python3Packages; [ numpy ];
  };

  asyncserial = python3Packages.buildPythonPackage rec {
    name = "asyncserial";
    version = "0.1";
    src = fetchFromGitHub {
      owner = "m-labs";
      repo = "asyncserial";
      rev = "d95bc1d6c791b0e9785935d2f62f628eb5cdf98d";
      sha256 = "0yzkka9jk3612v8gx748x6ziwykq5lr7zmr9wzkcls0v2yilqx9k";
    };
    propagatedBuildInputs = with python3Packages; [ pyserial ];
  };

  pythonparser = python3Packages.buildPythonPackage rec {
    name = "pythonparser";
    version = "1.3";
    src = fetchFromGitHub {
      owner = "m-labs";
      repo = "pythonparser";
      rev = "5b391fe86f43bb9f4f96c5bc0532e2a112db2936";
      sha256 = "1gw1fk4y2l6bwq0fg2a9dfc1rvq8cv492dyil96amjdhsxvnx35b";
    };
    patches = [ ./pythonparserver.patch ];
    propagatedBuildInputs = with python3Packages; [ regex ];
  };

  pyqtgraph-qt5 = python3Packages.buildPythonPackage rec {
    name = "pyqtgraph_qt5-${version}";
    version = "0.11.0";
    doCheck = false;
    pythonImportsCheck = [ "pyqtgraph" ];
    src = fetchFromGitHub {
      owner = "pyqtgraph";
      repo = "pyqtgraph";
      rev = "pyqtgraph-${version}";
      sha256 = "03fvpkqdn80ni51msvyivmghw41qk4vplwdqndkvzzzlppimdjbn";
    };
    propagatedBuildInputs = with python3Packages; [ scipy numpy pyqt5 pyopengl ];
  };

  # Development/firmware dependencies
  artiq-netboot = python3Packages.buildPythonPackage rec {
    name = "artiq-netboot";

    src = fetchgit {
      url = "https://git.m-labs.hk/m-labs/artiq-netboot.git";
      rev = "04f69eb07df73abe4b89fde2c24084f7664f2104";
      sha256 = "0ql4fr8m8gpb2yql8aqsdqsssxb8zqd6l65kl1f6s9845zy7shs9";
    };
  };

  misoc = python3Packages.buildPythonPackage {
    name = "misoc";
    
    src = if misoc-new
      then (fetchFromGitHub {
        owner = "m-labs";
        repo = "misoc";
        rev = "a8a33f6559da77a1d3ffc383939c1dc3a4a7795d";
        sha256 = "145hzxs6cf8p46m1lvrdr9af5c1vp0ix57adk9d8iwqj1rjw13f7";
        fetchSubmodules = true;
      })
      else (fetchFromGitHub {
        owner = "m-labs";
        repo = "misoc";
        rev = "7e5fe8d38835175202dad2c51d37b20b76fd9e16";
        sha256 = "0i8bppz7x2s45lx9n49c0r87pqps09z35yzc17amvx21qsplahxn";
        fetchSubmodules = true;
      });

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
      rev = "a5cc037a510b68374d2b7cd8cd13e6f17534cd2a";
      sha256 = "03y8k3a0kakh1ial6y2g7gwm9h53x8inbsw9f1rr18314j4l0lfk";
    };

    propagatedBuildInputs = with python3Packages; [ colorama ];

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
      rev = "ac877ac5975411a438415f824e182338ed773529";
      sha256 = "1lkb7cyj87bq4y0hp6379jq4q4lm2ijldccpyhawiizcfkawxa10";
    };

    propagatedBuildInputs = with python3Packages; [ migen misoc ];

    meta = with stdenv.lib; {
      description = "JESD204B core for Migen/MiSoC";
      homepage    = "https://m-labs.hk/migen";
      license     = licenses.bsd2;
      platforms   = platforms.unix;
    };
  };

  fastnumbers = python3Packages.buildPythonPackage rec {
    pname = "fastnumbers";
    version = "2.2.1";

    src = python3Packages.fetchPypi {
      inherit pname version;
      sha256 = "0j15i54p7nri6hkzn1wal9pxri4pgql01wgjccig6ar0v5jjbvsy";
    };

    meta = with stdenv.lib; {
      description = "Super-fast and clean conversions to numbers";
      homepage    = "https://github.com/SethMMorton/fastnumbers";
      license     = licenses.mit;
      platforms   = platforms.unix;
    };
  };

  ramda = python3Packages.buildPythonPackage {
    name = "ramda";

    src = fetchFromGitHub {
      owner = "peteut";
      repo = "ramda.py";
      rev = "bd58f8e69d0e9a713d9c1f286a1ac5e5603956b1";
      sha256 = "0qzd5yp9lbaham8p1wiymdjapzbqsli7lvngv24c3z4ybd9jlq9g";
    };

    nativeBuildInputs = [ python3Packages.pbr ];
    propagatedBuildInputs = [ python3Packages.future fastnumbers ];

    checkInputs = [ python3Packages.pytest python3Packages.pytest-flake8 ];
    checkPhase = "pytest";

    preBuild = ''
      export PBR_VERSION=0.0.1
    '';

    meta = with stdenv.lib; {
      description = "Ramda, ported to Python";
      homepage    = "https://github.com/peteut/ramda.py";
      license     = licenses.mit;
      platforms   = platforms.unix;
    };
  };

  migen-axi = python3Packages.buildPythonPackage {
    name = "migen-axi";

    src = fetchFromGitHub {
      owner = "peteut";
      repo = "migen-axi";
      rev = "cf992cc71d376b24168411e106016cd1a5707eee";
      sha256 = "0n4hiic81rzkqr2nz9gfrbrfg5h5gps7g29nkykllc0iqbl8p4kk";
    };

    nativeBuildInputs = [ python3Packages.pbr ];
    propagatedBuildInputs = [ python3Packages.click python3Packages.numpy python3Packages.toolz python3Packages.jinja2 ramda migen misoc ];

    postPatch = ''
      substituteInPlace requirements.txt \
        --replace "jinja2==2.10.3" "jinja2"
      substituteInPlace requirements.txt \
        --replace "future==0.18.2" "future"
      substituteInPlace requirements.txt \
        --replace "ramda==0.5.5" "ramda"
      substituteInPlace requirements.txt \
        --replace "colorama==0.4.3" "colorama"
    '';


    checkInputs = [ python3Packages.pytest python3Packages.pytest-flake8 ];
    checkPhase = "pytest";

    preBuild = ''
      export PBR_VERSION=0.0.1
    '';

    meta = with stdenv.lib; {
      description = "AXI support for Migen/MiSoC";
      homepage    = "https://github.com/peteut/migen-axi";
      license     = licenses.mit;
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
}
