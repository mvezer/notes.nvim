local main = require("telescope._extensions.notes.main")

local fallback_error = { "Falling back to `:Telescope repo list`, but this behavior may change in the future" }

return require("telescope").register_extension({
    exports = {
        list = main.list,
        cached_list = main.cached_list,
        -- Default command, for now, may change
        notes = function(opts)
            vim.api.nvim_echo({ fallback_error }, true, {})
            main.list(opts)
        end,
    },
})
