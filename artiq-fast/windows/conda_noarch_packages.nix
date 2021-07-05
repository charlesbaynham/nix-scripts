{ pkgs } : [

(pkgs.fetchurl {
  url = "https://conda.anaconda.org/conda-forge/noarch/prettytable-2.1.0-pyhd8ed1ab_0.tar.bz2";
  sha256 = "1w71padwzy6ay5g8zl575ali994cssgcgzf5917rap3fmw2mgg4d";
})

(pkgs.fetchurl {
  url = "https://repo.anaconda.com/pkgs/main/noarch/pyqtgraph-0.11.0-py_0.tar.bz2";
  sha256 = "1jnid69dpvhd8nscmkm761qpqz8ip0gka5av90xs3i0pqkqmffqg";
})

(pkgs.fetchurl {
  url = "https://repo.anaconda.com/pkgs/main/noarch/cached-property-1.5.2-py_0.tar.bz2";
  sha256 = "01mcbrsrdwvinyvp0fs2hbkczydb33gbz59ldhb1484w5mm9y9bi";
})

(pkgs.fetchurl {
  url = "https://repo.anaconda.com/pkgs/main/noarch/six-1.16.0-pyhd3eb1b0_0.tar.bz2";
  sha256 = "120wav3bxbyv0jsvbl94rxsigqqchsqg4qqxccg9ij7ydirmqaql";
})

(pkgs.fetchurl {
  url = "https://repo.anaconda.com/pkgs/main/noarch/typing_extensions-3.10.0.0-pyh06a4308_0.tar.bz2";
  sha256 = "07fk0rcll1105wiqqss8a3jwgpzkysg2ff0hlnz0vwca57qsv2pb";
})
]
