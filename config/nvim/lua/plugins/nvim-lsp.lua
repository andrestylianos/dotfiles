return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        jsonls = {
          mason = false,
        },
        lua_ls = {
          mason = false,
        },
        nil_ls = {
          mason = false,
        },
        clojure_lsp = {
          mason = false,
        },
      },
    },
  }
}
