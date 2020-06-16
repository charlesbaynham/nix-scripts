{ pkgs } : [

(pkgs.fetchurl {
  url = "http://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-libiconv-1.16-1-any.pkg.tar.xz";
  sha256 = "0w8jkjr5gwybw9469216vs6vpibkq36wx47bbl4r0smi4wvh2yxk";
})

(pkgs.fetchurl {
  url = "http://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-zlib-1.2.11-7-any.pkg.tar.xz";
  sha256 = "1hnfagn5m0ys4f8349d8dpbqvh9p900jjn83r7fi1az6i9dz1v0x";
})

(pkgs.fetchurl {
  url = "http://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-binutils-2.34-3-any.pkg.tar.zst";
  sha256 = "0ahlwbg5ir89nbra407yrzsplib4cia9m0dggcqjw1i4bxi7ypj1";
})

(pkgs.fetchurl {
  url = "http://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-headers-git-8.0.0.5905.066f1b3c-1-any.pkg.tar.zst";
  sha256 = "0sskg0vvgggs932i09ipm5rrllv6vdf1ai3d3fvbi5pxis1xc9g0";
})

(pkgs.fetchurl {
  url = "http://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-crt-git-8.0.0.5905.066f1b3c-1-any.pkg.tar.zst";
  sha256 = "1sjizkvknivbjs962fqxcmjkgnrvhd1frq96cfj2fyzk5cz7kfx0";
})

(pkgs.fetchurl {
  url = "http://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-isl-0.22.1-1-any.pkg.tar.xz";
  sha256 = "1nj7sj3hgxhziqs1l7k42ginl10w7iy1b753mwvqiczfs322hb90";
})

(pkgs.fetchurl {
  url = "http://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-gmp-6.2.0-1-any.pkg.tar.xz";
  sha256 = "1l4qdxr8xp6xyxabwcf9b876db3rhj4v54zsvb4v1kwm3jrs7caw";
})

(pkgs.fetchurl {
  url = "http://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-mpfr-4.0.2-2-any.pkg.tar.xz";
  sha256 = "0hriryx58bkk3sihnhd4i6966civ3hq8i68rnc9kjivk47wi49rj";
})

(pkgs.fetchurl {
  url = "http://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-mpc-1.1.0-1-any.pkg.tar.xz";
  sha256 = "0x1kg178l6mf9ivdy71bci36h2a37vypg4jk3k7y31ks6i79zifp";
})

(pkgs.fetchurl {
  url = "http://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-libwinpthread-git-8.0.0.5906.c9a21571-1-any.pkg.tar.zst";
  sha256 = "16aqi04drn252cxdh1brpbi4syn4bfjb84qk4xqbnffnpxpvv5ph";
})

(pkgs.fetchurl {
  url = "http://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-gcc-libs-10.1.0-3-any.pkg.tar.zst";
  sha256 = "0bmkrb9x7z0azzxl3z08r6chcl0pbnaijar7cdjxb2nh7fbbdzzp";
})

(pkgs.fetchurl {
  url = "http://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-windows-default-manifest-6.4-3-any.pkg.tar.xz";
  sha256 = "1kwxb3q2slgsg17lkd0dc9fjks5f205dgm79fj0xq0zmrsns83kc";
})

(pkgs.fetchurl {
  url = "http://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-winpthreads-git-8.0.0.5906.c9a21571-1-any.pkg.tar.zst";
  sha256 = "17nq8gs1nnxgligdrp5n6h4pnk46xw0yhjk2hn6y12vvpn7iv05v";
})

(pkgs.fetchurl {
  url = "http://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-zstd-1.4.5-1-any.pkg.tar.zst";
  sha256 = "1jfxzajmbvlap1c0v17s8dzwdx0fi8kyrkmgr6gw1snisgllifyh";
})

(pkgs.fetchurl {
  url = "http://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-gcc-10.1.0-3-any.pkg.tar.zst";
  sha256 = "1gkcc6hh20glx4b96ldsnd70r8dbp460bxfznm9z2rwgr0mxb374";
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
