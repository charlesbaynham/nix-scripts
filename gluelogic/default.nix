{ pkgs ? import <nixpkgs> {} }:
let
  artiqpkgs = import ../artiq-fast/pkgs/python-deps.nix { inherit (pkgs) stdenv fetchgit fetchFromGitHub python3Packages; misoc-new = true; };
  ise = import ./ise.nix { inherit pkgs; };
  vivado = import ../artiq-fast/vivado.nix { inherit pkgs; };
  buildUrukulCpld = {version, src}: pkgs.stdenv.mkDerivation {
    name = "urukul-cpld-${version}";
    inherit src;
    buildInputs = [(pkgs.python3.withPackages(ps: [artiqpkgs.migen]))] ++ (builtins.attrValues ise);
    phases = ["buildPhase" "installPhase"];
    buildPhase = "python $src/urukul_impl.py";
    installPhase = 
      ''
      mkdir -p $out $out/nix-support
      cp build/urukul.jed $out
      echo file binary-dist $out/urukul.jed >> $out/nix-support/hydra-build-products
      '';
  };
  buildMirnyCpld = {version, src}: pkgs.stdenv.mkDerivation {
    name = "mirny-cpld-${version}";
    inherit src;
    buildInputs = [(pkgs.python3.withPackages(ps: [artiqpkgs.migen]))] ++ (builtins.attrValues ise);
    phases = ["buildPhase" "installPhase"];
    buildPhase = "python $src/mirny_impl.py";
    installPhase = 
      ''
      mkdir -p $out $out/nix-support
      cp build/mirny.jed $out
      echo file binary-dist $out/mirny.jed >> $out/nix-support/hydra-build-products
      '';
  };
in
  {
    urukul-cpld-master = buildUrukulCpld {
      version = "master";
      src = <urukulSrc>;
    };
    urukul-cpld-release = buildUrukulCpld rec {
      version = "1.4.0";
      src = pkgs.fetchFromGitHub {
        owner = "quartiq";
        repo = "urukul";
        rev = "v${version}";
        sha256 = "1962jpzqzn22cwkcmfnvwqlj5i89pljhgfk64n6pk73clir9mp0w";
      };
    };
    urukul-cpld-legacy = buildUrukulCpld rec {
      version = "1.3.1";
      src = pkgs.fetchFromGitHub {
        owner = "quartiq";
        repo = "urukul";
        rev = "v${version}";
        sha256 = "1nvarspqbf9f7b27j34jkkh4mj6rwrlmccmfpz5nnzk3h2j6zbqc";
      };
    };
    mirny-cpld-master = buildMirnyCpld {
      version = "master";
      src = <mirnySrc>;
    };
    mirny-cpld-release = buildMirnyCpld rec {
      version = "0.2.4";
      src = pkgs.fetchFromGitHub {
        owner = "quartiq";
        repo = "mirny";
        rev = "v${version}";
        sha256 = "0fyz0g1h1s54zdivkfqhgyhpq7gjkl9kxkcfy3104p2f889l1vgw";
      };
    };
    fastino-fpga = pkgs.stdenv.mkDerivation {
      name = "fastino-fpga";
      src = <fastinoSrc>;
      buildInputs = [(pkgs.python3.withPackages(ps: [artiqpkgs.migen artiqpkgs.misoc]))] ++ [pkgs.yosys pkgs.nextpnr pkgs.icestorm];
      phases = ["buildPhase" "installPhase"];
      buildPhase = "python $src/fastino_phy.py";
      installPhase =
        ''
        mkdir -p $out $out/nix-support
        cp build/fastino.bin $out
        echo file binary-dist $out/fastino.bin >> $out/nix-support/hydra-build-products
        '';
    };
    phaser-fpga = pkgs.stdenv.mkDerivation {
      name = "phaser-fpga";
      src = <phaserSrc>;
      patchPhase = ''
        substituteInPlace phaser.py \
          --replace "Platform(load=True)" \
                    "Platform()"
      '';

      buildInputs = [ (pkgs.python3.withPackages(ps: [ artiqpkgs.migen artiqpkgs.misoc ])) ] ++ [ vivado ];
      buildPhase = "python phaser.py";
      installPhase =
        ''
        mkdir -p $out $out/nix-support
        cp build/phaser.bit $out
        echo file binary-dist $out/phaser.bit >> $out/nix-support/hydra-build-products
        '';
      dontFixup = true;

      doCheck = true;
      checkInputs = [ pkgs.python3Packages.pytest ];
      checkPhase = "pytest";
    };
  }
