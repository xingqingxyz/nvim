-- skipped builtins
local disabled_plugins = {
  'netrwPlugin',
  'gzip',
  'zipPlugin',
  'tarPlugin',
  '2html_plugin',
  'matchit',
}

for _, plugin in ipairs(disabled_plugins) do
  vim.g['loaded_' .. plugin] = 1
end

-- set globals for debugging
for _, name in ipairs { 'api', 'lsp', 'lpeg', 'fn', 'print' } do
  _G[name] = vim[name]
end
_G.ts = vim.treesitter
_G.tsq = ts.query

vim.opt.rtp:append(vim.fs.dirname(vim.uv.fs_realpath(debug.getinfo(1,'S').short_src)))
require 'editor'
