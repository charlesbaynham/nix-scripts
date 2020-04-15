{ python3Packages, runCommand }:

# Note: we do not use fetchgit but a local copy instead to avoid
# chicken-and-egg problem if reinstalling nixbld.m-labs.hk from scratch.
with python3Packages; buildPythonPackage rec {
  name = "rfq";
  src = ./src;
  propagatedBuildInputs = [ flask flask_mail python-dotenv ];
}
