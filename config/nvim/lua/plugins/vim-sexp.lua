local M = {
  "guns/vim-sexp",
  dependencies = { "tpope/vim-repeat" },
}

M.config = function()
  vim.g.sexp_mappings = {
    sexp_raise_element = "<M-r>",
    sexp_splice_list = "<M-S-2>",
    sexp_convolute = "<M-S-/>",
    sexp_flow_to_prev_close = "",
    sexp_flow_to_next_open = "",
    sexp_flow_to_prev_open = "",
    sexp_flow_to_next_close = "",
    sexp_round_head_wrap_element = "<M-S-9>",
    sexp_round_tail_wrap_element = "<M-S-0>",
    sexp_square_head_wrap_element = "<M-[>",
    sexp_square_tail_wrap_element = "<M-]>",
    sexp_curly_head_wrap_element = "<M-S-[>",
    sexp_curly_tail_wrap_element = "<M-S-]>",
  }
end

return {
  M,
  {
    "tpope/vim-sexp-mappings-for-regular-people",
  },
}
