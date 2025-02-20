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
      vimcats lua/sense/{init,config/init}.lua > doc/sense.txt
      vimcats lua/sense/{api,ui/*,helper,_meta}.lua > doc/sense-api.txt
    '';
  };
  sync-readme = final.writeShellApplication {
    name = "sync-readme";
    text = /* bash */ ''
      set -e

      default=lua/sense/config/default.lua

      # Create a temporary file for the copied snippet
      snippet=$(mktemp)
      echo "1. Extract the config snippet from $default"
      sed -n '/default-config:start/,/default-config:end/ {
        /default-config:start/d
        /default-config:end/d
        p
      }' "$default" > "$snippet"

      echo '2. Build new README content'
      # Create a temporary file for the updated README.
      tmpfile=$(mktemp)

      echo '2-1. Print all lines up to the starting marker'
      sed '/default-config:start/q' README.md > "$tmpfile"

      echo '2-2. Append the new code block'
      {
        echo '```lua'
        cat "$snippet"
        echo '```'
      } >> "$tmpfile"

      echo '2-3. Append the rest of the README starting from the ending marker'
      sed -n '/default-config:end/,$p' README.md >> "$tmpfile"

      echo '3. Replace the old README with the new version'
      mv "$tmpfile" README.md

      rm "$snippet"

      echo "README.md updated successfully."
    '';
  };
in {
  # TODO: test with neovim v0.10.2 instead
  neovim-stable-test = mkNeorocksTest "neovim-stable-test" final.neovim;
  neovim-nightly-test = mkNeorocksTest "neovim-nightly-test" final.neovim-nightly;
  inherit docgen sync-readme;
}
