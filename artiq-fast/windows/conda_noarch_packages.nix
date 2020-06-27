{ pkgs } : [

(pkgs.fetchurl {
  url = "https://conda.anaconda.org/conda-forge/noarch/prettytable-0.7.2-py_3.tar.bz2";
  sha256 = "0b7s4xm6bbkcg37sf1i3mxrbac0vxhryq22m3qx4x9kh6k2c5g5q";
})

(pkgs.fetchurl {
  url = "https://repo.anaconda.com/pkgs/main/noarch/six-1.15.0-py_0.tar.bz2";
  sha256 = "08rsfp9bd2mz8r120s8w5vgncy0gn732xa0lfgbmx833548cfqmb";
})

(pkgs.fetchurl {
  url = "https://repo.anaconda.com/pkgs/main/noarch/python-dateutil-2.8.1-py_0.tar.bz2";
  sha256 = "0cbcd0jq6683ibj8ncsmmrbhbjvwww8i22lb68bx4xfzsmb9z8cb";
})

(pkgs.fetchurl {
  url = "https://repo.anaconda.com/pkgs/main/noarch/cached-property-1.5.1-py_1.tar.bz2";
  sha256 = "1yl6h3wb6hxgw79i7rpgpq260l5vqfcj5dv5kyxn8z99xdkp52q5";
})

(pkgs.fetchurl {
  url = "https://repo.anaconda.com/pkgs/main/noarch/pycparser-2.20-py_0.tar.bz2";
  sha256 = "1qwcb07q8cjz0qpj6pfxb0qb68kddmx9bv9wr5pghwz78q8073z9";
})
]
