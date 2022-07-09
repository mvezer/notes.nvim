local config = require('notes_nvim.config')
local notes = require('notes_nvim.notes')
local main = require('telescope._extensions.notes.main')
local M = {}

M.setup = config.setup
M.pull_notes = notes.pull_notes
M.new_note = notes.new_note
M.find_notes = main.find_notes

return M

