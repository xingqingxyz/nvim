local M = {}

M.markup_languages = {
  'markdown',
  'html',
  'xml',
  'javascriptreact',
  'typescriptreact',
  'vue',
  'svelte',
  'angular',
  'mdx',
  'htmx',
  'typescript',
  'cpp',
  'java',
  'csharp',
}
M.pairs = {
  ["'"] = "'",
  ['"'] = '"',
  ['('] = ')',
  ['['] = ']',
  ['{'] = '}',
  __index = function(self, key)
    if key == '<' and vim.list_contains(M.markup_languages, vim.bo.ft) then
      return '>'
    end
    if key == '`' and vim.bo.ft ~= 'powershell' then
      return '`'
    end
  end,
}
setmetatable(M.pairs, M.pairs)

function M.on_InsertCharPre()
  local char = M.pairs[vim.v.char]
  if not char then
    return
  end
  vim.v.char = vim.v.char .. char
  vim.schedule(function()
    vim.cmd.norm(('%dh'):format(#char))
  end)
end

return M
