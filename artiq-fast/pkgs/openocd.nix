{ stdenv, buildEnv, lib, fetchFromGitHub, openocd }:
let
  bscan_spi_bitstreams-pkg = stdenv.mkDerivation {
    name = "bscan_spi_bitstreams";
    src = fetchFromGitHub {
      owner = "quartiq";
      repo = "bscan_spi_bitstreams";
      rev = "01d8f819f15baf9a8cc5d96945a51e4d267ff564";
      sha256 = "1zqv47kzgvbn4c8cr019a6wcja7gn5h1z4kvw5bhpc72fyhagal9";
    };
    phases = ["installPhase"];
    installPhase =
    ''
    mkdir -p $out/share/bscan-spi-bitstreams
    cp $src/*.bit $out/share/bscan-spi-bitstreams
    '';
  };
  # https://docs.lambdaconcept.com/screamer/troubleshooting.html#error-contents-differ
  openocd-fixed = openocd.overrideAttrs(oa: {
    patches = oa.patches or [] ++ [ ./openocd-jtagspi.nix ];
  });
in
  buildEnv {
    name = "openocd-bscanspi";
    paths = [ openocd-fixed bscan_spi_bitstreams-pkg ];
  }
