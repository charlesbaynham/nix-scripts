{ pkgs, version, src, target }:

let
  wfvm = import ../../wfvm.nix { inherit pkgs; };
  libiconv-filename = "libiconv-1.15-h1df5818_7.tar.bz2";
  libiconv = pkgs.fetchurl {
    url = "https://anaconda.org/anaconda/libiconv/1.15/download/win-64/${libiconv-filename}";
    sha256 = "0p431madykrjmi9sbl2sy9kzb0l3vhgs677i8q7cx8g210ab5g52";
  };
  vc14-filename = "vc-14.1-h0510ff6_4.tar.bz2";
  vc14 = pkgs.fetchurl {
    url = "https://anaconda.org/anaconda/vc/14.1/download/win-64/${vc14-filename}";
    sha256 = "0nsyxph667x8ky1nybakpnk816dkrzbf1684jd7pp6wm5x73p34v";
  };
  vs2015_runtime-filename = "vs2015_runtime-14.16.27012-hf0eaf9b_2.tar.bz2";
  vs2015_runtime = pkgs.fetchurl {
    url = "https://anaconda.org/anaconda/vs2015_runtime/14.16.27012/download/win-64/${vs2015_runtime-filename}";
    sha256 = "1gbm6i6nkp8linmak5mm42hj1nzqd5ppak8kv1n3wfn52p21ngvs";
  };
  build = wfvm.utils.wfvm-run {
    name = "build-binutils";
    image = wfvm.makeWindowsImage { installCommands = with wfvm.layers; [ anaconda3 msys2 (msys2-packages (import ./msys_packages.nix { inherit pkgs; } )) ]; };
    script = ''
      # Create a fake channel to work around another pile of bugs and cretinous design decisions from conda.
      ${wfvm.utils.win-exec}/bin/win-exec "mkdir fake-channel && mkdir fake-channel\win-64"
      ln -s ${libiconv} ${libiconv-filename}
      ${wfvm.utils.win-put}/bin/win-put ${libiconv-filename} ./fake-channel/win-64
      ln -s ${vc14} ${vc14-filename}
      ${wfvm.utils.win-put}/bin/win-put ${vc14-filename} ./fake-channel/win-64
      ln -s ${vs2015_runtime} ${vs2015_runtime-filename}
      ${wfvm.utils.win-put}/bin/win-put ${vs2015_runtime-filename} ./fake-channel/win-64
      ${wfvm.utils.win-exec}/bin/win-exec ".\Anaconda3\scripts\activate && conda index fake-channel"

      cp --no-preserve=mode,ownership -R ${./binutils-recipe} binutils
      sed -i s/##TARGET##/${target}/g binutils/*
      sed -i s/##VERSION##/${version}/g binutils/*
      ${wfvm.utils.win-put}/bin/win-put binutils .
      tar xjf ${src}
      patch -d binutils-${version} -p1 < ${./binutils-hack-libiconv.patch}
      tar cjf src.tar.bz2 binutils-${version}
      ${wfvm.utils.win-put}/bin/win-put src.tar.bz2 .

      ${wfvm.utils.win-exec}/bin/win-exec ".\Anaconda3\scripts\activate && conda build --no-anaconda-upload --no-test -c file:///C:/users/wfvm/fake-channel --override-channels binutils"

      ${wfvm.utils.win-get}/bin/win-get "Anaconda3/conda-bld/win-64/binutils-${target}-${version}-0.tar.bz2"
    '';
  };
in
  pkgs.runCommand "conda-windows-binutils-${target}" { buildInputs = [ build ]; } ''
    wfvm-run-build-binutils
    mkdir -p $out/win-64 $out/nix-support
    cp binutils-*.tar.bz2 $out/win-64
    echo file conda $out/win-64/*.tar.bz2 >> $out/nix-support/hydra-build-products
    ''
