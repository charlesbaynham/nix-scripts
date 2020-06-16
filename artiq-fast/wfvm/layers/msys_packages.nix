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
  url = "http://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-expat-2.2.9-1-any.pkg.tar.xz";
  sha256 = "16fz2r902mmc0kka3pm7g54xjd8x3q07bi7y54vzpbmic31rrvh4";
})

(pkgs.fetchurl {
  url = "http://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-gettext-0.19.8.1-8-any.pkg.tar.xz";
  sha256 = "1g28871qgc66k4csmc4rk4vcajzw5wavicc2x3iw4pnigh9vsj83";
})

(pkgs.fetchurl {
  url = "http://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-make-4.3-1-any.pkg.tar.xz";
  sha256 = "0v133ip1r3djcki5znn946r1c81vvyc6xk5xf35ad8b30wmlfqvq";
})

(pkgs.fetchurl {
  url = "http://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-pkg-config-0.29.2-1-any.pkg.tar.xz";
  sha256 = "1w6s9nb7kjwnlz2vgimzvyjmay47d6g008c82xab4k8nhd7nm77n";
})

(pkgs.fetchurl {
  url = "http://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-c-ares-1.16.1-1-any.pkg.tar.zst";
  sha256 = "13sfv0cs4rj3vw4y9pibp02qvvcv5qnzs87282m7pxxnjzccv9an";
})

(pkgs.fetchurl {
  url = "http://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-brotli-1.0.7-4-any.pkg.tar.xz";
  sha256 = "02i5jxmwbvraszy5rm31gm6wi21vclzsbqq9rx4qxjdgjwgn4rfl";
})

(pkgs.fetchurl {
  url = "http://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-libunistring-0.9.10-1-any.pkg.tar.xz";
  sha256 = "1q03qjyndbv65j0w71x41gc7nhdcbmdsc5xb882gmzlgwrdi77hq";
})

(pkgs.fetchurl {
  url = "http://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-libidn2-2.3.0-1-any.pkg.tar.xz";
  sha256 = "06523dq5q3dq07iz6f11pwk3b4v18z3b72ly3wvxl0kdy89khqjj";
})

(pkgs.fetchurl {
  url = "http://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-libmetalink-0.1.3-3-any.pkg.tar.xz";
  sha256 = "1nvjvygcxmrb7xlqzxym3g6vhz31nr83qx2vfsqrc0haw4r08d5j";
})

(pkgs.fetchurl {
  url = "http://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-libpsl-0.21.0-2-any.pkg.tar.xz";
  sha256 = "13456p4kl53i49hz6b9cpjbkb19k4443nksbii9c29x09lagbzwv";
})

(pkgs.fetchurl {
  url = "http://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-libtasn1-4.16.0-1-any.pkg.tar.xz";
  sha256 = "0aziyg127l9742g7i8dl4ffp80v55272i8p3jqk3pvz8qaf8dfyh";
})

(pkgs.fetchurl {
  url = "http://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-libffi-3.3-1-any.pkg.tar.xz";
  sha256 = "05sh8hwr171bbpjw9yf4z04sa3m4dg37kqbdz90y68glrj43i4xd";
})

(pkgs.fetchurl {
  url = "http://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-p11-kit-0.23.20-2-any.pkg.tar.xz";
  sha256 = "02f3k46b09b4rd0fmadavjj04f4a2v1c56r9qlkr5lkjlmfm7a5a";
})

(pkgs.fetchurl {
  url = "http://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-ca-certificates-20190110-1-any.pkg.tar.xz";
  sha256 = "1wjbm67rb07sp803dl51lfsrrih2xjnwbrif0hvsc6nq63q1i3dq";
})

(pkgs.fetchurl {
  url = "http://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-openssl-1.1.1.g-1-any.pkg.tar.xz";
  sha256 = "047x6dxxqm8y8fj236cd3p9jk4cdnmzdp3pgh84gsqa2vgxdn64f";
})

(pkgs.fetchurl {
  url = "http://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-libssh2-1.9.0-1-any.pkg.tar.xz";
  sha256 = "10pd4mmvsrvcs4sw0v786ry3w2xwrli6prnhpwcjfjvb25jn0y9a";
})

(pkgs.fetchurl {
  url = "http://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-jansson-2.12-1-any.pkg.tar.xz";
  sha256 = "133al0y3fg38b303934ls7f7l5f76qy7v6wx2cnxmfq2k0fxj7cc";
})

(pkgs.fetchurl {
  url = "http://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-jemalloc-5.2.1-1-any.pkg.tar.xz";
  sha256 = "1w0mm0wlsx37gbf5vcrbf7c4hvkcrhls8a1aiq3s4vbld8maccdl";
})

(pkgs.fetchurl {
  url = "http://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-nghttp2-1.40.0-2-any.pkg.tar.xz";
  sha256 = "0m2xww09f5j8ii6nqk8wz6g8dy1qbgvv185ikrpabpbdaqgkaijj";
})

(pkgs.fetchurl {
  url = "http://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-curl-7.70.0-1-any.pkg.tar.zst";
  sha256 = "013b04dxcfgcbx9ccknm8rkkxp5lxzi2473li678f0n1dagcxn0d";
})

(pkgs.fetchurl {
  url = "http://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-jsoncpp-1.9.2-1-any.pkg.tar.xz";
  sha256 = "0wdxn26lv9j9fdixcvgbg299wix9xxl48jjdnqf1387aiprhsj4m";
})

(pkgs.fetchurl {
  url = "http://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-bzip2-1.0.8-1-any.pkg.tar.xz";
  sha256 = "1ipndg1lg96hfznhcv8ifazv07944vk387i35rzaaamac2hm7nyf";
})

(pkgs.fetchurl {
  url = "http://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-lz4-1.9.2-1-any.pkg.tar.xz";
  sha256 = "067rm6fjziid747b9lzng4hpzlddqq8d2xfrxd95nzvj4qrj1xli";
})

(pkgs.fetchurl {
  url = "http://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-libtre-git-r128.6fb7206-2-any.pkg.tar.xz";
  sha256 = "0dp3ca83j8jlx32gml2qvqpwp5b42q8r98gf6hyiki45d910wb7x";
})

(pkgs.fetchurl {
  url = "http://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-libsystre-1.0.1-4-any.pkg.tar.xz";
  sha256 = "037gkzaaj8kp5nspcbc8ll64s9b3mj8d6m663lk1za94bq2axff1";
})

(pkgs.fetchurl {
  url = "http://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-nettle-3.6-1-any.pkg.tar.zst";
  sha256 = "1m5kakcfmwvmvajblscq541b40f5zhc01hqgvwlcgpdm4c1mjxhx";
})

(pkgs.fetchurl {
  url = "http://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-xz-5.2.5-1-any.pkg.tar.xz";
  sha256 = "09h7qpy8nrrk3z9fh31k9jc17449qs9cf5v183rz6v6526x3v7jg";
})

(pkgs.fetchurl {
  url = "http://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-libarchive-3.4.3-1-any.pkg.tar.zst";
  sha256 = "1c9wxa9i1hm1yvv82qdzc1pqgrw3gcfc0s9wjah7w1civ9a63flf";
})

(pkgs.fetchurl {
  url = "http://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-libuv-1.38.0-1-any.pkg.tar.zst";
  sha256 = "1x9vz2ib8mgx0g2gxjmyshdcf1qgql0d6hycyh4xf7ns4zk70mh0";
})

(pkgs.fetchurl {
  url = "http://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-rhash-1.3.9-1-any.pkg.tar.xz";
  sha256 = "1a5b1wvljbdn38jcw2w46mcw377aw8k7j93fxsjzghhf9msscl1a";
})

(pkgs.fetchurl {
  url = "http://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-cmake-3.17.3-1-any.pkg.tar.zst";
  sha256 = "0b9zaa11qazsgz88yfm6j93rddnw8mz9zzh8maz3vrmi9p4asldd";
})
]
