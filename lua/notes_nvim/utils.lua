local M = {}

local function exists (file)
   local ok, err, code = os.rename(file, file)
   if not ok then
      if code == 13 then
         return true
      end
   end
   return ok, err
end

local function is_dir (path)
   return exists(path.."/")
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

M.get_notes_dir = function ()
    local notes_dir = os.getenv('NOTES_DIR')
    if notes_dir == nil then
        notes_dir = '~/notes'
    end
    if not is_dir(notes_dir) then
        os.execute("mkdir " .. notes_dir)
        print('Notes directory "' .. notes_dir .. '" has been created')
    end

    return notes_dir
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
   if title == '' then
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

return M
