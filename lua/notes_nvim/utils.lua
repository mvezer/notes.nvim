local Job = require "plenary.job"
local M = {}

M.path_separator = "/"
M.is_windows = vim.fn.has("win32") == 1 or vim.fn.has("win32unix") == 1
if M.is_windows == true then
  M.path_separator = "\\"
end

M.file_exists = function (file)
   local ok, err, code = os.rename(file, file)
   if not ok then
      if code == 13 then
         return true
      end
   end
   return ok, err
end

M.dir_exists = function (path)
   return M.file_exists(path.."/")
end

M.create_dir = function (path)
  os.execute("mkdir -p " .. path)
end

-- Find the first executable in binaries that can be found in the PATH
local function find_binary(binaries)
    for _, binary in ipairs(binaries) do
        if type(binary) == "string" and vim.fn.executable(binary) == 1 then
            return binary
        elseif type(binary) == "table" and vim.fn.executable(binary[1]) == 1 then
            return vim.deepcopy(binary)
        end
    end
    return ""
end

M.get_current_date = function ()
   return os.date("%Y-%m-%dT%H:%M:%S%z")
end

M.get_note_file_name = function (title)
   local fname
   -- trim title
   title = string.gsub(title, "^%s*(.-)%s*$", "%1")
   -- replace spaces with underscore
   title = string.gsub(title, "%s+", "_")
   if title == "" then
      -- if the title is empty, we use the current date
      fname = os.date("%Y-%m-%d-%H-%M-%S")
   else
      fname = title
   end

   -- add markdown extendsion
   return fname .. ".md"
end

-- Find under what name ag is installed.
M.find_ag_binary = function()
    return find_binary({ "ag" })
end

M.path_join = function(...)
  local args = {...}
  if #args == 0 then
    return ""
  end

  local all_parts = {}
  if type(args[1]) =="string" and args[1]:sub(1, 1) == M.path_separator then
    all_parts[1] = ""
  end

  for _, arg in ipairs(args) do
    local arg_parts = M.split(arg, M.path_separator)
    vim.list_extend(all_parts, arg_parts)
  end
  return table.concat(all_parts, M.path_separator)
end

M.split = function(inputString, sep)
  local fields = {}

  local pattern = string.format("([^%s]+)", sep)
  local _ = string.gsub(inputString, pattern, function(c)
    fields[#fields + 1] = c
  end)

  return fields
end

M.str_is_empty = function(str)
  return str == nil or str == ""
end

M.exec_async = function(command, args)
  Job:new {
    command = command,
    args =  args or {},
    on_exit = function(_, exit_code)
      if exit_code ~= 0 then
        error("Could not sync note")
      else
        print("Note(s) sync complete")
      end
    end,
  }:start(30000)
end

M.get_notebook_name_from_file_path = function (file_path)
  local file_name_tbl = M.split(file_path, "/")
  return file_name_tbl[#file_name_tbl-1]
end

M.basename = function(file_path)
  local file_name_tbl = M.split(file_path, "/")
  return file_name_tbl[#file_name_tbl]
end

return M
