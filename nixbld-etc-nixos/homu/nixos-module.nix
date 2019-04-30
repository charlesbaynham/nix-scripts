{ config, pkgs, lib, ... }:
with lib;
let
  homu = pkgs.callPackage ./pkg.nix {};

  toToml = key: value:
    let valueString =
      if builtins.isString value
      then "\"" + (builtins.replaceStrings ["\"" "\\"] ["\\\"" "\\\\"] value) + "\""
      else toString value;
    in "${key} = ${valueString}\n";

  defaultConfig = {
    db = {
      file = "/var/db/homu/main.db";
    };
  };
  cfg = config.services.homu;
  homuConfig = defaultConfig // cfg.config;
  configFilter = f:
    filterAttrs (key: value: f value) homuConfig;
  topLevelConfig =
    configFilter (value: ! builtins.isAttrs value);
  configSections =
    configFilter (value: builtins.isAttrs value);

  configFile = builtins.toFile "config.toml" (
    builtins.concatStringsSep "" (
      (attrsets.mapAttrsToList toToml topLevelConfig) ++
      (builtins.concatLists (attrsets.mapAttrsToList
        (sectionName: sectionConfig:
          [ "[${sectionName}]\n" ] ++
          (attrsets.mapAttrsToList toToml sectionConfig)
        ) configSections)
      ))
  );

  dbFile = homuConfig.db.file;
in

{
  options.services.homu = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable the bot";
    };
    user = mkOption {
      type = types.str;
      default = "nobody";
    };
    group = mkOption {
      type = types.str;
      default = "nogroup";
    };
    config = mkOption {
      description = "Structured data for config.toml";
      type = with types; attrsOf unspecified;
    };
  };

  config = mkIf cfg.enable {
    systemd.services.homu-dbdir = {
      description = "Homu bot database directory";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = [
          "${pkgs.coreutils}/bin/mkdir -p ${dirOf dbFile}"
              "${pkgs.coreutils}/bin/chown -R ${cfg.user}:${cfg.group} ${dirOf dbFile}"
              ];
      };
    };
    systemd.services.homu = {
      description = "Homu bot";
      wantedBy = [ "multi-user.target" ];
      requires = [ "homu-dbdir.service" ];
      after    = [ "network.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${homu}/bin/homu -c ${configFile}";

        Restart = "always";
        RestartSec = "5sec";

        User = cfg.user;
        Group = cfg.group;
      };
    };
  };

}
  
