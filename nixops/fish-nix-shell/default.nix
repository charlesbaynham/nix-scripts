with import <nixpkgs> {}; stdenv.mkDerivation rec {
  name = "fish-nix-shell";
  src = fetchGit "https://github.com/haslersn/fish-nix-shell";
  nativeBuildInputs = [ makeWrapper ];
  installPhase = ''
    mkdir -p $out
    cp LICENSE $out
    cp -r bin $out
    wrapProgram $out/bin/fish-nix-shell
    wrapProgram $out/bin/fish-nix-shell-wrapper --prefix PATH ":" ${fish}/bin
    wrapProgram $out/bin/nix-shell-info
  '';
  meta.description = "fish support for the nix-shell environment of the Nix package manager.";
  meta.license = "MIT";
  meta.homepage = https://github.com/haslersn/fish-nix-shell;
}