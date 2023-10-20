{ lib, stdenv, cmake, python3, ninja, rustc, cargo
, swig4, windows }:

stdenv.mkDerivation {
  name = "project";
  src = null;

  nativeBuildInputs = [
    cmake
    python3
    ninja
    rustc
    cargo
    swig4
  ];

  buildInputs = lib.optionals stdenv.hostPlatform.isMinGW [
    windows.mingw_w64_pthreads
  ];
}
