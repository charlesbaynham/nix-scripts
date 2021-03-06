{ lib, fetchgit, fetchFromGitHub, python3Packages, misoc-new }:

rec {
  # User dependencies
  sipyco = python3Packages.buildPythonPackage rec {
    pname = "sipyco";
    version = "1.2";
    src = fetchFromGitHub {
      owner = "m-labs";
      repo = "sipyco";
      rev = "v${version}";
      sha256 = "02x2s66x9bbzj82d823vjg2i73w7iqwvkrjbbyrsav6ccj7f90sj";
    };
    propagatedBuildInputs = with python3Packages; [ numpy ];
  };

  asyncserial = python3Packages.buildPythonPackage rec {
    pname = "asyncserial";
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
    pname = "pythonparser";
    version = "1.4";
    src = fetchFromGitHub {
      owner = "m-labs";
      repo = "pythonparser";
      rev = "5413ee5c9f8760e95c6acd5d6e88dabb831ad201";
      sha256 = "1b9p3pjnfaiaf2k0a3iq39aj2vymfxx139hqdqkd3q4awrwy1957";
    };
    propagatedBuildInputs = with python3Packages; [ regex ];
  };

  qasync = python3Packages.buildPythonPackage rec {
    pname = "qasync";
    version = "0.10.0";

    src = fetchFromGitHub {
      owner = "CabbageDevelopment";
      repo = "qasync";
      rev = "v${version}";
      sha256 = "1zga8s6dr7gk6awmxkh4pf25gbg8n6dv1j4b0by7y0fhi949qakq";
    };

    propagatedBuildInputs = [ python3Packages.pyqt5 ];

    checkInputs = [ python3Packages.pytest ];
    checkPhase = ''
      pytest -k 'test_qthreadexec.py' # the others cause the test execution to be aborted, I think because of asyncio
    '';
  };

  # Development/firmware dependencies
  artiq-netboot = python3Packages.buildPythonPackage rec {
    pname = "artiq-netboot";
    version = "unstable-2020-10-15";

    src = fetchgit {
      url = "https://git.m-labs.hk/m-labs/artiq-netboot.git";
      rev = "04f69eb07df73abe4b89fde2c24084f7664f2104";
      sha256 = "0ql4fr8m8gpb2yql8aqsdqsssxb8zqd6l65kl1f6s9845zy7shs9";
    };
  };

  misoc = python3Packages.buildPythonPackage {
    pname = "misoc";
    version = if misoc-new then "unstable-2021-08-04" else "unstable-2021-02-15";

    src = if misoc-new
      then (fetchFromGitHub {
        owner = "m-labs";
        repo = "misoc";
        rev = "fa663cd05129f1e10678ab132e7668569f787ead";
        sha256 = "1813llhlk5jyzyd1xmkcdziz48yx9m41p03pivv2sn7cja8l1l1x";
        fetchSubmodules = true;
      })
      else (fetchFromGitHub {
        owner = "m-labs";
        repo = "misoc";
        rev = "d84551418042cea0891ea743442e20684b51e77a";
        sha256 = "1id5qjr9dl4r3vi6jdn7dfpnr2wb08nrm3nfscn18clbbdxybyjn";
        fetchSubmodules = true;
      });

    # TODO: fix misoc bitrot and re-enable tests
    doCheck = false;

    propagatedBuildInputs = with python3Packages; [ pyserial jinja2 numpy asyncserial migen ];

    meta = with lib; {
      description = "A high performance and small footprint system-on-chip based on Migen";
      homepage    = "https://m-labs.hk/migen";
      license     = licenses.bsd2;
      platforms   = platforms.unix;
    };
  };

  migen = python3Packages.buildPythonPackage rec {
    pname = "migen";
    version = "unstable-2021-08-10";

    src = fetchFromGitHub {
      owner = "m-labs";
      repo = "migen";
      rev = "27dbf03edd75c32dc1706e2a1316950c3a8d452a";
      sha256 = "0c7c7bbc05cb8xvxd612cxr7mvsxhaim0apfh7ax32wi9ykpl1ad";
    };

    propagatedBuildInputs = with python3Packages; [ colorama ];

    meta = with lib; {
      description = "A Python toolbox for building complex digital hardware";
      homepage    = "https://m-labs.hk/migen";
      license     = licenses.bsd2;
      platforms   = platforms.unix;
    };
  };

  microscope = python3Packages.buildPythonPackage rec {
    pname = "microscope";
    version = "unstable-2019-05-17";

    src = fetchFromGitHub {
      owner = "m-labs";
      repo = "microscope";
      rev = "bcbc5346c71ad8f7a1a0b7771a9d126b18fdf558";
      sha256 = "1hslm2nn2z1bl84ya4fsab3pvcdmbziwn7zkai0cm3bv525fjxxd";
    };

    propagatedBuildInputs = with python3Packages; [ pyserial prettytable msgpack migen ];

    meta = with lib; {
      description = "Finding the bacteria in rotting FPGA designs";
      homepage    = "https://m-labs.hk/migen";
      license     = licenses.bsd2;
      platforms   = platforms.unix;
    };
  };

  jesd204b = python3Packages.buildPythonPackage rec {
    pname = "jesd204b";
    version = "unstable-2021-05-05";

    src = fetchFromGitHub {
      owner = "m-labs";
      repo = "jesd204b";
      rev = "bf1cd9014c8b7a9db67609f653634daaf3bcd39b";
      sha256 = "035csm6as4p75cjz7kd6gnras14856i2jzi9g1gd800g284hw9n3";
    };

    propagatedBuildInputs = with python3Packages; [ migen misoc ];

    meta = with lib; {
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

    meta = with lib; {
      description = "Super-fast and clean conversions to numbers";
      homepage    = "https://github.com/SethMMorton/fastnumbers";
      license     = licenses.mit;
      platforms   = platforms.unix;
    };
  };

  ramda = python3Packages.buildPythonPackage {
    pname = "ramda";
    version = "unstable-2019-02-01";

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

    meta = with lib; {
      description = "Ramda, ported to Python";
      homepage    = "https://github.com/peteut/ramda.py";
      license     = licenses.mit;
      platforms   = platforms.unix;
    };
  };

  migen-axi = python3Packages.buildPythonPackage {
    pname = "migen-axi";
    version = "unstable-2021-01-22";

    src = fetchFromGitHub {
      owner = "peteut";
      repo = "migen-axi";
      rev = "9439ee900358598cecc682db327aa30e506172b5";
      sha256 = "1z5s8ifq7fbpqi6sx2i87rmz63kbgh9ck94fs2qf21ixhxi46nm3";
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
      substituteInPlace requirements.txt \
        --replace "toolz==0.10.0" "toolz"
      substituteInPlace requirements.txt \
        --replace "pyserial==3.4" "pyserial"
    '';


    checkInputs = [ python3Packages.pytest python3Packages.pytest-timeout python3Packages.pytest-flake8 ];
    checkPhase = "pytest";

    preBuild = ''
      export PBR_VERSION=0.0.1
    '';

    meta = with lib; {
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

    meta = with lib; {
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

    meta = with lib; {
      description = "A tool for checking tool output inspired by LLVM's FileCheck";
      homepage    = "https://github.com/stp/OutputCheck";
      license     = licenses.bsd3;
    };
  };
}
