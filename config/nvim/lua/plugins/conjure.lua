local M = {
  "Olical/conjure",
  ft = { "clojure", "lua" },
  keys = {},
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

  vim.g["conjure#client#clojure#nrepl#mapping#refresh_all"] = false
  vim.g["conjure#client#clojure#nrepl#mapping#refresh_changed"] = false

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
    start_client = conjure_eval_fn([[
    (user/start-client)
  ]]),
    restart_system = conjure_eval_fn([[
    (user/restart-system)
    ]]),
    restart_all_system = conjure_eval_fn([[
    (user/restart-all-system)
    ]]),
  }

  local wk = require("which-key")
  wk.register({
    p = {
      name = "portal",
      cond = vim.bo.filetype == "clojure",
      o = { portal_cmds.open, "Open Portal" },
      x = { portal_cmds.last_exception, "Tap last_exception" },
      w = { portal_cmds.tap_word, "Tap word" },
      e = { portal_cmds.tap_form, "Tap form" },
      f = { portal_cmds.tap_form, "Tap form" },
      r = { portal_cmds.tap_root_form, "Tap root form" },
    },
    r = {
      name = "REPL",
      cond = vim.bo.filetype == "clojure",
      s = { daitaas_cmds.start_system, "Start System" },
      S = { daitaas_cmds.start_client, "Start Client" },
      r = { daitaas_cmds.restart_system, "Restart System" },
      R = { daitaas_cmds.restart_all_system, "Restart All System" },
    },
  }, { prefix = "<localleader>" })
end

return M
