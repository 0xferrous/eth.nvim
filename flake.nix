{
  description = "eth.nvim - Ethereum block explorer navigation plugin for Neovim";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        
        luaPackages = pkgs.lua54Packages;
        
        testDeps = with luaPackages; [
          busted
          luacov
          luacheck
          dkjson
        ];
        
        devDeps = with pkgs; [
          lua5_4
          stylua
          selene
        ] ++ testDeps;
        
      in {
        devShells.default = pkgs.mkShell {
          buildInputs = devDeps;
          
          shellHook = ''
            echo "🚀 eth.nvim development environment"
            echo "Available tools:"
            echo "  - lua: Lua interpreter"
            echo "  - busted: Test runner"
            echo "  - luacov: Coverage analysis"
            echo "  - luacheck: Static analyzer"
            echo "  - stylua: Code formatter"
            echo "  - selene: Modern Lua linter"
            echo ""
            echo "Run tests with: busted"
            echo "Format code with: stylua ."
            echo "Lint code with: luacheck lua/"
            
            export LUA_PATH="./lua/?.lua;./lua/?/init.lua;$LUA_PATH"
          '';
        };
        
        packages = {
          default = pkgs.stdenv.mkDerivation {
            pname = "eth-nvim";
            version = "0.1.0";
            
            src = ./.;
            
            buildInputs = [ pkgs.lua5_4 ];
            
            installPhase = ''
              mkdir -p $out/share/nvim/site/pack/eth-nvim/start/eth-nvim
              cp -r lua $out/share/nvim/site/pack/eth-nvim/start/eth-nvim/
              cp README.md $out/share/nvim/site/pack/eth-nvim/start/eth-nvim/
            '';
          };
        };
        
        checks = {
          test = pkgs.stdenv.mkDerivation {
            name = "eth-nvim-tests";
            src = ./.;
            
            buildInputs = devDeps;
            
            buildPhase = ''
              export LUA_PATH="./?.lua;./lua/?.lua;./lua/?/init.lua;./spec/?.lua;./spec/?/init.lua;$LUA_PATH"
              
              # Set up vim mock inline  
              cat > vim_mock.lua << 'EOF'
              _G.vim = {
                tbl_deep_extend = function(behavior, ...)
                  local result = {}
                  local function deep_extend(target, source)
                    for k, v in pairs(source) do
                      if type(v) == "table" and type(target[k]) == "table" then
                        target[k] = deep_extend(target[k], v)
                      else
                        target[k] = v
                      end
                    end
                    return target
                  end
                  for _, tbl in ipairs({...}) do
                    result = deep_extend(result, tbl)
                  end
                  return result
                end,
                keymap = { set = function() end },
                notify = function() end,
                log = { levels = { DEBUG = 0, INFO = 1, WARN = 2, ERROR = 3 } },
                json = {
                  encode = function(data) return require("dkjson").encode(data) end,
                  decode = function(str) return require("dkjson").decode(str) end
                },
                fn = { 
                  has = function(f) return f == "unix" and 1 or 0 end,
                  getpos = function() return {0, 1, 1, 0} end,
                  getline = function() return "0x742d35cc6635c0532925a3b8d3ac25e0b7e4576c" end,
                  jobstart = function() return 1 end,
                  stdpath = function(type) return "/tmp" end,
                  getcwd = function() return "/test/project" end,
                  isdirectory = function() return 0 end,
                  mkdir = function() return true end,
                  filereadable = function(path) 
                    if path and path:match("/tmp/eth%-nvim/frecency%.json") then
                      local file = io.open(path, "r")
                      if file then file:close() return 1 end
                    end
                    return 0
                  end,
                  fnamemodify = function(path, modifier) return path end
                },
                ui = { select = function(choices, opts, cb) if #choices > 0 then cb(choices[1], 1) end end }
              }
              EOF
              
              export LUA_INIT="dofile('vim_mock.lua')"
              
              busted --verbose --coverage
            '';
            
            installPhase = ''
              mkdir -p $out
              echo "Tests passed" > $out/result
            '';
          };
          
          lint = pkgs.stdenv.mkDerivation {
            name = "eth-nvim-lint";
            src = ./.;
            
            buildInputs = [ pkgs.lua5_4 luaPackages.luacheck ];
            
            buildPhase = ''
              luacheck lua/ --globals vim
            '';
            
            installPhase = ''
              mkdir -p $out
              echo "Linting passed" > $out/result
            '';
          };
        };
      });
}