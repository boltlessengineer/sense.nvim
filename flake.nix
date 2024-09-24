{
  description = "sense.nvim";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    neorocks.url = "github:nvim-neorocks/neorocks";
    flake-parts.url = "github:hercules-ci/flake-parts";
    vimcats.url = "github:mrcjkb/vimcats";
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    neorocks,
    flake-parts,
    ...
  }: let
    test-overlay = import ./nix/test-overlay.nix {
      inherit self inputs;
    };
  in
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = [
        "x86_64-linux"
        "x86_64-darwin"
        "aarch64-linux"
        "aarch64-darwin"
      ];
      perSystem = {
        config,
        self',
        inputs',
        system,
        ...
      }: let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            neorocks.overlays.default
            test-overlay
          ];
        };

        devShell = pkgs.mkShell {
          name = "sense.nvim devShell";
          shellHook = ''
          '';
          buildInputs = [
            pkgs.sumneko-lua-language-server
            pkgs.stylua
            pkgs.docgen
            (pkgs.lua5_1.withPackages (ps: with ps; [luarocks luacheck]))
          ];
        };
      in {
        packages = {
          default = self.packages.${system}.luarocks-51;
          luarocks-51 = pkgs.lua51Packages.luarocks;
          inherit
            (pkgs)
            docgen
            ;
        };
        # packages = rec {
        #   default = sense-nvim;
        #   inherit (pkgs.luajitPackages) sense-nvim;
        #   inherit
        #     (pkgs)
        #     docgen
        #     ;
        # };

        devShells = {
          default = devShell;
          inherit devShell;
        };

        checks = {
          inherit
            (pkgs)
            # integration-stable
            integration-nightly
            ;
        };
      };
    };
}
