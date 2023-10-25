{ lib, stdenv, cmake, python3, ninja, rust
, windows }:

let

  rustPkgs = rust.packages.stable;

in stdenv.mkDerivation {
  name = "my-project";
  src = null;

  nativeBuildInputs = [
    cmake
    python3
    ninja
    rustPkgs.rustc
    rustPkgs.cargo
  ];

  buildInputs = lib.optionals stdenv.hostPlatform.isMinGW [
    windows.mingw_w64_pthreads
    windows.libsystre
  ];
}
