let
  pkgs = import <nixpkgs> {};
  artiqSrc = <artiqSrc>;
  generatedNix = pkgs.runCommand "generated-nix" { buildInputs = [ pkgs.nix pkgs.git ]; }
    # keep in sync with artiq-fast/pkgs/artiq-version.nix
    ''
    cp --no-preserve=mode,ownership -R ${./artiq-fast} $out
    REV=`git --git-dir ${artiqSrc}/.git rev-parse HEAD`
    MAJOR_VERSION=`cat ${artiqSrc}/MAJOR_VERSION`
    if [ -e ${artiqSrc}/BETA ]; then
      SUFFIX=".beta"
    else
      SUFFIX=""
    fi
    COMMIT_COUNT=`git --git-dir ${artiqSrc}/.git rev-list --count HEAD`
    TIMESTAMP=`git --git-dir ${artiqSrc}/.git log -1 --format=%ct`
    ARTIQ_SRC_CLEAN=`mktemp -d`
    cp -a ${artiqSrc}/. $ARTIQ_SRC_CLEAN
    chmod -R 755 $ARTIQ_SRC_CLEAN/.git
    chmod 755 $ARTIQ_SRC_CLEAN
    rm -rf $ARTIQ_SRC_CLEAN/.git
    HASH=`nix-hash --type sha256 --base32 $ARTIQ_SRC_CLEAN`
    cat > $out/pkgs/artiq-src.nix << EOF
    { fetchgit }:
    fetchgit {
      url = "git://github.com/m-labs/artiq.git";
      rev = "$REV";
      sha256 = "$HASH";
    }
    EOF
    echo "{ stdenv, git, fetchgit }: \"$MAJOR_VERSION.$COMMIT_COUNT.`cut -c1-8 <<< $REV`$SUFFIX\"" > $out/pkgs/artiq-version.nix
    echo "{ stdenv, git, fetchgit }: \"$TIMESTAMP\"" > $out/pkgs/artiq-timestamp.nix
    '';
  artiqpkgs = import "${generatedNix}/default.nix" { inherit pkgs; };
  artiqVersion = import "${generatedNix}/pkgs/artiq-version.nix" (with pkgs; { inherit stdenv fetchgit git; });
  windowsRunner = overrides:
    import "${generatedNix}/windows/run-test.nix" ({
      inherit pkgs artiqpkgs;
    } // overrides);
  jobs = (builtins.mapAttrs (key: value: pkgs.lib.hydraJob value) artiqpkgs);
in
  jobs // {
    generated-nix = pkgs.lib.hydraJob generatedNix;  # used by artiq-full
    artiq-fast = pkgs.releaseTools.channel {
      name = "artiq-fast";
      src = generatedNix;
      constituents = builtins.attrValues jobs;
    };

    windows-no-hardware-tests = pkgs.stdenv.mkDerivation {
      name = "windows-no-hardware-tests";
      phases = [ "buildPhase" ];
      buildPhase = ''
        ${windowsRunner { testCommand = "python -m unittest discover -v sipyco.test && python -m unittest discover -v artiq.test"; }}/bin/wfvm-run-windows-tests
        touch $out
      '';
    };

    extended-tests = pkgs.stdenv.mkDerivation {
      name = "extended-tests";

      # requires patched Nix
      __networked = true;

      buildInputs = [
        (pkgs.python3.withPackages(ps: [ ps.paramiko artiqpkgs.artiq artiqpkgs.artiq-board-kc705-nist_clock ]))
        artiqpkgs.binutils-or1k
        artiqpkgs.openocd
        pkgs.openssh
      ];
      phases = [ "buildPhase" ];
      buildPhase =
      ''
      export HOME=`mktemp -d`
      mkdir $HOME/.ssh
      cp /opt/hydra_id_rsa $HOME/.ssh/id_rsa
      cp /opt/hydra_id_rsa.pub $HOME/.ssh/id_rsa.pub
      echo "rpi-1 ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPOBQVcsvk6WgRj18v4m0zkFeKrcN9gA+r6sxQxNwFpv" > $HOME/.ssh/known_hosts
      chmod 600 $HOME/.ssh/id_rsa
      LOCKCTL=$(mktemp -d)
      mkfifo $LOCKCTL/lockctl

      cat $LOCKCTL/lockctl | ${pkgs.openssh}/bin/ssh \
        -i $HOME/.ssh/id_rsa \
        -o UserKnownHostsFile=$HOME/.ssh/known_hosts \
        rpi-1 \
        'mkdir -p /tmp/board_lock && flock /tmp/board_lock/kc705-1 -c "echo Ok; cat"' \
      | (
        # End remote flock via FIFO
        atexit_unlock() {
          echo > $LOCKCTL/lockctl
        }
        trap atexit_unlock EXIT

        # Read "Ok" line when remote successfully locked
        read LOCK_OK

        artiq_flash -t kc705 -H rpi-1
        sleep 15

        export ARTIQ_ROOT=`python -c "import artiq; print(artiq.__path__[0])"`/examples/kc705_nist_clock
        export ARTIQ_LOW_LATENCY=1
        python -m unittest discover -v artiq.test.coredevice

        ${windowsRunner { testCommand = "set ARTIQ_ROOT=%cd%\\Anaconda3\\envs\\artiq-env\\Lib\\site-packages\\artiq\\examples\\kc705_nist_clock&& python -m unittest discover -v artiq.test.coredevice"; }}/bin/wfvm-run-windows-tests
      )

      touch $out
      '';
    };
  }
