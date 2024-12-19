local api = vim.api
local empty_opts = vim.empty_dict()

---@class Follower
local Follower = {}
Follower.__index = Follower
Follower.ns = api.nvim_create_namespace 'lib/Follower'

function Follower.new()
  ---@class Follower
  return setmetatable({}, Follower)
end

function Follower:store()
  local cursor = api.nvim_win_get_cursor(0)
  self.ext_id = api.nvim_buf_set_extmark(0, Follower.ns, cursor[1], cursor[2], empty_opts)
end

function Follower:restore()
  local cursor = api.nvim_buf_get_extmark_by_id(0, Follower.ns, self.ext_id, empty_opts)
  cursor[1] = cursor[1] + 1
  api.nvim_win_set_cursor(0, cursor)
end

--[[all active apis:
nvim_buf_line_count
nvim_buf_attach
nvim_buf_detach
nvim_buf_get_lines
nvim_buf_set_lines
nvim_buf_set_text
nvim_buf_get_text
nvim_buf_get_offset
nvim_buf_get_var
nvim_buf_get_changedtick
nvim_buf_get_keymap
nvim_buf_set_keymap
nvim_buf_del_keymap
nvim_buf_set_var
nvim_buf_del_var
nvim_buf_get_name
nvim_buf_set_name
nvim_buf_is_loaded
nvim_buf_delete
nvim_buf_is_valid
nvim_buf_del_mark
nvim_buf_set_mark
nvim_buf_get_mark
nvim_buf_call
nvim_buf_create_user_command
nvim_buf_del_user_command
nvim_buf_get_commands
nvim_buf_get_extmark_by_id
nvim_buf_get_extmarks
nvim_buf_set_extmark
nvim_buf_del_extmark
nvim_buf_add_highlight
nvim_buf_clear_namespace
]]
---@class Buf
local Buf = {}
Buf.__index = Buf
Buf.Follower = Follower
Buf.buf = 0

function Buf.new(bufnr)
  bufnr = bufnr or api.nvim_get_current_buf()
  ---@class Buf
  return setmetatable({ buf = bufnr }, Buf)
end

---@param line string|vim.NIL|nil
function Buf.current_line(line)
  if line == nil then
    return api.nvim_get_current_line()
  elseif line == vim.NIL then
    api.nvim_del_current_line()
  else
    api.nvim_set_current_line(line)
  end
end

function Buf.split_lines(text)
  if type(text) == 'table' then
    return text
  end
  return vim.split(text, '\r?\n', text)
end

function Buf.Position(row, col)
  ---@type lsp.Position
  return {
    line = row,
    character = col,
  }
end

---@overload fun(s: lsp.Position, e: lsp.Position): lsp.Range
---@overload fun(s_row: integer, s_col: integer, e_row: integer, e_col: integer): lsp.Range
function Buf.Range(...)
  local args = { ... }
  if #args == 2 then
    return {
      start = args[1],
      ['end'] = args[2],
    }
  end
  return {
    {
      start = {
        line = args[1],
        character = args[2],
      },
      ['end'] = {
        line = args[3],
        character = args[4],
      },
    },
  }
end

---@param position lsp.Position
function Buf:_resolve_position(position, offset_encoding)
  if (offset_encoding or 'utf-8') ~= 'utf-8' then
    position.character = vim.str_byteindex(self:line(position.line), position.character, offset_encoding == 'utf-16')
      - 1
  end
end

---@param range lsp.Range
---@param offset_encoding? string
function Buf:_resolve_range(range, offset_encoding)
  if (offset_encoding or 'utf-8') == 'utf-8' then
    return
  end
  self:_resolve_position(range.start, offset_encoding)
  self:_resolve_position(range['end'], offset_encoding)
end

---@param range  lsp.Range
function Buf:replace(range, text)
  text = Buf.split_lines(text)
  api.nvim_buf_set_text(
    self.buf,
    range.start.line,
    range.start.character,
    range['end'].line,
    range['end'].character,
    text
  )
end

---@param range  lsp.Range
function Buf:delete(range)
  api.nvim_buf_set_text(
    self.buf,
    range.start.line,
    range.start.character,
    range['end'].line,
    range['end'].character,
    empty_opts
  )
end

---@param pos lsp.Position
function Buf:insert(pos, text)
  text = Buf.split_lines(text)
  api.nvim_buf_set_text(self.buf, pos.line, pos.character, pos.line, pos.character, text)
end

---@class Buf.text_edit_params
---@field encoding? 'utf-8' | 'utf-16' | 'utf-32'
---@field follow? boolean
---@field format? lsp.InsertTextFormat

---@param edit lsp.TextEdit
---@param opts Buf.text_edit_params
function Buf:text_edit(edit, opts)
  local range = edit.range
  self:_resolve_range(range, opts.encoding)
  if opts.format == 2 then
    self:delete(range)
    -- snippets are always followed
    Api.win:cursor(range.start)
    vim.snippet.expand(edit.newText)
  end
  local lines = Api.buf.split_lines(edit.newText)
  self:replace(range, lines)
  if opts.follow then
    local len = #lines
    local scol = len == 1 and range.start.character or 0
    Api.win:cursor(range.start.line + len, scol + #lines[len])
  end
end

function Buf:range_collides(range, range2) end

---@param edits lsp.TextEdit[]
---@param opts Buf.text_edit_params
function Buf:text_edits(edits, opts)
  local win = self:win()
  local row, col = win:cursor()
  for i = #edits, 1, -1 do
    local range = edits[i].range
    local lines = Buf.split_lines(edits[i].newText)
    Buf:_resolve_range(range)
    if opts.follow then
    end
  end
  win:cursor(row, col)
end

---@param key integer|string|vim.api.keyset.get_autocmds
---@param opts? vim.api.keyset.create_autocmd
function Buf:autocmd(key, opts)
  if type(key) == 'string' then
    opts = opts or {}
    opts.buffer = self.buf
    return api.nvim_create_autocmd(key, opts)
  elseif type(key) == 'number' then
    api.nvim_del_autocmd(key)
  else
    return api.nvim_get_autocmds(key)
  end
end

---@param line? string|table
function Buf:line(linr, line)
  if line == nil then
    return api.nvim_buf_get_lines(self.buf, linr, linr + 1, true)[1]
  elseif type(line) == 'string' then
    line = { line }
  end
  api.nvim_buf_set_lines(self.buf, linr, linr + 1, true, line)
end

---@param lines? string|table
function Buf:lines(s, e, lines)
  if lines == nil then
    return api.nvim_buf_get_lines(self.buf, s, e, true)
  elseif type(lines) == 'string' then
    lines = Buf.split_lines(lines)
  end
  api.nvim_buf_set_lines(self.buf, s, e, true, lines)
end

function Buf:text(s_row, s_col, e_row, e_col, text)
  if text == nil then
    return api.nvim_buf_get_text(self.buf, s_row, s_col, e_row, e_col, empty_opts)
  end
  text = Buf.split_lines(text)
  api.nvim_buf_set_text(self.buf, s_row, s_col, e_row, e_col, text)
end

---@param mode 'i'|'c'|'s'|'x'|'n'|'v'|'t'|''|'o'
---@param opts vim.api.keyset.keymap
function Buf:keymap(mode, lhs, rhs, opts)
  if lhs == nil then
    return api.nvim_buf_get_keymap(self.buf, mode)
  elseif rhs == nil then
    api.nvim_buf_del_keymap(self.buf, mode, lhs)
  else
    api.nvim_buf_set_keymap(self.buf, mode, lhs, rhs, opts)
  end
end

---@param buf_cmd_cb? fun(e: vim.UserCmdParams)
---@param opts? vim.api.keyset.user_command
function Buf:command(name, buf_cmd_cb, opts)
  if buf_cmd_cb == nil then
    api.nvim_buf_del_user_command(self.buf, name)
  else
    api.nvim_buf_create_user_command(self.buf, name, buf_cmd_cb, opts)
  end
end

function Buf:commands()
  return api.nvim_buf_get_commands(self.buf, empty_opts)
end

-- Note: 0-based
---@param pos? lsp.Position|false
function Buf:mark(name, pos)
  if pos == nil then
    local ret = api.nvim_buf_get_mark(self.buf, name)
    ret[1] = ret[1] - 1
    return ret
  elseif pos == false then
    api.nvim_buf_del_mark(self.buf, name)
  else
    api.nvim_buf_set_mark(self.buf, name, pos.line + 1, pos.character, empty_opts)
  end
end

-- Note: 0-based
function Buf:mark_all(name)
  local ret = api.nvim_get_mark(name, empty_opts)
  ret[1] = ret[1] - 1
  return ret
end

function Buf:follower() end

---@param pos lsp.Position|integer
---@param opts? vim.api.keyset.set_extmark
function Buf:highlight(ns_id, pos, opts)
  if pos == nil then
    return api.nvim_buf_get_extmarks(self.buf, ns_id, 0, -1, { type = 'highlight' })
  elseif opts == nil then
    api.nvim_buf_del_extmark(self.buf, ns_id, pos)
  else
    api.nvim_buf_set_extmark(self.buf, ns_id, pos.line, pos.character, opts)
  end
end

function Buf:extmark(ns_id, id, opts)
  return api.nvim_buf_get_extmark_by_id(self.buf, ns_id, id, opts)
end

---@param range? lsp.Range
---@param opts? vim.api.keyset.set_extmark
function Buf:extmarks(ns_id, range, opts)
  local s, e
  if range == nil then
    s, e = { 0, 0 }, { -1, -1 }
  else
    s = { range.start.line, range.start.character }
    e = { range['end'].line, range['end'].character }
  end
  return api.nvim_buf_get_extmarks(self.buf, ns_id, s, e, opts or empty_opts)
end

function Buf:selection()
  local p1, p2 = vim.fn.getpos '.', vim.fn.getpos 'v'
  if p1[2] > p2[2] or p1[3] > p2[3] then
    p1, p2 = p2, p1
  end
  return p1[2] - 1, p1[3] - 1, p2[2] - 1, p2[3] - 1
end

function Buf:var2(name, val)
  if val == nil then
    return api.nvim_buf_get_var(self.buf, name)
  elseif val == nil then
    -- you can't set nil for any vim var
    api.nvim_buf_del_var(self.buf, name)
  else
    api.nvim_buf_set_var(self.buf, name, val)
  end
end

function Buf:var()
  return vim.b[self.buf]
end

function Buf:opt()
  return vim.bo[self.buf]
end

function Buf:is_valid()
  return api.nvim_buf_is_valid(self.buf)
end

function Buf:is_loaded()
  return api.nvim_buf_is_loaded(self.buf)
end

function Buf:drop()
  api.nvim_buf_delete(self.buf, { force = true })
end

function Buf:unload()
  api.nvim_buf_delete(self.buf, { unload = true })
end

---@param pos lsp.Position|integer
function Buf:offset(pos)
  if type(pos) == 'number' then
    pos = {
      line = pos,
      character = 0,
    }
  end
  return api.nvim_buf_get_offset(self.buf, pos.line) + pos.character
end

---@param range lsp.Range
function Buf:offset_range(range) end

function Buf:count()
  return api.nvim_buf_line_count(self.buf)
end

---@param s? integer
---@param e? integer
function Buf:clear(ns_id, s, e)
  if s == nil then
    s, e = 0, -1
  end
  api.nvim_buf_clear_namespace(self.buf, ns_id, s, e)
end

function Buf:changedtick()
  return api.nvim_buf_get_changedtick(self.buf)
end

function Buf:attach(opts)
  api.nvim_buf_attach(self.buf, false, opts)
end

function Buf:detatch()
  -- TODO: type it
  api.nvim_buf_detach(self.buf)
end

function Buf:name(name)
  if name == nil then
    return api.nvim_buf_get_name(self.buf)
  end
  api.nvim_buf_set_name(self.buf, name)
end

function Buf:call(buf_cb)
  return api.nvim_buf_call(self.buf, buf_cb)
end

function Buf:win(win)
  if win == nil then
    return Api.Win.new(vim.fn.win_findbuf(self.buf)[1])
  end
end

function Buf:uri()
  return vim.uri_from_bufnr(self.buf)
end

function Buf:lsp_attach() end

return Buf
