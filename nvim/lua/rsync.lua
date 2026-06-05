local toggle_enabled = false
local group = vim.api.nvim_create_augroup("RsyncAutoCmd", { clear = true })

local function toggle()
    if toggle_enabled then
        -- turn off
        toggle_enabled = false
        vim.api.nvim_clear_autocmds({ group = group })
        print("rsync hook OFF")
    else
        -- turn on
        toggle_enabled = true

        vim.api.nvim_create_autocmd("BufWritePost", {
            group = group,
            pattern = "*",
            callback = function()
                vim.fn.jobstart(
                    "rsync -av --filter=':- .gitignore' . ping:/home/jmm845/intrin-dataset/src",
                    { detach = true })
            end,
        })

        print("rsync hook ON")
    end
end

vim.api.nvim_create_user_command("RsyncSaveHook", toggle, {})
