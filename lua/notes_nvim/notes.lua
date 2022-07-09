local utils = require('notes_nvim.utils')

local M = {}

M.before_note_saved = function (args)
   local buf = args['buf']
   vim.api.nvim_buf_set_lines(buf, 2, 3, true, {
      'modified: ' .. utils.get_current_date(),
   })
end

M.on_note_saved = function (args)
   local current_dir = vim.api.nvim_exec('pwd', false)
   vim.api.nvim_exec('cd ' .. utils.get_notes_dir(), false)
   vim.api.nvim_exec('!git add ' .. args['file'], true)
   vim.api.nvim_exec('!git commit -m \'Updated Note ' .. args['file'] .. '\'', true)
   vim.api.nvim_exec('!git push', true)
   vim.api.nvim_exec('cd ' .. current_dir, false)
end

M.pull_notes = function ()
   local current_dir = vim.api.nvim_exec('pwd', false)
   vim.api.nvim_exec('cd ' .. utils.get_notes_dir(), false)
   vim.api.nvim_exec('!git pull', true)
   vim.api.nvim_exec('cd ' .. current_dir, false)
end

M.new_note = function ()
   local path = utils.get_notes_dir()
   local title = vim.fn.input('Note title: ', '')
   local fname = utils.get_note_file_name(title)
   vim.cmd('e' .. path .. '/' .. fname)
   local buf = vim.api.nvim_get_current_buf()

   -- if the buffer is new we add a header
   if vim.api.nvim_buf_line_count(buf) == 1 then
      vim.api.nvim_buf_set_lines(buf, 0, 0, false, {
         '---',
         'created: ' .. utils.get_current_date(),
         'modified: ' .. utils.get_current_date(),
         'tags: []',
         '---',
      })
   end
end

return M
