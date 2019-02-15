{ pkgs ? import <nixpkgs> {}, mainBuild}:

{
  foo = pkgs.runCommand "xxxxabcd" { } "echo ${mainBuild} > $out";
}
