let
  pkgs = import <nixpkgs> {};
  artiq-zynq = import <artiq-zynq>;
  artiq-fast = import <artiq-fast> { inherit pkgs; };

  zynq-rs = import artiq-zynq.zynq-rs;
  # New zynq-rs versions with Kasli-SoC support have the multiboard "szl" package.
  # Older versions need the SZL environment variable set to the SZL ELF to be loaded.
  szlEnv = if zynq-rs ? "szl" then "${zynq-rs.szl}" else "${zynq-rs.zc706-szl}/szl.elf";
in
  (
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
        pkgs.netcat pkgs.openssh pkgs.rsync artiq-fast.artiq artiq-fast.artiq-netboot
      ];
      phases = [ "buildPhase" ];

      buildPhase =
        ''
        echo Power cycling board...
        (echo b; sleep 5; echo B; sleep 5) | nc -N -w6 192.168.1.31 3131
        echo Power cycle done.

        export USER=hydra
        export OPENOCD_ZYNQ=${artiq-zynq.zynq-rs}/openocd
        export SZL=${szlEnv}
        pushd ${<artiq-zynq>}
        export NIX_SSHOPTS="-F /dev/null -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR -i /opt/hydra_id_rsa"
        ssh rpi-4 "nix-store -r ${<nixpkgs>} --add-root openocd-pkgs --indirect && nix-env -e openocd && nix-env -iA openocd -f openocd-pkgs && rm openocd-pkgs"
        bash ${<artiq-zynq>}/remote_run.sh -h rpi-4 -o $NIX_SSHOPTS -d ${artiq-zynq.zc706-nist_qc2-jtag}
        popd

        echo Waiting for the firmware to boot...
        sleep 15

        echo Running test kernel...
        artiq_run --device-db ${<artiq-zynq>}/examples/device_db.py ${<artiq-zynq>}/examples/mandelbrot.py

        echo Running ARTIQ unit tests...
        ARTIQ_ROOT=${<artiq-zynq>}/examples python -m unittest discover artiq.test.coredevice -v

        touch $out

        echo Completed

        (echo b; sleep 5) | nc -N -w6 192.168.1.31 3131
        echo Board powered off
        '';
    });
  }
