---@diagnostic disable: missing-return, duplicate-doc-field
---@meta

---@alias bool boolean

---@class vim.UserCmdParams
---@field name string
---@field args string
---@field fargs string[]
---@field bang boolean
---@field line1 integer
---@field line2 integer
---@field range 0|1|2
---@field count integer
---@field mods string
---@field smods table<string, boolean>

---@class vim.AutocmdParams
---@field id integer
---@field event string
---@field buf integer
---@field file string
---@field match string
---@field group? integer
---@field data? any

---@class vim.api.keyset.create_autocmd
---@field pattern? string|string[]
---@field group? integer|string
---@field callback? fun(e: vim.AutocmdParams): ...

---@class vim.api.keyset.user_command
---@field count? true|integer -> count 0, count n
---@field range? true|'%'|integer -> current line, current file, or line range .,.+n
---@field nargs? '?'|'*'|'+'|'0'
---@field addr? 'lines'|'arguments'|'buffers'|'loaded_buffers'|'windows'|'tabs'|'quickfix'|'other'|'arg'|'buf'|'load'|'win'|'tab'|'qf'|'?'
---@field preview? fun(opts: vim.UserCmdParams, ns_id: integer, bufnr: integer): 0|1|2 -> no preview, without preview window, preview window

---@class vim.api.keyset.open_term
---@field on_input?  fun(event: 'input', term: integer, bufnr: integer, data: string): ...
---@field force_crlf? boolean

---@class vim.fn.keyset.jobstart_opts
---@field on_stdout? fun(job:integer, data: string, event: string): ...
---@field on_stderr? fun(job: integer, err: string, event: string): ...
---@field on_exit? fun(job: integer, exit_code: integer, event: string): ...
---@field stdout_buffered? boolean
---@field stderr_buffered? boolean
---@field clear_env? boolean
---@field cwd? string
---@field env? table<string, string>
---@field detach? boolean
---@field pty? boolean
---@field width? integer term size
---@field height? integer term size
---@field overlapped? boolean
---@field rpc? boolean
---@field stdin? ('pipe'|'null')?

---@class lsp.CompletionItemDefaults
---@field commitCharacters? string[]
---@field editRange? lsp.Range|{insert: lsp.Range, replace: lsp.Range}
---@field insertTextFormat? lsp.InsertTextFormat
---@field insertTextMode? lsp.InsertTextMode
---@field data? lsp.LSPAny

---@class vim.ChanInfo
---@field id integer chan id
---@field mode 'rpc'|'bytes'|'terminal'|'socket' 'socket' is for |nvim_open_term|
---@field stream 'stdio'|'stderr'|'job'
---@field pty? string pty path
---@field argv? string[] job cmd
---@field buffer? integer terminal buffer
---@field client? { [true]: integer } rpc client
---@field internal? boolean flag for |nvim_open_term|

---@class vim.CompletionItem
---@field word string
---@field abbr? string
---@field menu? string
---@field info? string
---@field kind? 'f'|'v'|'m'|'t'|'d'
---@field icase? 0|1
---@field equal? 0|1
---@field dup? 0|1
---@field empty? 0|1
---@field userdata? any

---@return vim.ChanInfo[]
function vim.api.nvim_list_chans() end

---@param chan integer
---@return vim.ChanInfo
function vim.api.nvim_get_chan_info(chan) end

---@type userdata
vim.NIL = ...

---@class vim.regex
vim.regex = ...

vim.type_idx = true
vim.val_idx = false

---@enum vim.types
vim.types = {
  float = 3,
  array = 5,
  dictionary = 6,
}

---@type fun(s: string, sep: string, opts?: { plain?: boolean, trimempty?: boolean }): fun(): string?
vim.gsplit = ...

---@type fun(s: string, sep: string, opts?: { plain?: boolean, trimempty?: boolean }): string[]
vim.split = ...

---@type fun(name: string, command: string|fun(e: vim.UserCmdParams), opts: vim.api.keyset.user_command)
vim.api.nvim_create_user_command = ...

---@alias vim.fn.jobstart fun(cmd: string|string[], opts: vim.fn.keyset.jobstart_opts): -1|0|integer
---@type vim.fn.jobstart
vim.fn.jobstart = ...
---@type vim.fn.jobstart
vim.fn.termopen = ...
---@type fun(start: string, middle: string, end: string, flag?: string, stopline?: integer, timeout?: integer): integer[]
vim.fn.searchpairpos = ...

---@param str string
---@return integer?
---@return integer
function vim.regex:match_str(str) end

---@param bufnr integer
---@param line_idx integer
---@param start? integer
---@param end_? integer
---@return integer?
---@return integer
function vim.regex:match_line(bufnr, line_idx, start, end_) end

---@param it table|function
---@return Iter
function vim.iter(it) end
