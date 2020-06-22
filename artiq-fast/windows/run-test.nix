{ pkgs, artiqpkgs, testCommand }:

let
  condaEnv = "artiq-env";
  tcpPorts = [ 1380 1381 1382 1383 ];
  forwardedPorts =
    map (port: {
      listenAddr = "192.168.1.50";
      targetAddr = "192.168.1.50";
      inherit port;
    }) tcpPorts;

  wfvm = import ../wfvm/default.nix { inherit pkgs; };
  conda-deps = {
    name = "conda-deps";
    script = let
      conda-deps-noarch = import ./conda_noarch_packages.nix { inherit pkgs; };
      conda-deps-win-64 = import ./conda_win-64_packages.nix { inherit pkgs; };
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
      win-put ${artiqpkgs.conda-quamash}/noarch/*.tar.bz2 'fake-channel/noarch'
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
      ${wfvm.utils.win-exec}/bin/win-exec ".\Anaconda3\scripts\activate ${condaEnv} && conda install -y -c file:///C:/users/wfvm/fake-channel --offline artiq"
      #${pkgs.sshpass}/bin/sshpass -p1234 -- ${pkgs.openssh}/bin/ssh -p 2022 wfvm@localhost -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null
      ${wfvm.utils.win-exec}/bin/win-exec ".\Anaconda3\scripts\activate ${condaEnv} && ${testCommand}"
      '';
  }
