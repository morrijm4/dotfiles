-- apps/web pulls ~13k files into one program (Next.js + source-included
-- @savvy/* packages); the default 3 GB tsserver heap aborts with SIGABRT
-- mid-diagnostics. Give it 8 GB.
vim.lsp.config('ts_ls', {
	init_options = {
		maxTsServerMemory = 8192,
	},
})
