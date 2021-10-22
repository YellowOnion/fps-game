{ pkgs ? import <nixpkgs> {}, compiler ? "ghc8104" }:

with pkgs;
let
  hsp = pkgs.haskell.packages.${compiler};

  pkg = hsp.callPackage ./. { } ;
  #pkg = (import ./. { inherit pkgs compiler stdenv; });

in
hsp.shellFor {
  packages = p: [];
  withHoogle = true;
  buildInputs = [ godot hsp.hoogle hsp.haskell-language-server pkgs.stack];
}
