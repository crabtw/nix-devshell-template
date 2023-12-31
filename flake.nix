{
  inputs.nixpkgs.url = "nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
  let
    systems = [ "x86_64-linux" ];

    forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system);

    shells = forAllSystems (system:
    let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ (import ./overlay) ];
      };

      pkgsMingw = pkgs.pkgsCross.mingwW64;

      emulator = pkgs.wine64Packages.minimal;
    in {
      default = pkgs.mkShell {
        inputsFrom = [ pkgs.my-project ];
      };

      mingw = pkgsMingw.callPackage ({ mkShell, my-project }: mkShell {
        nativeBuildInputs = [ emulator ];
        inputsFrom = [ my-project ];
      }) {};
    });
  in {
    devShells = shells;
  };
}
