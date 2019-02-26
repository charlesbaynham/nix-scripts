{ stdenv, lib, fetchgit, python3Packages, texlive, texinfo, sphinx-argparse, sphinxcontrib-wavedrom }:

let
  artiqVersion = import ./artiq-version.nix;

  isLatexPdfTarget = target: builtins.match "latexpdf.*" target != null;

  latex = texlive.combine {
    inherit (texlive)
      scheme-basic latexmk cmap collection-fontsrecommended fncychap
      titlesec tabulary varwidth framed fancyvrb float wrapfig parskip
      upquote capt-of needspace;
  };

  artiq-manual = target: stdenv.mkDerivation rec {
    name = "artiq-manual-${target}-${version}";
    version = artiqVersion;

    src = import ./artiq-src.nix { inherit fetchgit; };
    buildInputs = [
      python3Packages.sphinx python3Packages.sphinx_rtd_theme
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
  targets = [ "html" ] ++ (lib.optional (builtins.compareVersions sphinxcontrib-wavedrom.version "2.0.0" != -1) "latexpdf");
in
  builtins.listToAttrs (map (target: { name = "artiq-manual-${target}"; value = artiq-manual target; }) targets)
