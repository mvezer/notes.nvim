local config = require('notes_nvim.config')
local notes = require('notes_nvim.notes')
local utils = require('notes_nvim.utils')
local main = require('telescope._extensions.notes.main')

local M = {}

M.sync_notes = notes.sync_notes
M.new_note = notes.new_note
M.find_notes = main.find_notes

M.setup = function(options)
  config.setup(options)
  -- register commands
  vim.api.nvim_create_user_command('Note', notes.new_note, { nargs = "?" })
  vim.api.nvim_create_user_command('NotesSync', notes.sync_notes, { nargs = "?" })
  vim.api.nvim_create_user_command('NotesFind', main.find_notes, { nargs = "?" })

  -- register autocmds
  vim.api.nvim_create_autocmd({ 'BufReadPre' }, {
    pattern = { config.settings.notes_dir .. '/**' },
    callback = notes.on_before_open
  })
  vim.api.nvim_create_autocmd({ 'BufWritePost' }, {
    pattern = { config.settings.notes_dir .. '/**' },
    callback = notes.on_after_save
  })
  vim.api.nvim_create_autocmd({ 'BufWritePre' }, {
    pattern = { config.settings.notes_dir .. '/**' },
    callback = notes.on_before_save
  })

  -- create the notebooks dirs if they're not existing yet
  for _, notebook in pairs(config.settings.notebooks) do
    if not utils.dir_exists(notebook.dir) then
      utils.create_dir(notebook.dir)
    end
  end

  notes.sync_notes("all")
end

return M

