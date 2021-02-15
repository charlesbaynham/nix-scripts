{ pkgs, artiq-fast }:
{ jobs }:

let 
  condaBuilderEnv = import ../artiq-fast/conda/builder-env.nix { inherit pkgs; };
in
  pkgs.runCommand "conda-channel" { }
    ''
    mkdir -p $out/noarch $out/linux-64 $out/win-64
    for storepath in ${pkgs.lib.concatMapStringsSep " " builtins.toString (builtins.attrValues jobs)}; do
      hydra_build_products=$storepath/nix-support/hydra-build-products
      if [ -f $hydra_build_products ]; then
        while IFS= read -r line; do
          type=`echo $line | cut -f2 -d " "`
          if [ $type == "conda" ]; then
            path=`echo $line | cut -f3 -d " "`
            arch=`echo $path | cut -f5 -d "/"`
            ln -s $path $out/$arch
          fi
        done < $hydra_build_products
      fi
    done
    cd $out
    ${condaBuilderEnv}/bin/conda-builder-env -c "conda index"
    ''
