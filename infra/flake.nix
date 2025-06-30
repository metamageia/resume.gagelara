{
  description = "Cloud Resume Challenge development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; config.allowUnfree = true;};
      in {
        devShells.default = pkgs.mkShell {
          buildInputs = [
            pkgs.terraform
          ];
          shellHook = ''
            echo "Welcome to the CRC Infra development environment!"
          '';
        };
      });
}