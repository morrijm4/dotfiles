-- Telescope's find_files picks the first available of: fd, fdfind, rg, find.
-- Plain `find` ignores .gitignore, so node_modules etc. leak into the picker.
-- Warn at startup if neither fd nor rg is on PATH.

local M = {}

function M.check()
    local missing = {}
    if vim.fn.executable('fd') == 0 and vim.fn.executable('fdfind') == 0 then
        table.insert(missing, 'fd')
    end
    if vim.fn.executable('rg') == 0 then
        table.insert(missing, 'rg')
    end
    if #missing == 0 then
        return
    end

    local brew_pkgs = {}
    for _, tool in ipairs(missing) do
        table.insert(brew_pkgs, tool == 'rg' and 'ripgrep' or tool)
    end

    vim.schedule(function()
        vim.notify(
            ('Telescope: %s not found on PATH — find_files will fall back to `find` and ignore .gitignore. Install with: brew install %s')
                :format(table.concat(missing, ' and '), table.concat(brew_pkgs, ' ')),
            vim.log.levels.WARN
        )
    end)
end

return M
