#!/usr/bin/env bash

set -e

nix-build -E "
let
  pkgs = import <nixpkgs> {};
  wfvm = import ../wfvm/default.nix { inherit pkgs; };
in
  wfvm.utils.wfvm-run {
    name = \"get-conda-packages\";
    image = wfvm.makeWindowsImage { installCommands = [ wfvm.layers.anaconda3 ]; };
    # TODO: fix wfvm login expiry and also remove 'date' workarounds below
    #fakeRtc = false;
    isolateNetwork = false;
    script = ''
      cat > getcondapackages.bat << EOF
      date 06-22-20
      call conda config --prepend channels https://conda.m-labs.hk/artiq-beta
      call conda config --append channels conda-forge
      call conda create -n artiq -y
      call conda install --dry-run --json -n artiq artiq > packages.json
      date 04-20-20
      EOF
      \${wfvm.utils.win-put}/bin/win-put getcondapackages.bat
      \${wfvm.utils.win-exec}/bin/win-exec '.\Anaconda3\Scripts\activate && getcondapackages'
      \${wfvm.utils.win-get}/bin/win-get packages.json
    '';
  }
"

./result/bin/wfvm-run-get-conda-packages

python -c "
import json

with open('packages.json') as json_file:
    packages = json.load(json_file)

with open('packages_noarch.txt', 'w') as list_noarch:
    with open('packages_win-64.txt', 'w') as list_win64:
        for fetch in packages['actions']['FETCH']:
            if 'm-labs' not in fetch['channel']:
                if fetch['subdir'] == 'noarch':
                    list = list_noarch
                elif fetch['subdir'] == 'win-64':
                    list = list_win64
                else:
                    raise ValueError
                url = fetch['url']
                if url.endswith('.conda'):
                  url = url[:-6] + '.tar.bz2'
                print(url, file=list)
"

for type in "noarch" "win-64"; do
  echo Downloading $type packages
  out=conda_$type\_packages.nix
  echo "{ pkgs } : [" > $out
  while read package; do
    hash=$(nix-prefetch-url $package)
    echo "
(pkgs.fetchurl {
  url = \"$package\";
  sha256 = \"$hash\";
})" >> $out
  done < packages_$type.txt
  echo "]" >> $out
done

rm result getcondapackages.bat packages.json packages_noarch.txt packages_win-64.txt
