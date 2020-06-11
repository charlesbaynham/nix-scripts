{ pkgs ? import <nixpkgs> {}
, lib ? pkgs.lib
}:

/*

This file creates a simple custom simple bundle format containing
a powershell script plus any required executables and assets.

These are assets that are only handled in the pure build steps.

Impure packages are installed in _another_ step that runs impurely outside of
the Nix sandbox.

*/

let

  makeBundle =
    { name
    , bundle
    }: pkgs.runCommandNoCC "${name}-archive.tar" {} ''
      cp -r -L ${bundle} build
      tar -cpf $out -C build .
    '';


in
rec {

  /*
  Make a custom install bundle
  */
  makePkg =
    { name
    , src
    , installScript
    }: let
      installScript_ = pkgs.writeText "${name}-install-script" installScript;

      bundle = pkgs.runCommandNoCC "${name}-bundle" {} ''
        mkdir build
        ln -s ${src} build/"$(stripHash "${src}")"
        ln -s ${installScript_} build/install.ps1
        mv build $out
      '';
    in
      makeBundle {
        inherit name bundle;
      };


  /*
  Make an install bundle from a .msi
  */
  makeMSIPkg =
    { name
    , msi
    , cert ? null
    , ADDLOCAL ? []
    , preInstall ? ""
    , postInstall ? ""
    }: let
      installScript = pkgs.writeText "${name}-install-script" ''
        ${preInstall}
        ${if cert != null then "certutil.exe -f -addstore TrustedPublisher cert.cer" else ""}
        msiexec.exe /i .\${name}.msi ${if ADDLOCAL != [] then "ADDLOCAL=" else ""}${lib.concatStringsSep "," ADDLOCAL}
        ${postInstall}
      '';

      bundle = pkgs.runCommandNoCC "${name}-bundle" {} ''
        mkdir build
        ln -s ${msi} build/${name}.msi
        ${if cert != null then "ln -s ${cert} build/cert.cer" else ""}
        ln -s ${installScript} build/install.ps1
        mv build $out
      '';
    in
      makeBundle {
        inherit name bundle;
      };

  /*
  Nix cross-built packages
  */
  makeCrossPkg =
    { name
    , pkg
    , destination ? ''C:\Program Files\${name}\''
    , preInstall ? ""
    , postInstall ? ""
    }: let
      installScript = pkgs.writeText "${name}-install-script" ''
        ${preInstall}
        Copy-Item pkg -Destination "${destination}"
        ${postInstall}
      '';

      bundle = pkgs.runCommandNoCC "${name}-bundle" {} ''
        mkdir -p build/pkg
        ln -s ${pkg} build/pkg
        ln -s ${installScript} build/install.ps1
        mv build $out
      '';
    in
      makeBundle {
        inherit name bundle;
      };

}
