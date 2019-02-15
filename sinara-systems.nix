{ pkgs ? import <nixpkgs> {}}:
{ mainBuild }:

{
  fooxx = pkgs.runCommand "xxxxabcd" { } "echo ${mainBuild} > $out";
}
