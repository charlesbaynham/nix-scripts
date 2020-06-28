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
    rev = "304a102b61ae1649739129510bbfc2f162e069b7";
    sha256 = "0ss7z5inp2fbrqjpp296iy04m8v3bwiajhwa7w5ijixva5v2mmg0";
  };
in import "${wfvm}/wfvm" { pkgs = (import wfvm-pkgs {}); }
