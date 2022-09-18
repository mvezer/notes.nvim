local utils = require("notes_nvim.utils")
local config = require("notes_nvim.config")

local M = {}

M.on_before_save = function (args)
   local buf = args['buf']
   vim.api.nvim_buf_set_lines(buf, 2, 3, true, {
      'modified: ' .. utils.get_current_date(),
   })
end

M.on_before_open = function(args)
  -- TODO: add per-file down sync. 
end

M.on_after_save = function (args)
  local filename = args["file"]
  local basename = utils.basename(filename)
  local notebook = utils.get_notebook_name_from_file_path(filename)
  if config.settings.notebooks[notebook] ~= nil and config.settings.notebooks[notebook].remote ~= nil then
    utils.exec_async("rclone", {
      "copyto",
      filename,
      utils.path_join(config.settings.notebooks[notebook].remote, basename),
      "-q"
    })
  end
end

M.sync_notes_down = function (notebook)
  if notebook == nil then notebook = "all" end
  for nb_name, nb in pairs(config.settings.notebooks) do
    if (notebook == "all" or nb_name == notebook) and nb.remote ~= nil then
      utils.exec_async("rclone", {
        "sync",
        nb.remote,
        nb.dir,
        "-q"
      })
    end
  end
end

M.sync_notes_up = function (notebook)
  if notebook == nil then notebook = "all" end
  for nb_name, nb in pairs(config.settings.notebooks) do
    if (notebook == "all" or nb_name == notebook) and nb.remote ~= nil then
      utils.exec_async("rclone", {
        "sync",
        nb.dir,
        nb.remote,
        "-q"
      })
    end
  end
end

M.new_note = function (args)
  local notebook = args.args
  if utils.str_is_empty(notebook) then notebook = config.settings.default_notebook end
  local title = vim.fn.input('Note title: ', '')
  local fname = utils.get_note_file_name(title)
  vim.cmd('e ' .. utils.path_join(config.settings.notebooks[notebook].dir, fname))
  local buf = vim.api.nvim_get_current_buf()

  -- if the buffer is new we add a header
  if vim.api.nvim_buf_line_count(buf) == 1 then
      vim.api.nvim_buf_set_lines(buf, 0, 0, false, {
        '---',
        'created: ' .. utils.get_current_date(),
        'modified: ' .. utils.get_current_date(),
        'tags: []',
        '---',
        '#' .. title
      })
  end
end

return M
