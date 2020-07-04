let
  pkgs = import <nixpkgs> {};
  zc706 = import <zc706> { mozillaOverlay = import <mozillaOverlay>; };
  artiq-zynq = import <artiq-zynq> { mozillaOverlay = import <mozillaOverlay>; };
  addBuildProducts = drv: drv.overrideAttrs (oldAttrs: {
      installPhase = ''
        ${oldAttrs.installPhase}
        mkdir -p $out/nix-support
        for f in $out/*.elf ; do
          echo file binary-dist $f >> $out/nix-support/hydra-build-products
        done
      '';
    });
in
  (
    builtins.mapAttrs (name: drv:
      pkgs.lib.hydraJob (
        addBuildProducts drv
      )
    ) zc706.zc706
  ) // (
    builtins.mapAttrs (key: value: pkgs.lib.hydraJob value) artiq-zynq
  ) // {
    zc706-hitl-tests = pkgs.lib.hydraJob (pkgs.stdenv.mkDerivation {
      name = "zc706-hitl-tests";

      # requires patched Nix
      __networked = true;

      buildInputs = [
        pkgs.openssh pkgs.rsync
      ];
      phases = [ "buildPhase" ];

      buildPhase =
        ''
        export HOME=`mktemp -d`
        mkdir $HOME/.ssh
        cp /opt/hydra_id_rsa $HOME/.ssh/id_rsa
        cp /opt/hydra_id_rsa.pub $HOME/.ssh/id_rsa.pub
        echo "rpi-4 ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJu+HhQmQAclub9K/B3xUQ28lBg+MEdqSeBuQNZgPGKB" > $HOME/.ssh/known_hosts
        chmod 600 $HOME/.ssh/id_rsa

        bash ${<artiq-zynq>}/remote_run.sh -d ${artiq-zynq.zc706-simple-jtag}

        touch $out
        '';
    });
  }
