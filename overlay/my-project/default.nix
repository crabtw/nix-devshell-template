{ lib, buildPackages, stdenv, cmake, python3, ninja, rust
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

  shellHook = lib.optionalString (stdenv.buildPlatform != stdenv.hostPlatform) (with rust; ''
    export CC_${toRustTargetForUseInEnvVars stdenv.hostPlatform}="${envVars.ccForHost}"
    export CXX_${toRustTargetForUseInEnvVars stdenv.hostPlatform}="${envVars.cxxForHost}"
    export CARGO_TARGET_${toRustTargetForUseInEnvVars stdenv.hostPlatform}_LINKER="${envVars.ccForHost}"
  '' + ''
    export CC_${toRustTargetForUseInEnvVars stdenv.buildPlatform}="${envVars.ccForBuild}"
    export CXX_${toRustTargetForUseInEnvVars stdenv.buildPlatform}="${envVars.cxxForBuild}"
    export CARGO_TARGET_${toRustTargetForUseInEnvVars stdenv.buildPlatform}_LINKER="${envVars.ccForBuild}"
    export CARGO_BUILD_TARGET="${envVars.rustBuildPlatform}"
  '' + ''
    export HOST_CC="${buildPackages.stdenv.cc}/bin/cc"
    export HOST_CXX="${buildPackages.stdenv.cc}/bin/c++"
  '');
}
