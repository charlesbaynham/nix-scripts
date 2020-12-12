{ pkgs, artiqpkgs, testCommand, testTimeout ? 600 }:

let
  condaEnv = "artiq-env";
  tcpPorts = [ 1380 1381 1382 1383 ];
  forwardedPorts =
    map (port: {
      listenAddr = "192.168.1.50";
      targetAddr = "192.168.1.50";
      inherit port;
    }) tcpPorts;

  wfvm = import ../wfvm.nix { inherit pkgs; };
  conda-deps = {
    name = "conda-deps";
    script = let
      artiq6 = pkgs.lib.strings.versionAtLeast artiqpkgs.artiq.version "6.0";
      qt-asyncio-package = if artiq6 then artiqpkgs.conda-qasync else artiqpkgs.conda-quamash;
      conda-deps-noarch = import (if artiq6 then ./conda_noarch_packages.nix else ./conda_noarch_packages-legacy.nix) { inherit pkgs; };
      conda-deps-win-64 = import (if artiq6 then ./conda_win-64_packages.nix else ./conda_win-64_packages-legacy.nix) { inherit pkgs; };
      conda-packages-put = pkgs.lib.strings.concatStringsSep "\n"
          ( (map (package: ''win-put ${package} 'fake-channel/noarch' '') conda-deps-noarch)
             ++ (map (package: ''win-put ${package} 'fake-channel/win-64' '') conda-deps-win-64) );
    in
      ''
      win-exec 'mkdir fake-channel && mkdir fake-channel\noarch && mkdir fake-channel\win-64'

      ${conda-packages-put}

      win-put ${artiqpkgs.conda-windows-binutils-or1k}/win-64/*.tar.bz2 'fake-channel/win-64'
      win-put ${artiqpkgs.conda-windows-llvm-or1k}/win-64/*.tar.bz2 'fake-channel/win-64'
      win-put ${artiqpkgs.conda-windows-llvmlite-artiq}/win-64/*.tar.bz2 'fake-channel/win-64'

      win-put ${artiqpkgs.conda-pythonparser}/noarch/*.tar.bz2 'fake-channel/noarch'
      win-put ${artiqpkgs.conda-sipyco}/noarch/*.tar.bz2 'fake-channel/noarch'
      win-put ${qt-asyncio-package}/noarch/*.tar.bz2 'fake-channel/noarch'
      '';
  };
in
  wfvm.utils.wfvm-run {
    name = "windows-tests";
    image = wfvm.makeWindowsImage { installCommands = [ wfvm.layers.anaconda3 conda-deps ]; };
    inherit forwardedPorts;
    script =
      ''
      ${wfvm.utils.win-put}/bin/win-put ${artiqpkgs.conda-artiq}/noarch/*.tar.bz2 'fake-channel/noarch'

      ${wfvm.utils.win-exec}/bin/win-exec ".\Anaconda3\scripts\activate && conda index fake-channel"
      ${wfvm.utils.win-exec}/bin/win-exec ".\Anaconda3\scripts\activate && conda create -n ${condaEnv} --offline"
      ${wfvm.utils.win-exec}/bin/win-exec ".\Anaconda3\scripts\activate ${condaEnv} && conda install -y -c file:///C:/users/wfvm/fake-channel --offline artiq"\

      # Schedule a timed shutdown against hanging test runs
      ${wfvm.utils.win-exec}/bin/win-exec "shutdown -s -t ${toString testTimeout}"

      ${wfvm.utils.win-exec}/bin/win-exec ".\Anaconda3\scripts\activate ${condaEnv} && ${testCommand}"

      # Abort timeouted shutdown
      ${wfvm.utils.win-exec}/bin/win-exec "shutdown -a"
      '';
  }
