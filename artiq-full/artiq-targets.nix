{ pkgs
, artiqVersion
, sinaraSystemsSrc
}:

let
  jsons =
    map (jsonFile: builtins.fromJSON (
      builtins.readFile (sinaraSystemsSrc + "/${jsonFile}")
    )) (
      builtins.attrNames (
        pkgs.lib.filterAttrs (name: type:
          type != "directory" &&
          builtins.match ".+\\.json" name != null
        ) (builtins.readDir sinaraSystemsSrc)
      )
    );
  kasli = builtins.listToAttrs (
    builtins.map ({ variant, base, ... }: {
      name = "artiq-board-kasli-${variant}";
      value = {
        target = "kasli";
        inherit variant;
        src = sinaraSystemsSrc + "/${variant}.json";
        buildCommand = "python -m artiq.gateware.targets.kasli_generic $src";
        standalone = base == "standalone";
      };
    }) (
      builtins.filter (json:
        pkgs.lib.strings.versionAtLeast artiqVersion (
          if json ? min_artiq_version
          then json.min_artiq_version
          else "0"
        )
      ) jsons
    )
  );
in
kasli // {
  artiq-board-sayma-rtm = {
    target = "sayma";
    variant = "rtm";
    buildCommand = "python -m artiq.gateware.targets.sayma_rtm";
  };
  artiq-board-sayma-satellite = {
    target = "sayma";
    variant = "satellite";
    buildCommand = "python -m artiq.gateware.targets.sayma_amc";
  };
  artiq-board-metlino-master = {
    target = "metlino";
    variant = "master";
    buildCommand = "python -m artiq.gateware.targets.metlino";
  };
  artiq-board-kc705-nist_qc2 = {
    target = "kc705";
    variant = "nist_qc2";
  };
} // (pkgs.lib.optionalAttrs (pkgs.lib.strings.versionAtLeast artiqVersion "6.0") {
  artiq-board-sayma-satellite-st = {
    target = "sayma";
    variant = "satellite";
    buildCommand = "python -m artiq.gateware.targets.sayma_amc --jdcg-type syncdds";
  };
})
