{ config, pkgs, lib, ... }:

with lib;
let
  hookPkg =
    { stdenv, makeWrapper, bash, coreutils, jq }:
    stdenv.mkDerivation rec {
      name = "hydra-www-hook";
      src = ./.;
      buildInputs = [ makeWrapper ];
      propagatedBuildInputs = [ bash coreutils jq ];
      phases = [ "unpackPhase" "installPhase" "fixupPhase" ];
      installPhase = ''
        mkdir -p $out/bin/
        cp hydra-www-hook.sh $out/bin/
        wrapProgram $out/bin/hydra-www-hook.sh \
          --prefix PATH : ${makeBinPath propagatedBuildInputs}
      '';
    };
  hook = pkgs.callPackage hookPkg {};

  hydraWwwOutputs = "/var/www/hydra-outputs";
  cfg = config.services.hydraWwwOutputs;
in
{
  options.services.hydraWwwOutputs = mkOption {
    type = with types; attrsOf (attrsOf (submodule {
      options = {
        job = mkOption {
          type = string;
        };
        httpPath = mkOption {
          type = string;
        };
        outputPath = mkOption {
          type = string;
        };
      };
    }));
  };

  config.services.hydra = {
    extraConfig = builtins.concatStringsSep "\n"
      (builtins.concatMap (vhost:
        builtins.attrValues (
          builtins.mapAttrs (name: cfg: ''
            <runcommand>
              job = ${cfg.job}
              command = ${hook}/bin/hydra-www-hook.sh ${hydraWwwOutputs}/${name}.conf ${cfg.httpPath} ${cfg.outputPath}
            </runcommand>
          '') cfg.${vhost}
        )) (builtins.attrNames cfg)
      );
  };

  config.systemd.services.hydra-www-outputs-init = {
    description = "Set up a hydra-owned directory for build outputs";
    wantedBy = [ "multi-user.target" ];
    requiredBy = [ "hydra-queue-runner.service" ];
    before = [ "hydra-queue-runner.service" "nginx.service" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = [
        "${pkgs.coreutils}/bin/mkdir -p ${hydraWwwOutputs}"
        ] ++
        (builtins.concatMap (vhost:
          map (name:
            "${pkgs.coreutils}/bin/touch ${hydraWwwOutputs}/${name}.conf"
          ) (builtins.attrNames cfg.${vhost})
        ) (builtins.attrNames cfg)) ++ [
          "${pkgs.coreutils}/bin/chown -R hydra-queue-runner:hydra ${hydraWwwOutputs}"
        ];
    };
  };

  # Allow the hook to reload nginx
  config.security.sudo.extraRules = [ {
    users = [ "hydra-queue-runner" ];
    commands = [ {
      command = "${config.systemd.package}/bin/systemctl reload nginx";
      options = [ "NOPASSWD" ];
    } ];
  } ];

  config.services.nginx = {
    virtualHosts = builtins.mapAttrs (vhost: cfg': {
      extraConfig = builtins.concatStringsSep "\n" (
        map (name:
          "include ${hydraWwwOutputs}/${name}.conf;"
        ) (builtins.attrNames cfg')
      );
    }) cfg;
  };
}
