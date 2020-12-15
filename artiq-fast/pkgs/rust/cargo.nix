{ stdenv, file, curl, pkgconfig, python, openssl, cmake, zlib
, makeWrapper, libiconv, cacert, rustPlatform, rustc, libgit2
, fetchurl
}:

rustPlatform.buildRustPackage rec {
  # Note: we can't build cargo 1.28.0 because rustc tightened the borrow checker rules and broke
  # backward compatibility, which affects old cargo versions.
  # There are also issues with asm/llvm_asm with recent rustc and cargo versions prior to 1.39.
  pname = "cargo";
  version = "1.39.0";
  src = fetchurl {
    url = "https://static.rust-lang.org/dist/rustc-1.39.0-src.tar.gz";
    sha256 = "0mwkc1bnil2cfyf6nglpvbn2y0zfbv44zfhsd5qg4c9rm6vgd8dl";
  };

  # the rust source tarball already has all the dependencies vendored, no need to fetch them again
  cargoVendorDir = "vendor";
  preBuild = "pushd src/tools/cargo";
  postBuild = "popd";

  passthru.rustc = rustc;

  # changes hash of vendor directory otherwise
  dontUpdateAutotoolsGnuConfigScripts = true;

  nativeBuildInputs = [ pkgconfig cmake makeWrapper ];
  buildInputs = [ cacert file curl python openssl zlib libgit2 ];

  LIBGIT2_SYS_USE_PKG_CONFIG = 1;

  # fixes: the cargo feature `edition` requires a nightly version of Cargo, but this is the `stable` channel
  RUSTC_BOOTSTRAP = 1;

  postInstall = ''
    # NOTE: We override the `http.cainfo` option usually specified in
    # `.cargo/config`. This is an issue when users want to specify
    # their own certificate chain as environment variables take
    # precedence
    wrapProgram "$out/bin/cargo" \
      --suffix PATH : "${rustc}/bin" \
      --set CARGO_HTTP_CAINFO "${cacert}/etc/ssl/certs/ca-bundle.crt" \
      --set SSL_CERT_FILE "${cacert}/etc/ssl/certs/ca-bundle.crt"
  '';

  checkPhase = ''
    # Disable cross compilation tests
    export CFG_DISABLE_CROSS_TESTS=1
    cargo test
  '';

  # Disable check phase as there are failures (4 tests fail)
  doCheck = false;

  meta = with stdenv.lib; {
    homepage = https://crates.io;
    description = "Downloads your Rust project's dependencies and builds your project";
    maintainers = with maintainers; [ wizeman retrry ];
    license = [ licenses.mit licenses.asl20 ];
    platforms = platforms.unix;
  };
}
