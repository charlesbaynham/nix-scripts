{ pkgs, name, filename, baseurl, sha256 }:

let
  download = pkgs.fetchurl {
  	url = "${baseurl}${filename}";
  	inherit sha256;
  };
in
  pkgs.runCommand "conda-windows-${name}" { } ''
    mkdir -p $out/win-64 $out/nix-support
    ln -s ${download} $out/win-64/${filename}
    echo file conda $out/win-64/${filename} >> $out/nix-support/hydra-build-products
    ''
