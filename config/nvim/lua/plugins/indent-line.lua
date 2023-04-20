return {
  {
    "echasnovski/mini.indentscope",
    enabled = false,
  },
  {
    "lukas-reineke/indent-blankline.nvim",
    opts = {
      char = "▎",
      context_char = "▎",
      space_char_blankline = "▎",
      show_current_context = true,
      show_current_context_start = true,
      context_patterns = { "lit$" },
      use_treesitter = true,
      use_treesitter_scope = true,
    }
  }
}
