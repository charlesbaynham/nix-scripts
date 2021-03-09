{ stdenv, lib
, fetchFromGitHub, runCommand
, perl, groff, cmake, libxml2, python, libffi, valgrind
}:

let
  llvm-src = fetchFromGitHub {
    rev = "7746fe85489e92e1caffda18b9d7b2ae9e5da1a8";
    owner = "m-labs";
    repo = "llvm-or1k";
    sha256 = "0jqbb3k9r91swsyrdak8fzvs1qi451zy8dqmpqriaxk5g83ny5b7";
  };
  clang-src = fetchFromGitHub {
    rev = "9e996136d52ed506ed8f57ef8b13b0f0f735e6a3";
    owner = "m-labs";
    repo = "clang-or1k";
    sha256 = "0w5f450i76y162aswi2c7jip8x3arzljaxhbqp8qfdffm0rdbjp4";
  };
  llvm-clang-src = runCommand "llvm-clang-src" {}
    ''
    mkdir -p $out
    mkdir -p $out/tools/clang
    cp -r ${llvm-src}/* $out/
    cp -r ${clang-src}/* $out/tools/clang
    '';
in
  stdenv.mkDerivation rec {
    pname = "llvm-or1k";
    version = "6.0.0";
    passthru.llvm-src = llvm-src;
    src = llvm-clang-src;

    buildInputs = [ perl groff cmake libxml2 python libffi ] ++ lib.optional stdenv.isLinux valgrind;

    preBuild = ''
      NIX_BUILD_CORES=4
      makeFlagsArray=(-j''$NIX_BUILD_CORES)
      mkdir -p $out/
    '';

    cmakeFlags = with stdenv; [
      "-DCMAKE_BUILD_TYPE=Release"
      "-DLLVM_BUILD_LLVM_DYLIB=ON"
      "-DLLVM_LINK_LLVM_DYLIB=ON"
      "-DLLVM_TARGETS_TO_BUILD=X86;ARM"
      "-DLLVM_EXPERIMENTAL_TARGETS_TO_BUILD=OR1K"
      "-DLLVM_ENABLE_ASSERTIONS=OFF"
      "-DLLVM_INSTALL_UTILS=ON"
      "-DLLVM_INCLUDE_TESTS=OFF"
      "-DLLVM_INCLUDE_DOCS=OFF"
      "-DLLVM_INCLUDE_EXAMPLES=OFF"
      "-DCLANG_ENABLE_ARCMT=OFF"
      "-DCLANG_ENABLE_STATIC_ANALYZER=OFF"
      "-DCLANG_INCLUDE_TESTS=OFF"
      "-DCLANG_INCLUDE_DOCS=OFF"
    ];

    enableParallelBuilding = true;
    meta = {
      description = "Collection of modular and reusable compiler and toolchain technologies";
      homepage = http://llvm.org/;
      license = lib.licenses.bsd3;
      maintainers = with lib.maintainers; [ sb0 ];
      platforms = lib.platforms.all;
    };
  }
