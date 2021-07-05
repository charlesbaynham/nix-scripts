{ pkgs }:

let
  # Pin nixpkgs to avoid frequent resource-intensive Windows reinstallations on Hydra.
  wfvm-pkgs = pkgs.fetchFromGitHub {
    owner = "NixOS";
    repo = "nixpkgs";
    rev = "f8248ab6d9e69ea9c07950d73d48807ec595e923";
    sha256 = "009i9j6mbq6i481088jllblgdnci105b2q4mscprdawg3knlyahk";
  };
  wfvm = pkgs.fetchgit {
    url = "https://git.m-labs.hk/M-Labs/wfvm.git";
    rev = "6d9d9d91f66929574b7c8e5dacb3a611939bfaf1";
    sha256 = "02b7rs46ia3vvw0r98ih6i2xb6k952hza4i8h4gi0r8dzplsg004";
  };
in import "${wfvm}/wfvm" { pkgs = (import wfvm-pkgs {}); }
