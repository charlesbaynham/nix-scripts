{ config, pkgs }:

let
  pkg = pkgs.callPackage ./pkg.nix {};
in {
  type = "normal";
  pythonPackages = self: [ pkg ];
  module = "rfq:app";
  env = [
    "FLASK_MAIL_SERVER=ssl.serverraum.org"
    "FLASK_MAIL_PORT=465"
    "FLASK_MAIL_USE_SSL=True"
    "FLASK_MAIL_USERNAME=sales@m-labs.hk"
    "FLASK_MAIL_PASSWORD=${import /etc/nixos/secret/sales_password.nix}"
    "FLASK_MAIL_RECIPIENT=sales@m-labs.hk"
    "FLASK_MAIL_SENDER=sales@m-labs.hk"
  ];
  socket = "${config.services.uwsgi.runDir}/uwsgi-rfq.sock";
  # allow access from nginx
  chmod-socket = 666;
}
