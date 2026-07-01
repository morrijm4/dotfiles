-- Hex editor: open binary files as an xxd hex dump, write them back as raw bytes.
--
-- Detection is content-based, not extension-based: on read we run `file` to
-- classify the on-disk bytes, and any file whose MIME encoding is `binary`
-- opens as a dump (offsets + hex columns + ASCII gutter). Text files are left
-- untouched.
--
-- How the round-trip works:
--   * BufReadPre  classifies the path with `file`; if binary, sets the buffer's
--     `binary` option (verbatim byte load) and an explicit `hex_editor` marker.
--   * BufReadPost pipes the buffer through `xxd` to produce the editable dump.
--   * BufWritePre pipes the dump back through `xxd -r` so the bytes — not the
--     literal dump text — are what gets written.
--   * BufWritePost re-runs `xxd` so the buffer keeps showing hex after saving.
-- The post/pre filters gate on the `hex_editor` marker (not `binary`), so they
-- stay inert for ordinary buffers even though they now match every file.

local group = vim.api.nvim_create_augroup('HexEditor', { clear = true })

-- True when `file` classifies the on-disk path as binary content. Empty files
-- report `binary` on macOS, so require a non-empty, existing file too.
local function is_binary(path)
    if path == '' or vim.fn.getfsize(path) <= 0 then
        return false
    end
    local out = vim.fn.system({ 'file', '--mime-encoding', '-b', '--', path })
    return vim.v.shell_error == 0 and vim.trim(out) == 'binary'
end

vim.api.nvim_create_autocmd('BufReadPre', {
    group = group,
    pattern = '*',
    callback = function(args)
        if is_binary(args.file) then
            vim.bo[args.buf].binary = true
            vim.b[args.buf].hex_editor = true
        end
    end,
})

vim.api.nvim_create_autocmd('BufReadPost', {
    group = group,
    pattern = '*',
    callback = function(args)
        if not vim.b[args.buf].hex_editor then
            return
        end
        vim.cmd('%!xxd')
        vim.bo.filetype = 'xxd'
        vim.bo.modified = false
    end,
})

vim.api.nvim_create_autocmd('BufWritePre', {
    group = group,
    pattern = '*',
    callback = function(args)
        if vim.b[args.buf].hex_editor then
            vim.cmd('%!xxd -r')
        end
    end,
})

vim.api.nvim_create_autocmd('BufWritePost', {
    group = group,
    pattern = '*',
    callback = function(args)
        if not vim.b[args.buf].hex_editor then
            return
        end
        vim.cmd('%!xxd')
        vim.bo.modified = false
    end,
})
