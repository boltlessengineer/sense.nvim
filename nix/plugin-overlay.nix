{ self }: final: prev: let
  luaPackages-override = luaself: luaprev: {
    sense-nvim = luaself.callPackage ({
      buildLuarocksPackage,
      fetchurl,
      fetchzip,
      luaOlder,
    }:
      buildLuarocksPackage {
        pname = "sense.nvim";
        version = "scm-1";
        knownRockspec = "${self}/sense.nvim-scm-1.rockspec";
        src = self;

        disabled = luaOlder "5.1";
        propagatedBuildInputs = with luaself; [
        ];
      }) {};
  };
  lua5_1 = prev.lua5_1.override {
    packageOverrides = luaPackages-override;
  };
  lua51Packages = prev.lua51Packages // final.lua5_1.pkgs;

  sense-nvim-dev = final.neovimUtils.buildNeovimPlugin {
    luaAttr = final.lua51Packages.sense-nvim;
  };
in {
  inherit
    lua5_1
    lua51Packages
    sense-nvim-dev
    ;
  vimPlugins = prev.vimPlugins // {
    sense-nvim = sense-nvim-dev;
  };
  neovim-test-drive = let
    neovimConfig = final.neovimUtils.makeNeovimConfig {
      viAlias = false;
      vimAlias = false;
      plugins = [
        final.vimPlugins.sense-nvim
      ];
    };
  in (final.wrapNeovimUnstable final.neovim-nightly (neovimConfig // {
    luaRcContent = /* lua */ ''
      vim.o.number = true
      vim.o.relativenumber = true
      vim.lsp.config("gopls", {
        cmd = { "gopls" },
        root_markers = { ".git" },
        filetypes = { "go" },
      })
      vim.lsp.enable("gopls")
    '';
  }))
    .overrideAttrs (oa: {
      nativeBuildInputs = oa.nativeBuildInputs ++ [
        final.luajit.pkgs.wrapLua
        final.gopls
      ];
    });
}
