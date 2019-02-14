{ pkgs ? import <nixpkgs> {}}:
pkgs.fetchgit {
  url = "https://github.com/m-labs/artiq";
  rev = import ./artiq-rev.nix;
  sha256 = import ./artiq-hash.nix;
  deepClone = true;
}
