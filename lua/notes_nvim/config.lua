local utils = require('notes_nvim.utils')

-- TODO: filter out these reserved notebook names
--local reserved_notebook_names = { "all", "default" }

local M = {
  settings = {
    notes_dir = os.getenv("NOTES_DIR") or os.getenv("HOME") .. "/Documents",
    notebooks = {
      default = {
        is_default = true
      }
    },
    default_notebook = "default"
  }
}

M.setup = function(options)
  M.settings = vim.tbl_deep_extend("force", M.settings, options or {})
  if vim.tbl_count(M.settings.notebooks) > 1 then
    M.settings.notebooks.default = nil
  end

  local default_notebook = nil
  local first_key = nil
  for notebook, _ in pairs(M.settings.notebooks) do
    M.settings.notebooks[notebook].dir = utils.path_join(M.settings.notes_dir, notebook)
    if M.settings.notebooks[notebook].is_default ~= nil then
      default_notebook = notebook
      M.settings.default_notebook = default_notebook
    end
    if first_key == nil then
      first_key = notebook
    end
  end

  if default_notebook == nil then
    M.settings.notebooks[first_key] = vim.tbl_deep_extend("force", M.settings.notebooks[first_key], { is_default = true })
    M.settings.default_notebook = first_key
  end
end

return M

