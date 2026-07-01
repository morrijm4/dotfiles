-- Remembers each Telescope picker's last prompt text for the current Neovim
-- session and re-seeds it as default_text when that picker is reopened.
-- In-memory only: state is held in a Lua table and resets when nvim exits.
--
-- Why re-seed the prompt instead of telescope's cache_picker/resume: resume
-- also restores the cached result list, so find_files would keep showing a
-- stale file list and miss files created later in the session.

local M = {}

local saved = {}

-- Wrap a telescope.builtin picker so its prompt text persists for the session.
function M.remember(name, picker)
    return function(opts)
        opts = opts or {}
        if saved[name] ~= nil and opts.default_text == nil then
            opts.default_text = saved[name]
        end

        local user_attach = opts.attach_mappings
        opts.attach_mappings = function(prompt_bufnr, map)
            vim.api.nvim_create_autocmd('BufLeave', {
                buffer = prompt_bufnr,
                once = true,
                callback = function()
                    local action_state = require('telescope.actions.state')
                    local ok, prompt = pcall(function()
                        return action_state.get_current_picker(prompt_bufnr):_get_prompt()
                    end)
                    if ok then
                        saved[name] = prompt
                    end
                end,
            })
            if user_attach then
                return user_attach(prompt_bufnr, map)
            end
            return true
        end

        return picker(opts)
    end
end

return M
