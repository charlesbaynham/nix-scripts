{ pkgs ? import <nixpkgs> {} }:
let
  migen = (pkgs.callPackage ../artiq-fast/pkgs/python-deps.nix {}).migen;
  ise = import ./ise.nix { inherit pkgs; };
  buildUrukulCpld = {version, src}: pkgs.stdenv.mkDerivation {
    name = "urukul-cpld-${version}";
    inherit src;
    buildInputs = [(pkgs.python3.withPackages(ps: [migen]))] ++ (builtins.attrValues ise);
    phases = ["buildPhase" "installPhase"];
    buildPhase = "python $src/urukul_impl.py";
    installPhase = 
      ''
      mkdir -p $out $out/nix-support
      cp build/urukul.jed $out
      echo file binary-dist $out/urukul.jed >> $out/nix-support/hydra-build-products
      '';
  };
in
  {
    urukul-cpld-master = buildUrukulCpld {
      version = "master";
      src = <urukulSrc>;
    };
    urukul-cpld-release = buildUrukulCpld rec {
      version = "1.3.1";
      src = pkgs.fetchFromGitHub {
        owner = "quartiq";
        repo = "urukul";
        rev = "v${version}";
        sha256 = "1nvarspqbf9f7b27j34jkkh4mj6rwrlmccmfpz5nnzk3h2j6zbqc";
      };
    };
  }
