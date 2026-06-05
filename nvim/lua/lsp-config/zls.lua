local vim = vim
local zls_path = '/Users/matthew/projects/zls/zls-x86_64-macos-0.16.0/zls'

-- Check if zls is installed
local zls_exe_file = io.open(zls_path, "r")
if zls_exe_file == nil then
    return
else
    io.close(zls_exe_file)
end

vim.lsp.config('zls', {
    cmd = { zls_path },
    filetypes = { 'zig' },
    root_markers = { 'build.zig' },
    settings = {
        zls = {
            zls_exe_path = { zls_path },
        }
    }
})

vim.lsp.enable('zls')
