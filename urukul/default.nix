{ pkgs ? import <nixpkgs> {} }:
let
  migen = (pkgs.callPackage ../artiq/pkgs/python-deps.nix {}).migen;
  ise = import ./ise.nix { inherit pkgs; };
in
  {
    urukul-cpld = pkgs.stdenv.mkDerivation {
      name = "urukul-cpld";
      src = <urukulSrc>;
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
  }
