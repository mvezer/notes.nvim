local notes = require('notes_nvim.notes')
local utils = require('notes_nvim.utils')
local main = require('telescope._extensions.notes.main')

local M = {}

M.setup = function(options)
   -- register commands
   vim.api.nvim_create_user_command('Note', notes.new_note, { nargs = 0 })
   vim.api.nvim_create_user_command('NotesPull', notes.pull_notes, { nargs = 0 })
   vim.api.nvim_create_user_command('NotesFind', main.find_notes, { nargs = 0 })

   -- register autocmds
   vim.api.nvim_create_autocmd({ 'BufWritePost' }, {
      pattern = { utils.get_notes_dir() .. '/**' },
      callback = notes.on_note_saved
   })
   vim.api.nvim_create_autocmd({ 'BufWritePre' }, {
      pattern = { utils.get_notes_dir() .. '/**' },
      callback = notes.before_note_saved
   })
end

return M

