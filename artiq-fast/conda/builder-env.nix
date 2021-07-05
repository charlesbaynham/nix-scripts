{ pkgs }:

with pkgs;

let
  condaDeps = [ stdenv.cc zlib xorg.libSM xorg.libICE xorg.libX11 xorg.libXau xorg.libXi xorg.libXrender libselinux libGL ];
  # Use the full Anaconda distribution, which already contains conda-build and its many dependencies,
  # so we don't have to manually deal with them.
  condaInstaller = fetchurl {
    url = "https://repo.anaconda.com/archive/Anaconda3-2021.05-Linux-x86_64.sh";
    sha256 = "0lrxwd3pwz8k3jxwgkd9x47wgkqqy9s8m7hgx1x2gw4gcwysnl97";
  };
  condaSrcChmod = runCommand "conda-src-chmod" { }
    ''
    mkdir $out
    cp ${condaInstaller} $out/conda-installer.sh
    chmod +x $out/conda-installer.sh
    # keep the same file length to avoid breaking embedded payload offsets
    sed -i 0,/unset\ LD_LIBRARY_PATH/s//\#nset\ LD_LIBRARY_PATH/ $out/conda-installer.sh
    '';
  condaInstallerEnv = buildFHSUserEnv {
    name = "conda-installer-env";
    targetPkgs = pkgs: ([ condaSrcChmod ] ++ condaDeps);
  };

  # for binutils
  libiconv-filename = "libiconv-1.15-h516909a_1006.tar.bz2";
  libiconv = pkgs.fetchurl {
    url = "https://anaconda.org/conda-forge/libiconv/1.15/download/linux-64/${libiconv-filename}";
    sha256 = "1y1g807881j95f9s6mjinf6b7mqa51vc9jf0v7cx8hn7xx4d10ik";
  };

  condaInstalled = runCommand "conda-installed" { }
    ''
    ${condaInstallerEnv}/bin/conda-installer-env -c "${condaSrcChmod}/conda-installer.sh -p $out -b"
    substituteInPlace $out/lib/python3.8/site-packages/conda/gateways/disk/__init__.py \
      --replace "os.chmod(path, 0o2775)" "pass"

    # The conda garbage breaks if the package filename is prefixed with the Nix store hash.
    # Symptom is "WARNING conda.core.prefix_data:_load_single_record(167): Ignoring malformed
    # prefix record at: /nix/store/[...].json", and the package is not registered in the conda
    # list, even though its files are installed.
    ln -s ${libiconv} ${libiconv-filename}
    ${condaInstallerEnv}/bin/conda-installer-env -c "$out/bin/conda install ${libiconv-filename}"
    '';
in
  buildFHSUserEnv {
    name = "conda-builder-env";
    targetPkgs = pkgs: ([ condaInstalled ] ++ condaDeps ++ [
        # for llvm-or1k
        cmake
      ]
    );
  }
