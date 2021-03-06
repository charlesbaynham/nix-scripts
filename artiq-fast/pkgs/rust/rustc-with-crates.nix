{ stdenv, callPackage, recurseIntoAttrs, makeRustPlatform, llvm-or1k, fetchurl
, targets ? []
, targetToolchains ? []
, targetPatches ? []
, fetchFromGitHub
, runCommand
}:

let
  rustPlatform = recurseIntoAttrs (makeRustPlatform (callPackage ./bootstrap.nix {}));
  version = "1.28.0";
  src = fetchFromGitHub {
    owner = "m-labs";
    repo = "rust";
    sha256 = "03lfps3xvvv7wv1nnwn3n1ji13z099vx8c3fpbzp9rnasrwzp5jy";
    rev = "f305fb024318e96997fbe6e4a105b0cc1052aad4"; #  artiq-1.28.0 branch
    fetchSubmodules = true;
  };
  rustc_internal = callPackage ./rustc.nix {
    inherit stdenv llvm-or1k targets targetPatches targetToolchains rustPlatform version src;

    patches = [
      ./patches/net-tcp-disable-tests.patch

      # Re-evaluate if this we need to disable this one
      #./patches/stdsimd-disable-doctest.patch

      # Fails on hydra - not locally; the exact reason is unknown.
      # Comments in the test suggest that some non-reproducible environment
      # variables such $RANDOM can make it fail.
      ./patches/disable-test-inherit-env.patch
    ];

    #configureFlags = [ "--release-channel=stable" ];

    # 1. Upstream is not running tests on aarch64:
    # see https://github.com/rust-lang/rust/issues/49807#issuecomment-380860567
    # So we do the same.
    # 2. Tests run out of memory for i686
    #doCheck = !stdenv.isAarch64 && !stdenv.isi686;

    # Disabled for now; see https://github.com/NixOS/nixpkgs/pull/42348#issuecomment-402115598.
    doCheck = false;
  };
  or1k-crates = stdenv.mkDerivation {
    name = "or1k-crates";
    inherit src;
    phases = [ "unpackPhase" "buildPhase" ];
    buildPhase = ''
      destdir=$out
      rustc="${rustc_internal}/bin/rustc --out-dir ''${destdir} -L ''${destdir} --target or1k-unknown-none -g -C target-feature=+mul,+div,+ffl1,+cmov,+addc -C opt-level=s --crate-type rlib"
      
      mkdir -p ''${destdir}
      ''${rustc} --crate-name core src/libcore/lib.rs
      ''${rustc} --crate-name compiler_builtins src/libcompiler_builtins/src/lib.rs --cfg 'feature="compiler-builtins"' --cfg 'feature="mem"'
      ''${rustc} --crate-name std_unicode src/libstd_unicode/lib.rs
      ''${rustc} --crate-name alloc src/liballoc/lib.rs
      ''${rustc} --crate-name libc src/liblibc_mini/lib.rs
      ''${rustc} --crate-name unwind src/libunwind/lib.rs
      ''${rustc} -Cpanic=abort --crate-name panic_abort src/libpanic_abort/lib.rs
      ''${rustc} -Cpanic=unwind --crate-name panic_unwind src/libpanic_unwind/lib.rs --cfg llvm_libunwind
    '';
  };
  arm-crates = stdenv.mkDerivation {
    name = "arm-crates";
    inherit src;
    phases = [ "unpackPhase" "buildPhase" ];
    buildPhase = ''
      destdir=$out
      rustc="${rustc_internal}/bin/rustc --out-dir ''${destdir} -L ''${destdir} --target armv7-unknown-linux-gnueabihf -g -C target-feature=+dsp,+fp16,+neon,+vfp3 -C opt-level=s --crate-type rlib"

      mkdir -p ''${destdir}
      ''${rustc} --crate-name core src/libcore/lib.rs
      ''${rustc} --crate-name compiler_builtins src/libcompiler_builtins/src/lib.rs --cfg 'feature="compiler-builtins"' --cfg 'feature="mem"'
      ''${rustc} --crate-name std_unicode src/libstd_unicode/lib.rs
      ''${rustc} --crate-name alloc src/liballoc/lib.rs
      ''${rustc} --crate-name libc src/liblibc_mini/lib.rs
      ''${rustc} --crate-name unwind src/libunwind/lib.rs
      ''${rustc} -Cpanic=abort --crate-name panic_abort src/libpanic_abort/lib.rs
      ''${rustc} -Cpanic=unwind --crate-name panic_unwind src/libpanic_unwind/lib.rs --cfg llvm_libunwind
    '';
  };
in
  stdenv.mkDerivation {
    name = "rustc";
    inherit src version;
    buildCommand = ''
      mkdir -p $out/lib/rustlib/or1k-unknown-none/lib/
      cp -r ${or1k-crates}/* $out/lib/rustlib/or1k-unknown-none/lib/
      mkdir -p $out/lib/rustlib/armv7-unknown-linux-gnueabihf/lib/
      cp -r ${arm-crates}/* $out/lib/rustlib/armv7-unknown-linux-gnueabihf/lib/
      cp -r ${rustc_internal}/* $out
      '';
    passAsFile = [ "buildCommand" ];
  }
