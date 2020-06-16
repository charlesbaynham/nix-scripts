{ pkgs } : [

(pkgs.fetchurl {
  url = "http://repo.msys2.org/mingw/i686/mingw-w64-i686-libiconv-1.16-1-any.pkg.tar.xz";
  sha256 = "0d53xqbd6r53pyfkhrdjh88fwkiq3xkcl9nxp3sfh5pib589vmxv";
})

(pkgs.fetchurl {
  url = "http://repo.msys2.org/mingw/i686/mingw-w64-i686-zlib-1.2.11-7-any.pkg.tar.xz";
  sha256 = "0hjswm6b9nzmqkjb8v18787l6r2vzi7dzjzi81v409s02d96rpxd";
})

(pkgs.fetchurl {
  url = "http://repo.msys2.org/mingw/i686/mingw-w64-i686-binutils-2.34-3-any.pkg.tar.zst";
  sha256 = "0wp6yhylpdb6hw5xvqjj5bsyyllanhdqsya3vq17sc7pk7h246rc";
})

(pkgs.fetchurl {
  url = "http://repo.msys2.org/mingw/i686/mingw-w64-i686-headers-git-8.0.0.5905.066f1b3c-1-any.pkg.tar.zst";
  sha256 = "14bpm8lvkpfk9xk4xynqcgr7f5s8hfqplq2bd4alvl4pr05yrf8j";
})

(pkgs.fetchurl {
  url = "http://repo.msys2.org/mingw/i686/mingw-w64-i686-crt-git-8.0.0.5905.066f1b3c-1-any.pkg.tar.zst";
  sha256 = "0brg5m9xp019b7p44ijcl5khmqk9hagf7lf9jz1vwjj8y5lpyhrb";
})

(pkgs.fetchurl {
  url = "http://repo.msys2.org/mingw/i686/mingw-w64-i686-isl-0.22.1-1-any.pkg.tar.xz";
  sha256 = "1685993h14iyj155cbamvncjv2gdkvdhmbm138sy6i7cd8q7avvy";
})

(pkgs.fetchurl {
  url = "http://repo.msys2.org/mingw/i686/mingw-w64-i686-gmp-6.2.0-1-any.pkg.tar.xz";
  sha256 = "00dps8wmrr3gnk17ndi5v20722fp8knyqbqkpvlmyw4fxlx7ix1v";
})

(pkgs.fetchurl {
  url = "http://repo.msys2.org/mingw/i686/mingw-w64-i686-mpfr-4.0.2-2-any.pkg.tar.xz";
  sha256 = "0vhl8prvd2kh9mfdrmaijadx7nk70pzqy9rqj5hxqpskbsffv9bv";
})

(pkgs.fetchurl {
  url = "http://repo.msys2.org/mingw/i686/mingw-w64-i686-mpc-1.1.0-1-any.pkg.tar.xz";
  sha256 = "11523nvs28jzmrxfrfs352ybp7zpm834ak293hnk8g8fh9v056jr";
})

(pkgs.fetchurl {
  url = "http://repo.msys2.org/mingw/i686/mingw-w64-i686-libwinpthread-git-8.0.0.5906.c9a21571-1-any.pkg.tar.zst";
  sha256 = "0349g5yy656bx94w1kajck03lgl85pcy3hwh2akql1062gi5ycgs";
})

(pkgs.fetchurl {
  url = "http://repo.msys2.org/mingw/i686/mingw-w64-i686-gcc-libs-10.1.0-3-any.pkg.tar.zst";
  sha256 = "13sndq497a2bgmc1dxlanwnvh0w6mdb83qb13szfjpy6y6qn13an";
})

(pkgs.fetchurl {
  url = "http://repo.msys2.org/mingw/i686/mingw-w64-i686-windows-default-manifest-6.4-3-any.pkg.tar.xz";
  sha256 = "10xrlsv1p5fm0q0dlzhdzip3kf15m959rh0mg5rgzq3xkk1kncjn";
})

(pkgs.fetchurl {
  url = "http://repo.msys2.org/mingw/i686/mingw-w64-i686-winpthreads-git-8.0.0.5906.c9a21571-1-any.pkg.tar.zst";
  sha256 = "058jipgsf7v5r3q49icl6yijl539k3brhm5nrc812baa1pq83v2f";
})

(pkgs.fetchurl {
  url = "http://repo.msys2.org/mingw/i686/mingw-w64-i686-zstd-1.4.5-1-any.pkg.tar.zst";
  sha256 = "151fi9iijf6vf53pq5vs970wsf7hlmrplz025fmc94ck22c6aza8";
})

(pkgs.fetchurl {
  url = "http://repo.msys2.org/mingw/i686/mingw-w64-i686-gcc-10.1.0-3-any.pkg.tar.zst";
  sha256 = "1gx2q2lr44bpa1ixx5bv57jzhvf9a8y3rbz7njk1z63jp0ylgsr9";
})

(pkgs.fetchurl {
  url = "http://repo.msys2.org/msys/x86_64/make-4.3-1-x86_64.pkg.tar.xz";
  sha256 = "0bmgggw56gkx7dcd8simpi2lhgz98limikx8wm0cb8cn7awi9w82";
})

(pkgs.fetchurl {
  url = "http://repo.msys2.org/msys/x86_64/m4-1.4.18-2-x86_64.pkg.tar.xz";
  sha256 = "05x7myqwwxk3vfqmliwk5pfn0w04fnjh1sqafsynpb9hx0c563ji";
})

(pkgs.fetchurl {
  url = "http://repo.msys2.org/msys/x86_64/diffutils-3.7-1-x86_64.pkg.tar.xz";
  sha256 = "11qdxn4mr8a96palhp5jkam904fh77bsw5v7mslhnzag4cg3kybx";
})

(pkgs.fetchurl {
  url = "http://repo.msys2.org/msys/x86_64/autoconf-2.69-5-any.pkg.tar.xz";
  sha256 = "1fxvgbjnmmb7dvmssfxkiw151dfd1wzj04hf45zklmzs4h2kkwda";
})

(pkgs.fetchurl {
  url = "http://repo.msys2.org/msys/x86_64/automake1.6-1.6.3-2-any.pkg.tar.xz";
  sha256 = "0if4wrr1vm2f1zjjh6dpln97xc1l1052bcawzmndwfh561cfxqb6";
})

(pkgs.fetchurl {
  url = "http://repo.msys2.org/msys/x86_64/automake1.7-1.7.9-2-any.pkg.tar.xz";
  sha256 = "1mjhp1k4c0xm8hfm3yckqvfb4ablzgg8a87l7wxaq1mmmskjmhpq";
})

(pkgs.fetchurl {
  url = "http://repo.msys2.org/msys/x86_64/automake1.8-1.8.5-3-any.pkg.tar.xz";
  sha256 = "046bzr44ss0lglx9lzccj9li74arz632hyvz6l9fcp98dndr3qjk";
})

(pkgs.fetchurl {
  url = "http://repo.msys2.org/msys/x86_64/automake1.9-1.9.6-2-any.pkg.tar.xz";
  sha256 = "0bh0dldmrd46xhix5358nj9sgf298n4ap0y8dsl6rvjsb5c0l5hd";
})

(pkgs.fetchurl {
  url = "http://repo.msys2.org/msys/x86_64/automake1.10-1.10.3-3-any.pkg.tar.xz";
  sha256 = "0p26lkx5n1mmmw1y98bgwzbxfxkfa18fqxvkgsm60fznjig4dq61";
})

(pkgs.fetchurl {
  url = "http://repo.msys2.org/msys/x86_64/automake1.11-1.11.6-3-any.pkg.tar.xz";
  sha256 = "1cjkav2bskf9rdm8g3hsl2l7wz1lx8dfigwqib0xhm7n8i8gc560";
})

(pkgs.fetchurl {
  url = "http://repo.msys2.org/msys/x86_64/automake1.12-1.12.6-3-any.pkg.tar.xz";
  sha256 = "1c0h2lngfjjfvw0jkrfah1fs25k0vdm80hlxfjs912almh2yg5gv";
})

(pkgs.fetchurl {
  url = "http://repo.msys2.org/msys/x86_64/automake1.13-1.13.4-4-any.pkg.tar.xz";
  sha256 = "0mczn8hanqn3hxr104klb832b4cnzn44bbn7lvqfsbvvjpklv9ld";
})

(pkgs.fetchurl {
  url = "http://repo.msys2.org/msys/x86_64/automake1.14-1.14.1-3-any.pkg.tar.xz";
  sha256 = "04gjyfszyphxy7qc1rr8378ms9hql0sy8a1gyj0mvpbmgb0phgkp";
})

(pkgs.fetchurl {
  url = "http://repo.msys2.org/msys/x86_64/automake1.15-1.15.1-1-any.pkg.tar.xz";
  sha256 = "00n1f3c6fwznpm1f6xmj30q41ixw5vdg52yg48yvr4jswb78qf8q";
})

(pkgs.fetchurl {
  url = "http://repo.msys2.org/msys/x86_64/automake1.16-1.16.1-1-any.pkg.tar.xz";
  sha256 = "1ds8rpagrlkzi28n5rh0jcibbic49xssl2hz6sy41my0vd8a3z9y";
})

(pkgs.fetchurl {
  url = "http://repo.msys2.org/msys/x86_64/automake-wrapper-11-1-any.pkg.tar.xz";
  sha256 = "1dzymv59wri7qqmgmy5xfkq6zvfcb0znwspc149a04d0bhxs75gw";
})

(pkgs.fetchurl {
  url = "http://repo.msys2.org/msys/x86_64/libltdl-2.4.6-9-x86_64.pkg.tar.xz";
  sha256 = "0j0xazjpj28dib9vjn3paibhry77k903rzvbkdn6gnl20smj18g2";
})

(pkgs.fetchurl {
  url = "http://repo.msys2.org/msys/x86_64/tar-1.32-1-x86_64.pkg.tar.xz";
  sha256 = "0ynz2qwzbcmixcxddp05q2wc7iqli6svzkrjss9izrpmbkv5ifa5";
})

(pkgs.fetchurl {
  url = "http://repo.msys2.org/msys/x86_64/libtool-2.4.6-9-x86_64.pkg.tar.xz";
  sha256 = "0mrnkayrhmrgq446nyysvj3kadqm1xhyl97qqv6hrq57lhkcry2p";
})

(pkgs.fetchurl {
  url = "http://repo.msys2.org/msys/x86_64/texinfo-6.7-1-x86_64.pkg.tar.xz";
  sha256 = "0c50809yg9g95m8yib867q8m28sjabqppz2qbzh3gr83z55kknnw";
})

(pkgs.fetchurl {
  url = "http://repo.msys2.org/msys/x86_64/jsoncpp-1.9.1-2-any.pkg.tar.xz";
  sha256 = "02gpvddk4d037kmn5hyz8lpwg80zp1g7wcsp53d8f60dz735z1i1";
})

(pkgs.fetchurl {
  url = "http://repo.msys2.org/msys/x86_64/libarchive-3.4.3-1-x86_64.pkg.tar.zst";
  sha256 = "15piplgk5rqqmbhk0pvfh3d6cs0nqk5sb43kmz24rjy5wkfvwpq1";
})

(pkgs.fetchurl {
  url = "http://repo.msys2.org/msys/x86_64/librhash-1.3.9-1-x86_64.pkg.tar.xz";
  sha256 = "0p782qw0991zgv2shc12np9jrdna688a5hlwyrrvrxh7clfmlgzr";
})

(pkgs.fetchurl {
  url = "http://repo.msys2.org/msys/x86_64/libuv-1.38.0-1-x86_64.pkg.tar.zst";
  sha256 = "1gb8rq4nf7wwa0jhjwakyip2f4v31sajyjj6fsxxnb5bwf37vznb";
})

(pkgs.fetchurl {
  url = "http://repo.msys2.org/msys/x86_64/pkg-config-0.29.2-1-x86_64.pkg.tar.xz";
  sha256 = "12f615hnzdxpv7q3apwbqkr8fqw4jpgkfzr23g9yhbrf84qd0gvb";
})

(pkgs.fetchurl {
  url = "http://repo.msys2.org/msys/x86_64/cmake-3.17.3-1-x86_64.pkg.tar.zst";
  sha256 = "0yrv5b2w509pmc2apwbfgnv607ysv6c9w01736ax21dyhr8wr8a2";
})
]
