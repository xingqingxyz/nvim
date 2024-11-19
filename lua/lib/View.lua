local api = vim.api
local assign = require('util').assign

---@class View
---@field _bufnr integer
---@field _window integer
---@field _win_config? vim.api.keyset.win_config
---@field open_win fun(self, opts: vim.api.keyset.win_config)
---@field make_win_config fun(self, lines: string[]): vim.api.keyset.win_config
local View = {}
View.__index = View
View.augroup = api.nvim_create_augroup('lib/view', {})

function View.new()
  local self = setmetatable({}, View)
  api.nvim_create_autocmd('WinClosed', {
    group = View.augroup,
    callback = function(e)
      self:on_WinClosed(e)
    end,
    desc = 'lib/view: auto deletes buffer on WinClosed',
  })
  api.nvim_create_autocmd('VimResized', {
    group = View.augroup,
    callback = function(e)
      ---@diagnostic disable-next-line: redundant-parameter
      self:on_VimResized(e)
    end,
    desc = 'lib/view: auto resize window on VimResized',
  })
  return self
end

--- Open or reuse the window, set the lines in the buffer and set the window config.
---@param lines string[]
function View:update_win(lines)
  local win_config = self:make_win_config(lines)
  if not win_config then
    if self._bufnr then
      api.nvim_buf_set_lines(self._bufnr, 0, -1, true, lines)
    end
    return
  end
  win_config.hide = false
  if self._window then
    self:set_win_config(win_config)
  else
    self:update_win(win_config)
    self._win_config = self:get_win_config()
  end
  api.nvim_buf_set_lines(self._bufnr, 0, -1, true, lines)
end

function View:is_visible()
  return self._window and not self._win_config.hide
end

function View:close()
  if self._window then
    -- note: this will implicitly deletes the buffer
    api.nvim_win_close(self._window, true)
  end
end

function View:hide()
  if self:is_visible() then
    api.nvim_win_set_config(self._window, { hide = true })
    self._win_config.hide = true
  end
end

function View:unhide()
  if self._window then
    api.nvim_win_set_config(self._window, { hide = false })
    self._win_config.hide = false
  end
end

function View:on_VimResized()
  if self:is_visible() then
    local win_config =
      self:make_win_config(api.nvim_buf_get_lines(self._bufnr, 0, -1, true))
    if win_config then
      win_config.hide = false
      api.nvim_win_set_config(self._window, win_config)
    end
  end
end

--- Auto deletes buffer on WinClosed event.
---@param e vim.AutocmdParams
function View:on_WinClosed(e)
  if tonumber(e.file) == self._window then
    api.nvim_buf_delete(self._bufnr, { force = true })
    self._bufnr, self._window, self._win_config = nil, nil, nil
  end
end

---@param delta integer
function View:next_page(delta)
  assert(self:is_visible(), 'no visible window')
  local cursor = api.nvim_win_get_cursor(self._window)
  cursor[1] = math.max(
    1,
    math.min(
      cursor[1] + delta * self._win_config.height,
      api.nvim_buf_line_count(self._bufnr)
    )
  )
  api.nvim_win_set_cursor(self._window, cursor)
end

function View:get_win_config()
  assert(self._window, 'no active window')
  if self._win_config then
    return self._win_config
  end
  local win_config = api.nvim_win_get_config(self._window)
  if type(win_config.row) == 'table' then
    win_config.row, win_config.col =
      win_config.row[vim.val_idx], win_config.col[vim.val_idx]
  end
  return win_config
end

---@param win_config vim.api.keyset.win_config
function View:set_win_config(win_config)
  assert(self._window, 'no active window')
  api.nvim_win_set_config(self._window, win_config)
  if self._win_config then
    assign(self._win_config, win_config)
  else
    self._win_config = self:get_win_config()
  end
end

return View
