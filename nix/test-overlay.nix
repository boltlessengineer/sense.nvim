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
        extraPackages = [
          wget
          git
          gopls
        ];

        preCheck = ''
          # Neovim expects to be able to create log files, etc.
          export HOME=$(realpath .)
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
  integration-stable = mkNeorocksTest "integration-stable" final.neovim;
  integration-nightly = mkNeorocksTest "integration-nightly" final.neovim-nightly;
  inherit docgen;
}
