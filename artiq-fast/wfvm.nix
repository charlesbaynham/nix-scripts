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
    rev = "4b497938ffd9fcddf84a3dbe2f01524395292adb";
    sha256 = "0m3kdbbcskqc1lf8b5f7ccbll9b7vkl4r00kbyx3yjb2rs6cqvil";
  };
in import "${wfvm}/wfvm" { pkgs = (import wfvm-pkgs {}); }
