{
  inputs.nixpkgs.url = "nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      systems = [ "x86_64-linux" ];

      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system);

      shells = forAllSystems (system:
        let
          pkgs = import nixpkgs { inherit system; };
          mingwPkgs = pkgs.pkgsCross.mingwW64;

          emulator = pkgs.wine64Packages.minimal;

          project = mingwPkgs.callPackage ./project {};
        in {
          default = mingwPkgs.callPackage ({ mkShell }: mkShell {
            nativeBuildInputs = [ emulator ];

            inputsFrom = [ project ];
          }) {};
        }
      );
    in {
      devShells = shells;
    };
}
