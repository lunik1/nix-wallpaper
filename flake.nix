{
  description = "A configurable wallpaper for nix systems";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };
  };

  outputs = inputs@{ self, ... }:
    with inputs;
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = import nixpkgs { inherit system; };
      in {
        packages.default = pkgs.callPackage ./pkg { };

        devShells.default = with pkgs;
          mkShell {
            inherit (self.checks.${system}.pre-commit-check) shellHook;
            packages = [
              nixpkgs-fmt
              rnix-lsp
              statix
              imagemagick
            ];
          };

        formatter = pkgs.nixpkgs-fmt;

        checks = {
          pre-commit-check = pre-commit-hooks.lib.${system}.run {
            src = ./.;
            hooks = {
              nixpkgs-fmt.enable = true;
              copier-rejects = {
                enable = true;
                entry =
                  "found Copier update rejection files; review them and remove them";
                files = "\\.rej$";
                language = "fail";
              };
            };
          };
        };
      });
}
