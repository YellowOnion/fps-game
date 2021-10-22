{ mkDerivation, base, containers, godot-haskell, lens, lib, linear
, stm, template-haskell, text, th-abstraction, vector
}:
mkDerivation {
  pname = "fps-game";
  version = "0.0.0.0";
  src = ./.;
  libraryHaskellDepends = [
    base containers godot-haskell lens linear stm template-haskell text
    th-abstraction vector
  ];
  homepage = "https://github.com/YellowOnion/fps-game#readme";
  license = lib.licenses.bsd3;
}
