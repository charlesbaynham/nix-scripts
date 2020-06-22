{ pkgs } : [

(pkgs.fetchurl {
  url = "https://conda.anaconda.org/conda-forge/noarch/prettytable-0.7.2-py_3.tar.bz2";
  sha256 = "0b7s4xm6bbkcg37sf1i3mxrbac0vxhryq22m3qx4x9kh6k2c5g5q";
})

(pkgs.fetchurl {
  url = "https://repo.anaconda.com/pkgs/main/noarch/six-1.15.0-py_0.conda";
  sha256 = "057vci1j78fzkg4qnamfjhz47s0x2v6ygli565a56hvna7h11kng";
})

(pkgs.fetchurl {
  url = "https://repo.anaconda.com/pkgs/main/noarch/pycparser-2.20-py_0.conda";
  sha256 = "00rx3nqa21dpqq4lx7g7rahsds0248ky4rw8xjxv5xik5x5xrqnd";
})
]
