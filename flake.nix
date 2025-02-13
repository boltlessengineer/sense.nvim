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
    plugin-overlay = import ./nix/plugin-overlay.nix {
      inherit self;
    };
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
            plugin-overlay
            test-overlay
          ];
        };
      in {
        packages = {
          default = self.packages.${system}.luarocks-51;
          luarocks-51 = pkgs.lua51Packages.luarocks;
          inherit
            (pkgs)
            docgen
            neovim-test-drive
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

        devShells.default = pkgs.mkShell {
          name = "sense.nvim devShell";
          shellHook = ''
            export LUA_PATH="$(luarocks path --lr-path --lua-version 5.1 --local)"
            export LUA_CPATH="$(luarocks path --lr-cpath --lua-version 5.1 --local)"
          '';
          buildInputs = [
            pkgs.sumneko-lua-language-server
            pkgs.stylua
            pkgs.docgen
            pkgs.neovim-nightly
            (pkgs.lua5_1.withPackages (ps: with ps; [luarocks luacheck]))
          ];
        };

        checks = {
          inherit
            (pkgs)
            neovim-stable-test
            neovim-nightly-test
            ;
        };
      };
    };
}
