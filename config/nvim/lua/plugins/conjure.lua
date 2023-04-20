local M = { 
  "Olical/conjure",
  ft = { "clojure", "lua" },
  keys = {
  },
}

M.config = function()
  local eval = require("conjure.eval")
  local extract = require("conjure.extract")

  local function conjure_eval(form)
    return eval["eval-str"]({ code = form, origin = "custom_command" })
  end

  local function conjure_eval_fn(form)
    return function()
      return conjure_eval(form)
    end
  end

  local function conjure_word()
    return extract.word().content
  end

  local function conjure_form(is_root)
    return (extract.form({ ["root?"] = is_root })).content
  end

  local portal_cmds
  local function tap_word()
    local word = conjure_word()
    return conjure_eval(("(tap> " .. word .. ")"))
  end

  local function tap_form()
    local form = conjure_form(false)
    return conjure_eval(("(tap> " .. form .. ")"))
  end

  local function tap_root_form()
    local form = conjure_form(true)
    return conjure_eval(("(tap> " .. form .. ")"))
  end

  portal_cmds = {
    open = conjure_eval_fn([[
    (do (ns dev)
        ((requiring-resolve 'portal.api/close))
        (def portal ((requiring-resolve 'portal.api/open)
                     {:theme :portal.colors/nord}))
        (add-tap (requiring-resolve 'portal.api/submit)))
  ]]),
    clear = conjure_eval_fn("(portal.api/clear)"),
    last_exception = conjure_eval_fn("(tap> (Throwable->map *e))"),
    tap_word = tap_word,
    tap_form = tap_form,
    tap_root_form = tap_root_form,
  }

  daitaas_cmds = {
    start_system = conjure_eval_fn([[
    (user/start-system)
  ]]),
  }

  local wk = require("which-key")
  wk.register({
    p = {
      name = "portal",
      cond = vim.bo.filetype == "clojure",
      o = { portal_cmds.open, "Open Portal" },
      e = { portal_cmds.last_exception, "Tap last_exception" },
      w = { portal_cmds.tap_word, "Tap word" },
      f = { portal_cmds.tap_form, "Tap form" },
      r = { portal_cmds.tap_root_form, "Tap root form" },

    },
    r = {
      name = "REPL",
      cond = vim.bo.filetype == "clojure",
      c = { daitaas_cmds.start_system, "Start System"},
    },
  }, { prefix = "<localleader>" })

end

return M
