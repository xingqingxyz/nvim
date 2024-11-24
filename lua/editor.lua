local go, map = vim.go, vim.keymap.set
local edit = require 'lib.edit'

_G.Api, _G.Buf, _G.Win, _G.Tab = require 'lib.Api', require 'lib.Buf', require 'lib.Win', require 'lib.Tab'

---@type table<string, integer>
_G.augmap = vim.iter({ 'editor', 'lib/logger' }):fold({}, function(obj, name)
  obj[name] = vim.api.nvim_create_augroup(name, {})
  return obj
end)
_G.Au = require 'lib.Au'
-- _G.logger = require 'lib.logger'.setup()

require('surround').setup()
require('terminal').setup()

-- #region go
go.splitright = true
go.splitbelow = true
go.cursorline = true
go.scrolloff = 5
go.updatetime = 100
go.pumheight = 12
go.tabclose = 'uselast'
go.completeopt = 'menuone,popup'
go.wildmode = 'longest,full'
go.wildoptions = 'pum,tagfile'
go.dictionary = '/usr/share/dict/words,~/.words'
go.thesaurus = '~/.thesaurus'
go.fileencodings = 'fileencodings=ucs-bom,utf-8,euc-cn,euc-tw,default,latin1'
vim.opt.listchars:prepend 'precedes:<,extends:>,tab:>-,lead:.,trail:.,nbsp:%'
-- #endregion

map({ 'n', 'v', 'i' }, '<M-j>', edit.move_lines_down, { desc = 'move lines down' })
map({ 'n', 'v', 'i' }, '<M-Down>', edit.move_lines_down, { desc = 'move lines down' })
map({ 'n', 'v', 'i' }, '<M-k>', edit.move_lines_up, { desc = 'move lines up' })
map({ 'n', 'v', 'i' }, '<M-Up>', edit.move_lines_up, { desc = 'move lines up' })
map({ 'n', 'v', 'i' }, '<M-J>', edit.dup_lines_down, { desc = 'duplicate lines down' })
map({ 'n', 'v', 'i' }, '<M-S-Down>', edit.dup_lines_down, { desc = 'duplicate lines down' })
map({ 'n', 'v', 'i' }, '<M-K>', edit.dup_lines_up, { desc = 'duplicate lines up' })
map({ 'n', 'v', 'i' }, '<M-S-Up>', edit.dup_lines_up, { desc = 'duplicate lines up' })
map('i', '<C-S-K>', vim.api.nvim_del_current_line, { desc = 'delete current line' })

Au.add('FileType', {
  callback = function(e)
    local bo = vim.bo[e.buf]
    local ft = bo.filetype
    if
        vim.list_contains({
          'javascript',
          'typescript',
          'javascriptreact',
          'typescriptreact',
          'vue',
          'svelte',
          'mdx',
        }, ft)
    then
      bo.iskeyword = '@,48-57,_,-,$'
    elseif vim.list_contains({ 'sh', 'html', 'xml' }, ft) then
      bo.iskeyword = '@,48-57,_,-'
    elseif vim.list_contains({ 'c', 'cpp', 'm' }, ft) then
      bo.iskeyword = 'a-z,A-Z,48-57,_,.,-,>'
    else
      -- removes unprintable characters 192-255
      bo.iskeyword = '@,48-57,_'
    end
    bo.expandtab = not vim.list_contains({ 'go' }, ft)
    if vim.list_contains({ 'rust', 'go', 'python', 'mojo', 'java', 'csharp' }, ft) then
      bo.shiftwidth = 4
      bo.softtabstop = 4
    else
      bo.shiftwidth = 2
      bo.softtabstop = 2
    end
  end,
  group = 'editor',
  desc = 'Set FileType options',
})

Au.add('BufWinEnter', {
  callback = function()
    local wo = vim.wo
    if not vim.list_contains({ 'help', 'markdown' }, vim.bo.ft) then
      wo.number = true
      wo.relativenumber = true
      wo.signcolumn = 'number'
    end
    wo.cursorline = true
    wo.foldmethod = 'expr'
    wo.foldlevel = 100
    wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
    wo.foldtext = 'v:lua.vim.treesitter.foldtext()'
  end,
  group = 'editor',
  desc = 'Set BufWinEnter options',
})

Au.add('InsertCharPre', {
  callback = require('pairs').on_InsertCharPre,
  desc = 'auto pairs',
  group = 'editor',
})
