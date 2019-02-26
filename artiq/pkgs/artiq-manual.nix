{ stdenv, lib,
  git, fetchFromGitHub, fetchgit,
  python3Packages, texlive, texinfo
}:

with python3Packages;
let
  artiqVersion = import ./artiq-version.nix;

  # TODO: sphinx-argparse will be available from nixos-19.XX
  sphinx-argparse = buildPythonPackage rec {
    pname = "sphinx-argparse";
    version = "0.2.5";

    src = fetchPypi {
      inherit pname version;
      sha256 = "05wc8f5hb3jsg2vh2jf7jsyan8d4i09ifrz2c8fp6f7x1zw9iav0";
    };

    checkInputs = [
      pytest
    ];

    checkPhase = "py.test";

    propagatedBuildInputs = [
      sphinx
    ];

    meta = {
      description = "A sphinx extension that automatically documents argparse commands and options";
      homepage = https://github.com/ribozz/sphinx-argparse;
      license = lib.licenses.mit;
      maintainers = with lib.maintainers; [ clacke ];
    };
  };

  wavedrom = buildPythonPackage rec {
    pname = "wavedrom";
    version = "0.1";

    src = fetchPypi {
      inherit pname version;
      sha256 = "006w683zlmmwcw5xz1n5dwg34ims5jg3gl2700ql4wr0myjz6710";
    };

    buildInputs = [ setuptools_scm ];
    propagatedBuildInputs = [
      svgwrite attrdict
    ];
    doCheck = false;
  };

  sphinxcontrib-wavedrom-1_3_1 = buildPythonPackage rec {
    pname = "sphinxcontrib-wavedrom";
    version = "1.3.1";

    src = fetchPypi {
      inherit pname version;
      sha256 = "1q2hk630nz734cln2wwngjidlb7xyk6ly8qqlpsj259n9n2iab6v";
    };

    buildInputs = [ setuptools_scm ];
    propagatedBuildInputs = [
      sphinx
    ];
    doCheck = false;
  };

  sphinxcontrib-wavedrom-2_0_0 = buildPythonPackage rec {
    pname = "sphinxcontrib-wavedrom";
    version = "2.0.0";

    src = fetchPypi {
      inherit pname version;
      sha256 = "0nk36zqq5ipxqx9izz2iazb3iraasanv3nm05bjr21gw42zgkz22";
    };

    buildInputs = [ setuptools_scm ];
    propagatedBuildInputs = [
      sphinx wavedrom xcffib cairosvg
    ];
    doCheck = false;
  };

  sphinxcontrib-wavedrom =
    if builtins.compareVersions sphinx.version "1.8" == -1
    then sphinxcontrib-wavedrom-1_3_1
    else sphinxcontrib-wavedrom-2_0_0;

  latex = texlive.combine {
    inherit (texlive)
      scheme-basic latexmk cmap collection-fontsrecommended fncychap
      titlesec tabulary varwidth framed fancyvrb float wrapfig parskip
      upquote capt-of needspace;
  };

  isLatexPdfTarget = target: builtins.match "latexpdf.*" target != null;

  artiq-manual = target: stdenv.mkDerivation rec {
    name = "artiq-manual-${target}";
    version = artiqVersion;

    src = import ./artiq-src.nix { inherit fetchgit; };
    buildInputs = [
      sphinx sphinx_rtd_theme
      sphinx-argparse sphinxcontrib-wavedrom
    ] ++
      lib.optional (isLatexPdfTarget target) latex ++
      lib.optional (target == "texinfo") texinfo;

    preBuild = ''
        export VERSIONEER_OVERRIDE=${artiqVersion}
        cd doc/manual
      '';
    makeFlags = [ target ];

    installPhase =
      let
        dest = "$out/share/doc/artiq-manual";
      in
        if isLatexPdfTarget target
        then ''
            mkdir -p ${dest}
            cp _build/latex/ARTIQ.pdf ${dest}/

            mkdir -p $out/nix-support/
            echo doc-pdf manual ${dest} ARTIQ.pdf >> $out/nix-support/hydra-build-products
          ''
        else ''
            mkdir -p ${dest}
            cp -r _build/${target} ${dest}/

            mkdir -p $out/nix-support/
            echo doc manual ${dest}/${target} index.html >> $out/nix-support/hydra-build-products
          '';
  };

  # TODO: starting with NixOS 19.XX, drop sphinxcontrib-wavedrom-1_3_1
  # and simplify `targets`:
  targets = [
    "html" "singlehtml"
  ] ++ (lib.optional (builtins.compareVersions sphinxcontrib-wavedrom.version "2.0.0" != -1) "latexpdf");
in
  builtins.listToAttrs (map (target: { name = target; value = artiq-manual target; }) targets)
