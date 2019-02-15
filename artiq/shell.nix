{ pkgs ? import <nixpkgs> {}}:

let 
  artiqpkgs = import ./default.nix { inherit pkgs; };
in
  pkgs.mkShell {
    buildInputs = with artiqpkgs; [ binutils-or1k llvm-or1k llvmlite artiq ];
  }
