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
  sense-nvim-dev = final.neovimUtils.buildNeovimPlugin {
    luaAttr = final.lua51Packages.sense-nvim;
  };
in {
  lua5_1 = prev.lua5_1.override {
    packageOverrides = luaPackages-override;
  };
  lua51Packages = prev.lua51Packages // final.lua5_1.pkgs;
  inherit sense-nvim-dev;
}
