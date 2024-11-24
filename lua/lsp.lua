local lsp = vim.lsp
local buf = lsp.buf

---@type vim.lsp.ClientConfig
local info = {
  name = 'lua-language-server',
  offset_encoding = 'utf-8',
  workspace_folders = { { name = '', uri = vim.uri_from_fname(vim.uv.cwd()) } },
  cmd_cwd = [[C:\Users\cmema\.vscode\extensions\sumneko.lua-3.13.1-win32-x64\server\bin\]],
  cmd = {
    [[C:\Users\cmema\.vscode\extensions\sumneko.lua-3.13.1-win32-x64\server\bin\lua-language-server.exe]],
    '--locale=zh-cn',
  },
}

vim.api.nvim_create_autocmd('VimEnter', {
  callback = function(e)
    local client_id = lsp.start(info)
    lsp.completion.enable(true, client_id, e.buf, { autotrigger = true })
  end,
})

lsp.inlay_hint.enable(true)
