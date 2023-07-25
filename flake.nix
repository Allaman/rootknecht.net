{
  description = "Rootknecht.net Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-23.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    { self
    , nixpkgs
    , flake-utils
    }:

    flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs { inherit system; };
    in
    {
      devShells.default = pkgs.mkShellNoCC {
        packages = with pkgs; [
          hugo
          jdk19_headless

        ];

        shellHook = ''
          ${pkgs.hugo}/bin/hugo version
        '';
      };
    });
}
