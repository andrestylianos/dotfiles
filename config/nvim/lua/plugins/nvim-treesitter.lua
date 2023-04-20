return {
  { 
    "mrjones2014/nvim-ts-rainbow"
  },
  {
    "nvim-treesitter/playground"
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      auto_install = false;
      ensure_installed = {
        "clojure"
      },
      highlight = {
        additional_vim_regex_highlighting = {
          "clojure",
        },
      },
      textobjects = {
        select = {
          enable = true,
          lookahead = true,
          keymaps = {
            ["af"] = "@function.outer",
            ["if"] = "@function.inner",
          }
        }
      },
      rainbow = {
        enable = true,
      },
      playground = {
        enable = true,
      },
    },
  }
}
