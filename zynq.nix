let
  pkgs = import <nixpkgs> {};
  zynq-rs = import <zynq-rs> { mozillaOverlay = import <mozillaOverlay>; };
  artiq-zynq = import <artiq-zynq>;
  artiq-fast = import <artiq-fast> { inherit pkgs; };
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
    ) zynq-rs.zc706
  ) // (
    builtins.mapAttrs (key: value: pkgs.lib.hydraJob value) artiq-zynq
  ) // {
    gateware-sim = pkgs.lib.hydraJob (pkgs.stdenv.mkDerivation {
      name = "gateware-sim";
      buildInputs = [ artiq-fast.migen artiq-fast.migen-axi artiq-fast.artiq ];

      phases = [ "buildPhase" ];

      buildPhase =
        ''
        python -m unittest discover ${<artiq-zynq>}/src/gateware -v
        touch $out
        '';
    });
    zc706-hitl-tests = pkgs.lib.hydraJob (pkgs.stdenv.mkDerivation {
      name = "zc706-hitl-tests";

      # requires patched Nix
      __networked = true;

      buildInputs = [
        pkgs.netcat pkgs.openssh pkgs.rsync artiq-fast.artiq
      ];
      phases = [ "buildPhase" ];

      buildPhase =
        ''
        echo Power cycling board...
        (echo b; sleep 5; echo B) | nc -N 192.168.1.31 3131
        sleep 5
        echo Power cycle done.

        export USER=hydra
        export OPENOCD_ZYNQ=${<zynq-rs>}/openocd
        pushd ${<artiq-zynq>}
        bash ${<artiq-zynq>}/remote_run.sh -h rpi-4 -o "-F /dev/null -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR -i /opt/hydra_id_rsa" -d ${artiq-zynq.zc706-nist_qc2-jtag}
        popd

        echo Waiting for the firmware to boot...
        sleep 15

        echo Running test kernel...
        artiq_run --device-db ${<artiq-zynq>}/examples/device_db.py ${<artiq-zynq>}/examples/mandelbrot.py

        echo Running ARTIQ unit tests...
        ARTIQ_ROOT=${<artiq-zynq>}/examples python -m unittest discover artiq.test.coredevice -v

        touch $out

        echo Completed
        '';
    });
  }
