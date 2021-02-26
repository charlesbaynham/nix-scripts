{ pkgs, artiq-full }:
let
  matplotlib-qt = (pkgs.python3Packages.matplotlib.override { enableQt = true; });
in
{
  artiq-example-user-env = pkgs.runCommand "artiq-example-user-env" {
    buildInputs = [
      (pkgs.python3.withPackages(ps: [
        artiq-full.artiq
        artiq-full.artiq-comtools
        artiq-full.wand
        artiq-full.flake8-artiq
        artiq-full.lda
        artiq-full.korad_ka3005p
        artiq-full.novatech409b
        artiq-full.thorlabs_tcube
        artiq-full.artiq-board-kc705-nist_clock
        artiq-full.artiq-board-kasli-oregon
        ps.paramiko
        ps.pandas
        ps.numpy
        ps.scipy
        ps.numba
        ps.bokeh
        matplotlib-qt
        # cirq is broken and doesn't build (as of 20.09.3281.06b11191834)
        #(ps.cirq.override { matplotlib = matplotlib-qt; })
        # qiskit does not work with matplotlib-qt
        #ps.qiskit
      ]))

      artiq-full.openocd
      pkgs.gtkwave
      #pkgs.spyder  # broken on 20.03
      pkgs.R
    ];
  } "touch $out";
}
