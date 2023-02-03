{
  description = "A configurable wallpaper for nix systems";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };
  };

  outputs = inputs@{ self, ... }:
    with inputs;
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = import nixpkgs { inherit system; };
      in
      {
        packages.default = pkgs.runCommand "nix-wallpaper" { } ''
          mkdir -p $out/bin
          printf "#!${pkgs.bash}/bin/bash\n\nprintf 'Hello, world!\\n'" \
            > $out/bin/nix-wallpaper
          chmod +x $out/bin/nix-wallpaper
        '';

        apps.default = {
          type = "app";
          program = "${self.packages.${system}.default}/bin/nix-wallpaper";
        };

        devShells.default = with pkgs;
          mkShell {
            inherit (self.checks.${system}.pre-commit-check) shellHook;
            buildInputs = [
              nixpkgs-fmt
              rnix-lsp
              statix

              librsvg
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
                entry = "found Copier update rejection files; review them and remove them";
                files = "\\.rej$";
                language = "fail";
              };
            };
          };
        };
      });
}
