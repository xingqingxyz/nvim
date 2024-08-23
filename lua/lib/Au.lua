local Au = {}

---@type fun(events: string|string[], opts: vim.api.keyset.create_autocmd)
Au.add = vim.api.nvim_create_autocmd

Au.get = vim.api.nvim_get_autocmds
Au.del = vim.api.nvim_del_autocmd
---@type fun(events: string|string[], opts: vim.api.keyset.exec_autocmds)
Au.exec = vim.api.nvim_exec_autocmds
Au.clear = vim.api.nvim_clear_autocmds

return Au
