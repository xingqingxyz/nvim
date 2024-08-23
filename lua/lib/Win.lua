local api = vim.api

--[[api
nvim_win_add_ns
nvim_win_get_ns
nvim_win_remove_ns
nvim_win_set_config
nvim_win_get_config
nvim_win_get_buf
nvim_win_set_buf
nvim_win_get_cursor
nvim_win_set_cursor
nvim_win_get_height
nvim_win_set_height
nvim_win_get_width
nvim_win_set_width
nvim_win_get_var
nvim_win_set_var
nvim_win_del_var
nvim_win_get_position
nvim_win_get_tabpage
nvim_win_get_number
nvim_win_is_valid
nvim_win_hide
nvim_win_close
nvim_win_call
nvim_win_set_hl_ns
nvim_win_text_height
]]

---@class Win
local Win = {}
Win.__index = Win
Win.win = 0

function Win.new(winnr)
  winnr = winnr or api.nvim_get_current_win()
  ---@class Win
  return setmetatable({ win = winnr }, Win)
end

---@param config? vim.api.keyset.win_config
function Win:config(config)
  if config == nil then
    return api.nvim_win_get_config(self.win)
  end
  api.nvim_win_set_config(self.win, config)
end

function Win:close()
  api.nvim_win_close(self.win, true)
end

function Win:hide()
  api.nvim_win_hide(self.win)
end

function Win:buf()
  return api.nvim_win_get_buf(self.win)
end

function Win:ns(ns_id)
  if ns_id == nil then
    return api.nvim_win_get_ns(self.win)
  end
  api.nvim_win_set_hl_ns(self.win, ns_id)
end

function Win:add(ns_id)
  api.nvim_win_add_ns(self.win, ns_id)
end

function Win:remove(ns_id)
  api.nvim_win_remove_ns(self.win, ns_id)
end

function Win:is_valid()
  return api.nvim_win_is_valid(self.win)
end

function Win:call(win_cb)
  api.nvim_win_call(self.win, win_cb)
end

---@param range lsp.Range
function Win:text_height(range)
  ---@type vim.api.keyset.win_text_height
  local opts = {
    start_row = range.start.line,
    start_vcol = range.start.character,
    end_row = range['end'].line,
    end_vcol = range['end'].character,
  }
  return api.nvim_win_text_height(self.win, opts)
end

function Win:height(height)
  if height == nil then
    return api.nvim_win_get_height(self.win)
  end
  api.nvim_win_set_height(self.win, height)
end

function Win:width(width)
  if width == nil then
    return api.nvim_win_get_width(self.win)
  end
  api.nvim_win_set_width(self.win, width)
end

function Win:position()
  return api.nvim_win_get_position(self.win)
end

function Win:tab()
  return api.nvim_win_get_tabpage(self.win)
end

function Win:var()
  return vim.w[self.win]
end

function Win:opt()
  return vim.wo[self.win]
end

--- Note: All indexes is 0-based
---@param cursor? table [integer, integer]
function Win:cursor(cursor)
  if cursor == nil then
    cursor = api.nvim_win_get_cursor(self.win)
    cursor[1] = cursor[1] - 1
    return cursor
  end
  cursor[1] = cursor[1] + 1
  api.nvim_win_set_cursor(self.win, cursor)
end

return Win
