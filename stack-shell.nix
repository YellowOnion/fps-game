{ nixpkgs ? import <nixpkgs> { } # import ./pinned-nixpkgs.nix {}
, ghc
}:

with nixpkgs;

haskell.lib.buildStackProject {
  inherit ghc;
  name = "fps-godot-haskell";
  buildInputs = [];
}


