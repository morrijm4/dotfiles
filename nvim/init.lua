require('bootstrap')
require('rsync')
require('hex-editor')

------------
-- Options --
-------------
vim.opt.relativenumber = true

vim.o.number = true
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.expandtab = true
vim.o.softtabstop = 4
vim.o.winborder = 'rounded'
vim.o.signcolumn = 'yes'
vim.g.mapleader = ' '

-------------
-- Lazy --
-------------
vim.opt.rtp:prepend(vim.fn.stdpath('data') .. '/lazy/lazy.nvim')

---@type LazySpec
local lazy_spec = {
    { "catppuccin/nvim",      name = "catppuccin", priority = 1000 },
    { 'neovim/nvim-lspconfig' },
    { 'mason-org/mason.nvim', opts = {} },
    {
        'mason-org/mason-lspconfig.nvim',
        dependencies = { 'mason-org/mason.nvim', 'neovim/nvim-lspconfig' },
        opts = {
            ensure_installed = {
                'lua_ls',
                'ts_ls',
                'jsonls',
                'cssls',
                'html',
                'eslint',
                'tailwindcss',
                'tinymist',
                'clangd',
                'pyright',
                'ruff',
                'solidity_ls_nomicfoundation',
                'zls',
            },
        },
    },
    {
        'stevearc/conform.nvim',
        opts = {
            formatters_by_ft = {
                javascript = { 'prettier' },
                javascriptreact = { 'prettier' },
                typescript = { 'prettier' },
                typescriptreact = { 'prettier' },
                json = { 'prettier' },
                jsonc = { 'prettier' },
                css = { 'prettier' },
                scss = { 'prettier' },
                html = { 'prettier' },
                -- markdown = { 'prettier' }, yaml = { 'prettier' }, -- enable if you want notes reformatted too
            },
            format_on_save = function(bufnr)
                -- preserve the old clangd/solidity opt-out from the BufWritePre autocmd
                local skip = { cpp = true, solidity = true }
                if skip[vim.bo[bufnr].filetype] then
                    return nil
                end
                -- prettier where configured above; LSP (lua_ls, rust_analyzer, ruff, tinymist…) otherwise
                return { timeout_ms = 3000, lsp_format = 'fallback' }
            end,
        },
    },
    { 'nvim-telescope/telescope.nvim',   tag = '0.1.8',     dependencies = { 'nvim-lua/plenary.nvim' } },
    {
        'lewis6991/gitsigns.nvim',
        opts = {
            current_line_blame_opts = { delay = 0 },
        },
        config = function(_, opts)
            require('gitsigns').setup(opts)
            vim.keymap.set('n', 'gB', '<Cmd>Gitsigns toggle_current_line_blame<CR>',
                { desc = '[mm] Toggle inline git blame' })
            vim.keymap.set('n', 'gb', '<Cmd>Gitsigns blame_line<CR>',
                { desc = '[mm] Show full git blame for line' })
            vim.keymap.set('n', 'gp', '<Cmd>Gitsigns preview_hunk<CR>',
                { desc = '[mm] Preview git hunk' })
            vim.keymap.set('n', 'gP', function()
                local line = vim.fn.line('.')
                local file = vim.fn.expand('%:p')
                local cwd = vim.fn.fnamemodify(file, ':h')
                vim.system(
                    { 'git', 'blame', '-L', line .. ',' .. line, '--porcelain', '--', file },
                    { text = true, cwd = cwd },
                    function(blame_out)
                        local sha = (blame_out.stdout or ''):match('^(%S+)')
                        if not sha or sha:match('^0+$') then
                            vim.schedule(function() vim.notify('No commit for this line') end)
                            return
                        end
                        vim.system(
                            { 'gh', 'api', 'repos/{owner}/{repo}/commits/' .. sha .. '/pulls',
                                '--jq', '.[0].html_url' },
                            { text = true, cwd = cwd },
                            function(pr_out)
                                local url = (pr_out.stdout or ''):gsub('%s+$', '')
                                vim.schedule(function()
                                    if url ~= '' then
                                        vim.fn.jobstart({ 'open', url }, { detach = true })
                                    else
                                        vim.notify('No PR found for ' .. sha:sub(1, 7))
                                    end
                                end)
                            end)
                    end)
            end, { desc = '[mm] Open blame PR on GitHub' })
            vim.keymap.set('n', ']c', '<Cmd>Gitsigns next_hunk<CR>', { desc = '[mm] Next git hunk' })
            vim.keymap.set('n', '[c', '<Cmd>Gitsigns prev_hunk<CR>', { desc = '[mm] Previous git hunk' })
        end,
    },
    { 'nvim-treesitter/nvim-treesitter', branch = 'master', lazy = false,                              build = ':TSUpdate' },
    {
        'hrsh7th/nvim-cmp',
        dependencies = {
            'hrsh7th/cmp-nvim-lsp',
            'hrsh7th/cmp-buffer',
            'hrsh7th/cmp-path',
            'hrsh7th/cmp-cmdline',
        }
    },
    {
        'chomosuke/typst-preview.nvim',
        ft = 'typst',
        version = '1.*',
        opts = {},
        config = function()
            vim.g.jupynium_auto_download_ipynb = false
            vim.keymap.set("n", "<leader>T", ":TypstPreview<CR>", { desc = "[mm] Open Typst preview" })
        end

    },
    -- {
    --     "kiyoon/jupynium.nvim",
    --     -- build = "pip3 install --user .",
    --     -- build = "uv pip install . --python=$HOME/.virtualenvs/jupynium/bin/python",
    --     build = "conda run --no-capture-output -n aml pip install .",
    --     opts = {
    --         default_notebook_URL = "localhost:8889/nbclassic",
    --         python_host = { "conda", "run", "--no-capture-output", "-n", "aml", "python" },
    --         jupyter_command = { "conda", "run", "--no-capture-output", "-n", "aml", "jupyter" }
    --     },
    --     config = function()
    --         vim.g.jupynium_auto_download_ipynb = false
    --         vim.keymap.set("n", "<leader>J", ":Jupynium", { desc = "[mm] Jupynium prefix" })
    --     end
    -- },
}

---@type LazyConfig
local lazy_opts = {
    spec = lazy_spec,
    rocks = {
        enabled = false,
    },
}
require('lazy').setup(lazy_opts)

------------------
-- Color scheme --
------------------
vim.o.background = 'dark' -- or 'light' for light mode
vim.cmd.colorscheme 'catppuccin-macchiato'

--------------
-- Snippets --
--------------
local snippet_path = vim.fs.joinpath(vim.fn.stdpath("config"), "snippets/")
vim.keymap.set('n', '<Leader>k', ':r ' .. snippet_path, { desc = '[mm] Load a snippet' })
vim.keymap.set('v', '<Leader>k', ':w ' .. snippet_path, { desc = '[mm] Create a snippet' })
vim.keymap.set('n', '<Leader><C-k>', ':e ' .. snippet_path, { desc = '[mm] Edit a snippet' })
vim.keymap.set('n', '<Leader>K', ':!ls ' .. snippet_path .. "<CR>", { desc = '[mm] List snippets' })
vim.keymap.set('n', '<Leader>d', ':!rm ' .. snippet_path, { desc = '[mm] Delete a snippet' })


-----------
-- Misc. --
-----------
vim.keymap.set('n', '<Leader>|', ':nohls<CR>', { desc = '[mm] Clear highlight after search' })
vim.keymap.set('n', '<Leader>e', ':Explore<CR>', { desc = '[mm] Open file explorer' })
vim.keymap.set('v', '<Leader>y', '"+y', { desc = '[mm] Yank to clipboard' })
vim.keymap.set('n', '<Leader>l', ':Lazy<CR>', { desc = '[mm] Open lazy.nvim' })
vim.keymap.set('n', '<Leader>h', ':vert rightb help ', { desc = '[mm] Open help vertically' })

-------------
-- Windows --
-------------
vim.keymap.set('n', '<Leader><', '<C-w><', { desc = '[mm] Decrease vertical window size' })
vim.keymap.set('n', '<Leader>>', '<C-w>>', { desc = '[mm] Increase vertical window size' })

--------------
-- Terminal --
--------------
vim.keymap.set('n', '<Leader>t', ':vert rightb terminal<CR>', { desc = '[mm] Open terminal' })
vim.cmd([[tnoremap <Esc> <C-\><C-n>]]) -- map Esc to exit "TERMINAL" mode

---------------
-- Telescope --
---------------
require('telescope-deps').check()

local telescope = require('telescope.builtin')
local remember = require('telescope-session').remember

-- Each picker remembers its last prompt text for the session (see telescope-session.lua).
local telescope_save = {
    grep_string = remember('grep_string', telescope.grep_string),
    live_grep = remember('live_grep', telescope.live_grep),
}

vim.keymap.set('n', '<Leader>p', telescope.find_files, { desc = '[mm] File finder' })
vim.keymap.set('n', 'gs', telescope.git_status, { desc = '[mm] Git status' })
vim.keymap.set('n', '<C-Space>', vim.lsp.buf.code_action, { desc = '[mm] Find code action' })
vim.keymap.set('n', '<Leader>fb', telescope.buffers, { desc = '[mm] Search current buffer' })
vim.keymap.set('n', '<Leader>fh', telescope.help_tags, { desc = '[mm] Search help tags' })
vim.keymap.set('n', '<Leader>fk', telescope.keymaps, { desc = '[mm] Find keymap' })
vim.keymap.set({ 'n', 'v' }, '<Leader>fs', telescope_save.grep_string,
    { desc = '[mm] Grep string under cursor or highlighted' })
vim.keymap.set({ 'n', 'v' }, '<Leader>fw', telescope_save.live_grep, { desc = '[mm] Live grep' })
vim.keymap.set({ 'n', 'v' }, '<Leader>ss', telescope.spell_suggest, { desc = '[mm] Spell suggest' })

--------------
-- Quickfix --
--------------
vim.keymap.set('n', '<C-n>', '<Cmd>cnext<CR>', { desc = '[mm] Next quickfix item' })
vim.keymap.set('n', '<C-p>', '<Cmd>cprevious<CR>', { desc = '[mm] Previous quickfix item' })
vim.keymap.set('n', '<Leader>q', function()
    local qf_open = vim.iter(vim.fn.getwininfo()):any(function(win) return win.quickfix == 1 end)
    vim.cmd(qf_open and 'cclose' or 'copen')
end, { desc = '[mm] Toggle quickfix window' })

-------------------
-- Auto Complete --
-------------------

local cmp = require('cmp')

cmp.setup({
    sources = cmp.config.sources({
        { name = "jupynium", priority = 1000 },
        { name = 'nvim_lsp', priority = 100 },
    }),
    sorting = {
        priority_weight = 1.0,
        comparators = {
            cmp.config.compare.score, -- Jupyter kernel completion shows prior to LSP
            cmp.config.compare.recently_used,
            cmp.config.compare.locality,
        },
    },
    mapping = cmp.mapping.preset.insert({
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<CR>'] = cmp.mapping.confirm({ select = true }),
    }),
})

cmp.setup.cmdline(':', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({ { name = 'path' }, { name = 'cmdline' } }),
})

cmp.setup.cmdline({ '/', '?' }, {
    mapping = cmp.mapping.preset.cmdline(),
    sources = { { name = 'buffer' } },
})

----------------------
-- Language servers --
----------------------
local function go_to_definitions()
    vim.cmd('fc!') -- close all floating windows
    telescope.lsp_definitions()
end

vim.keymap.set('n', 'gd', go_to_definitions, { desc = '[mm] Go to definition' })
vim.keymap.set('n', 'gi', telescope.lsp_implementations, { desc = '[mm] Go to implementations' })
vim.keymap.set('n', 'grr', telescope.lsp_references, { desc = '[mm] Go to references' })
vim.keymap.set('n', 'gl', vim.diagnostic.open_float, { desc = '[mm] Show diagnositc' })
vim.keymap.set('n', 'gh', vim.lsp.buf.hover, { desc = '[mm] Hover' })
vim.keymap.set('n', 'ff', function()
    require('conform').format({ lsp_format = 'fallback' })
end, { desc = '[mm] Format file' })
vim.keymap.set('n', '<Leader>r', vim.lsp.buf.rename, { desc = '[mm] Rename' })

-- ts_ls ships its own formatter that ignores Prettier; force it off so
-- format-on-save can only go through conform (prettier) for TS/JS.
vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('DisableTsLsFormatting', {}),
    callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if client and client.name == 'ts_ls' then
            client.server_capabilities.documentFormattingProvider = false
            client.server_capabilities.documentRangeFormattingProvider = false
        end
    end,
})

vim.o.completeopt = 'menu,menuone,noselect,popup' -- Disable autocomplete & new popup
vim.diagnostic.config({
    signs = false,
})

vim.lsp.config('*', {
    capabilities = require('cmp_nvim_lsp').default_capabilities(),
})

require('lsp-config.lua_ls')
require('lsp-config.zls')

vim.lsp.config('clangd', {
    cmd = {
        "clangd",
        "--query-driver=/Users/matthew/.espressif/tools/**",
    },
})

vim.lsp.enable({
    'lua_ls',
    'rust_analyzer', -- installed via rustup, not mason
    'ts_ls',
    'jsonls',
    'cssls',
    'html',
    'eslint',
    'tailwindcss',
    'tinymist',
    'clangd',
    'pyright',
    'ruff',
    'solidity_ls_nomicfoundation',
    'ruby_ls',
    'zls',
    'bashls',
})
