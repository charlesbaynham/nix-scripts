{ stdenv, callPackage, fetchgit, python3Packages, qt5Full, binutils-or1k, llvm-or1k, llvmlite-artiq }:

let
  pythonDeps = callPackage ./python-deps.nix {};
in
  python3Packages.buildPythonPackage rec {
    name = "artiq-${version}";
    version = import ./artiq-version.nix;
    src = import ./artiq-src.nix { inherit fetchgit; };
    preBuild = "export VERSIONEER_OVERRIDE=${version}";
    propagatedBuildInputs = [ binutils-or1k llvm-or1k llvmlite-artiq qt5Full ]
      ++ (with pythonDeps; [ levenshtein pyqtgraph-qt5 quamash pythonparser asyncserial ])
      ++ (with python3Packages; [ aiohttp pygit2 numpy dateutil scipy prettytable pyserial h5py pyqt5 ]);
    checkPhase = "python -m unittest discover -v artiq.test";
    meta = with stdenv.lib; {
      description = "A leading-edge control system for quantum information experiments";
      homepage = https://m-labs/artiq;
      license = licenses.lgpl3;
      #maintainers = [ maintainers.sb0 ];
      platforms = [ "x86_64-linux" ];
    };
  }
