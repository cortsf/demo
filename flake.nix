{
  description = "Demo project";
  inputs.haskellNix.url = "github:input-output-hk/haskell.nix";
  inputs.nixpkgs.follows = "haskellNix/nixpkgs-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  outputs = { self, nixpkgs, flake-utils, haskellNix }:
    flake-utils.lib.eachSystem [ "x86_64-linux" ] (system:
    let
      fourmoluFor = system: pkgs.haskell-nix.tool "ghc924" "fourmolu" { };
      overlays = [ haskellNix.overlay
        (final: prev: {
          demo =
            final.haskell-nix.project' {
              src = ./.;
              compiler-nix-name = "ghc924";
              shell.tools = {
                cabal = {};
                hlint = {};
              };
              shell.buildInputs = with pkgs; [
                nixpkgs-fmt
              ];
              shell.nativeBuildInputs =
                [
                  (fourmoluFor system)
                ];

            };
        })
      ];
      pkgs = import nixpkgs { inherit system overlays; inherit (haskellNix) config; };
      flake = pkgs.demo.flake {
      };
    in flake // {
      packages.default = flake.packages."demo:exe:demo";
      hydraJobs = {
        build.x86_64-linux = pkgs.demo;
      };
    });
}
