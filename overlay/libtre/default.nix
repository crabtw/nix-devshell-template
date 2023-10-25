{ lib, stdenv, fetchFromGitHub, fetchpatch, autoreconfHook }:

let

  mingwPatchUrl = f:
  let
    pkg = "mingw-w64-libtre-git";
    rev = "f3b63f0f19317ad8098226e9443fe56e5b008f4d";
  in
    "https://raw.githubusercontent.com/msys2/MINGW-packages/" + rev + "/" + pkg + "/" + f;

in stdenv.mkDerivation {
  pname = "libtre";
  version = "0.8.0";

  src = fetchFromGitHub {
    owner = "laurikari";
    repo = "tre";
    rev = "6fb7206b935b35814c5078c20046dbe065435363";
    hash = "sha256-mMElv8w1TggMiW4LAMty+PBBZMexQIWiY4ru9Mnqu30=";
  };

  nativeBuildInputs = [
    autoreconfHook
  ];

  patches = [
    (fetchpatch {
      url = mingwPatchUrl "001-autotools.patch";
      hash = "sha256-1Vx0w/f0eLlDw7IJqm7X26S3Y59qNO3qJwHBFpg1J5A=";
    })
    (fetchpatch {
      url = mingwPatchUrl "002-pointer-cast.patch";
      hash = "sha256-csh7lW6t4X7VREw8bq574JuT0UVXPyABfsWQ2cJRbFI=";
    })
  ];

  meta = {
    platforms = lib.platforms.windows;
  };
}
