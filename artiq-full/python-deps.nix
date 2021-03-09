{ pkgs }:

rec {
  wavedrom = pkgs.python3Packages.buildPythonPackage rec {
    pname = "wavedrom";
    version = "2.0.3.post2";

    src = pkgs.python3Packages.fetchPypi {
      inherit pname version;
      sha256 = "13a4086417nv836s2wbj3f4r31gwapbyw5smgl00jsqizwsk96r3";
    };

    buildInputs = [ pkgs.python3Packages.setuptools_scm ];
    propagatedBuildInputs = with pkgs.python3Packages; [ svgwrite attrdict ];
    doCheck = false;

    meta = with pkgs.lib; {
      description = "WaveDrom compatible Python module and command line";
      homepage    = "https://pypi.org/project/wavedrom/";
      license     = licenses.mit;
    };
  };

  sphinxcontrib-wavedrom = pkgs.python3Packages.buildPythonPackage rec {
    pname = "sphinxcontrib-wavedrom";
    version = "2.1.1";

    src = pkgs.python3Packages.fetchPypi {
      inherit pname version;
      sha256 = "09xq4csdcil2x8mm38yd5k6lfbkazicvm278xnzwbfc9vghkqqs2";
    };

    buildInputs = [ pkgs.python3Packages.setuptools_scm ];
    propagatedBuildInputs = [ wavedrom ] ++ (with pkgs.python3Packages; [ sphinx xcffib cairosvg ]);
    doCheck = false;

    meta = with pkgs.lib; {
      description = "A Sphinx extension that allows including WaveDrom diagrams";
      homepage    = "https://pypi.org/project/sphinxcontrib-wavedrom/";
      license     = licenses.mit;
    };
  };
}
