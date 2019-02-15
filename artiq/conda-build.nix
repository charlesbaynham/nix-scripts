# We need to pass the whole source to conda for the git variables to work.
# recipe must be a string pointing to a path within the source.

{ pkgs ? import <nixpkgs> {}}:
{ name, src, recipe }:

with pkgs;

let
  condaDeps = [ stdenv.cc xorg.libSM xorg.libICE xorg.libXrender libselinux ];
  # Use the full Anaconda distribution, which already contains conda-build and its many dependencies,
  # so we don't have to manually deal with them.
  condaInstaller = fetchurl {
    url = "https://repo.anaconda.com/archive/Anaconda3-2018.12-Linux-x86_64.sh";
    sha256 = "006fgyz75ihd00qzbr1cny97xf1mwnzibbqyhskghraqgs2x068h";
  };
  condaSrcChmod = runCommand "conda-src-chmod" { } "mkdir $out; cp ${condaInstaller} $out/conda-installer.sh; chmod +x $out/conda-installer.sh";
  condaInstallerEnv = buildFHSUserEnv {
    name = "conda-installer-env";
    targetPkgs = pkgs: ([ condaSrcChmod ] ++ condaDeps);
  };

  # Git depends on libiconv
  condaIconv = fetchurl {
    url = "https://anaconda.org/conda-forge/libiconv/1.15/download/linux-64/libiconv-1.15-h14c3975_1004.tar.bz2";
    sha256 = "167j8jpr6mnyrzwp18dr52xr3xjsf39q452ag247ijlmp092v8ns";
  };
  condaGit = fetchurl {
    url = "https://anaconda.org/conda-forge/git/2.20.1/download/linux-64/git-2.20.1-pl526hc122a05_1001.tar.bz2";
    sha256 = "03s01xq2jj7zbx7jfzz6agy40jj7xkq6dwar3lw1z5j2rbmh8h0h";
  };
  condaInstalled = runCommand "conda-installed" { }
    ''
    ${condaInstallerEnv}/bin/conda-installer-env -c "${condaSrcChmod}/conda-installer.sh -p $out -b"
    ${condaInstallerEnv}/bin/conda-installer-env -c "$out/bin/conda install ${condaIconv}"
    ${condaInstallerEnv}/bin/conda-installer-env -c "$out/bin/conda install ${condaGit}"
    '';
  condaBuilderEnv = buildFHSUserEnv {
    name = "conda-builder-env";
    targetPkgs = pkgs: [ condaInstalled ] ++ condaDeps;
  };

in stdenv.mkDerivation {
  inherit name src;
  buildInputs = [ condaBuilderEnv ];
  buildCommand =
    ''
    HOME=`pwd`
    mkdir $out
    ${condaBuilderEnv}/bin/conda-builder-env -c "PYTHON=python conda build --no-anaconda-upload --no-test --output-folder $out $src/${recipe}"

    mkdir -p $out/nix-support
    echo file conda $out/noarch/*.tar.bz2 >> $out/nix-support/hydra-build-products
    '';
}
