{
  self,
  inputs,
}: final: prev: let
  mkNeorocksTest = name: nvim:
    with final;
      neorocksTest {
        inherit name;
        pname = "sense.nvim";
        src = self;
        neovim = nvim;
        luaPackages = ps:
          with ps; [
            luautf8
          ];
        extraPackages = [];

        preCheck = ''
          # Neovim expects to be able to create log files, etc.
          export HOME=$(realpath .)
          export SENSE_NVIM_PLUGIN_DIR=${final.sense-nvim-dev}
        '';
      };
  docgen = final.writeShellApplication {
    name = "docgen";
    runtimeInputs = [
      inputs.vimcats.packages.${final.system}.default
    ];
    text = ''
      mkdir -p doc
      echo "todo"
      # vimcats lua/sense/init.lua > doc/sense.txt
    '';
  };
in {
  # TODO: test with neovim v0.10.2 instead
  neovim-stable-test = mkNeorocksTest "neovim-stable-test" final.neovim;
  neovim-nightly-test = mkNeorocksTest "neovim-nightly-test" final.neovim-nightly;
  inherit docgen;
}
