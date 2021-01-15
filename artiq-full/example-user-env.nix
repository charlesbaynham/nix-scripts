{ pkgs, artiq-full }:
{
  artiq-example-user-env = pkgs.runCommand "artiq-example-user-env" {
    buildInputs = [
      (pkgs.python3.withPackages(ps: [
        artiq-full.artiq
        artiq-full.artiq-comtools
        artiq-full.wand
        artiq-full.lda
        artiq-full.korad_ka3005p
        artiq-full.novatech409b
        artiq-full.thorlabs_tcube
        artiq-full.artiq-board-kc705-nist_clock
        artiq-full.artiq-board-kasli-nist2
        ps.paramiko
        ps.pandas
        ps.numpy
        ps.scipy
        ps.numba
        (ps.matplotlib.override { enableQt = true; })
        ps.bokeh
        ps.cirq
        ps.qiskit
      ]))

      artiq-full.openocd
      pkgs.gtkwave
      pkgs.spyder
      pkgs.R
    ];
  } "touch $out";
}
