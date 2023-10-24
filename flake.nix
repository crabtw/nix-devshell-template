{
  inputs.nixpkgs.url = "nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
  let
    systems = [ "x86_64-linux" ];

    forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system);

    overlay = final: prev: {
      useLldLinker = stdenv:
      let
        lld = prev.buildPackages.llvmPackages_16.lld;
        bintools = stdenv.cc.bintools.override {
          extraBuildCommands = ''
            wrap ${stdenv.cc.bintools.targetPrefix}ld.lld ${prev.path}/pkgs/build-support/bintools-wrapper/ld-wrapper.sh ${lld}/bin/ld.lld
            wrap ${stdenv.cc.bintools.targetPrefix}ld ${prev.path}/pkgs/build-support/bintools-wrapper/ld-wrapper.sh ${lld}/bin/ld.lld
          '';
        };
      in stdenv.override (old: {
        allowedRequisites = null;
        cc = stdenv.cc.override { inherit bintools; };
      });

      mkShell = prev.mkShell.override (old: {
        stdenv = final.useLldLinker old.stdenv;
      });

      my-project = prev.callPackage ./project {
        stdenv = final.useLldLinker prev.stdenv;
      };
    };

    shells = forAllSystems (system:
    let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ overlay ];
      };

      pkgsMingw = pkgs.pkgsCross.mingwW64;

      emulator = pkgs.wine64Packages.minimal;
    in {
      default = pkgs.mkShell {
        inputsFrom = [ pkgs.my-project ];
      };

      mingw = pkgsMingw.callPackage ({ mkShell, python311, my-project }:
      let
        my-project' = my-project.override { python3 = python311; };
      in mkShell {
        nativeBuildInputs = [ emulator ];

        inputsFrom = [ my-project' ];
      }) {};
    });
  in {
    devShells = shells;
  };
}
