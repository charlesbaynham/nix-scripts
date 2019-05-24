{ config, pkgs, lib, ... }:
with lib;
let
  makeBackup = pkgs.writeScript "make-backup" ''
    #!${pkgs.bash}/bin/bash
    ${pkgs.gnutar}/bin/tar cf - /etc/nixos | \
        ${pkgs.bzip2}/bin/bzip2 | \
        ${pkgs.gnupg}/bin/gpg --symmetric --batch --passphrase-file /etc/nixos/secret/backup-passphrase | \
        ${pkgs.rclone}/bin/rclone rcat --config /etc/nixos/secret/rclone.conf dropbox:backup-`date +%F`.tar.bz2.gpg
    echo Backup done
  '';
  cfg = config.services.homu;
in
{
  options.services.mlabs-backup = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable backups";
    };
  };

  config = mkIf cfg.enable {
    systemd.services.mlabs-backup = {
      description = "M-Labs backup";
      serviceConfig = {
        Type = "oneshot";
        User = "root";
        Group = "root";
        ExecStart = "${makeBackup}";
      };
    };

    systemd.timers.mlabs-backup = {
      description = "M-Labs backup";
      wantedBy = [ "timers.target" ];
      timerConfig.OnCalendar = "weekly";
    };
  };
}
