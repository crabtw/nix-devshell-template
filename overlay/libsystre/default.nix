{ lib, stdenv, fetchurl, autoreconfHook, libtre }:

let
  pname = "libsystre";
  version = "1.0.1";
  revision = "07b84dbe6108d3b61208889124f080f9034d74fa";
in stdenv.mkDerivation {
  inherit pname;
  inherit version;

  src = fetchurl {
    url = "https://github.com/msys2/MINGW-packages/raw/${revision}/mingw-w64-libsystre/systre-${version}.tar.xz";
    hash = "sha256-kJoFigHz3zrz8DA0KnKDAyuLJAwP1m8ir4Du5nT9OaI=";
  };

  nativeBuildInputs = [
    autoreconfHook
  ];

  propagatedBuildInputs = [
    libtre
  ];

  postInstall = lib.optionalString (!stdenv.hostPlatform.isStatic) ''
    rm $out/lib/libgnurx.a
    rm $out/lib/libregex.a
  '';

  meta = {
    platforms = lib.platforms.windows;
  };
}
