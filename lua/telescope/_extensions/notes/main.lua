local make_entry = require("telescope.make_entry")
local finders = require("telescope.finders")
local pickers = require("telescope.pickers")
local previewers = require("telescope.previewers")
local config = require("notes_nvim.config")

local M = {}

M.find_notes = function(notebook)
  local dir = config.settings.notes_dir
  local opts = {}
  if notebook ~= nil and notebook ~= "all" and config.settings.notebooks[notebook] ~= nil then
    dir = config.settings.notebooks[notebook].dir
  end
  local ag_bin = { "ag" }
  local args = { "-li" }
  local md_previewer = previewers.new_termopen_previewer({
    get_command = function(entry)
      return "glow " .. entry[1] .. " -p"
    end
  })
  local ag_grepper = finders.new_job(function(prompt)
    if not prompt or prompt == "" then
      return nil
    end

    return vim.tbl_flatten { ag_bin, args, "--", prompt, dir }
  end, opts.entry_maker )

  pickers.new(opts, {
    prompt_title = "Find Notes",
    finder = ag_grepper,
    previewer = md_previewer,
    entry_maker = opts.entry_maker or make_entry.gen_from_file(opts)
  }):find()
end

return M
