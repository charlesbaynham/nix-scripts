# We need to pass the whole source to conda for the git variables to work.
# recipe must be a string pointing to a path within the source.

{ pkgs }:
{ name ? null
, src
, pname ? null
, version ? null
, recipe ? "fake-conda"
}:

# Check that either name is specified or both pname & version are specified.
assert (name == null) -> pname != null && version != null;
assert (name != null) -> pname == null && version == null;
let
  condaBuilderEnv = import ./builder-env.nix { inherit pkgs; };
  realName = if (name != null) then name else "${pname}-${version}";
in pkgs.stdenv.mkDerivation {
  name = realName;
  inherit src;
  buildCommand =
    ''
    HOME=`pwd`
    mkdir $out
    ${condaBuilderEnv}/bin/conda-builder-env -c "conda build --no-anaconda-upload --no-test --output-folder $out $src/${recipe}"

    mkdir -p $out/nix-support
    echo file conda $out/*/*.tar.bz2 >> $out/nix-support/hydra-build-products
    '';
}
