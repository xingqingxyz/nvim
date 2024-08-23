local api = vim.api

--[[api
nvim_tabpage_list_wins
nvim_tabpage_get_var
nvim_tabpage_set_var
nvim_tabpage_del_var
nvim_tabpage_get_win
nvim_tabpage_set_win
nvim_tabpage_get_number
nvim_tabpage_is_valid
]]

---@class Tab
local Tab = {}
Tab.__index = Tab
Tab.tab = 0

function Tab.new(tab)
  if (tab or 0) == 0 then
    tab = api.nvim_get_current_tabpage()
  end
  ---@class Tab
  return setmetatable({ tab = tab }, Tab)
end

function Tab:var()
  return vim.t[self.tab]
end

function Tab:win(win)
  if win == nil then
    return api.nvim_tabpage_get_win(self.tab)
  end
  api.nvim_tabpage_set_win(self.tab, win)
end

function Tab:wins()
  return api.nvim_tabpage_list_wins(self.tab)
end

function Tab:is_valid()
  return api.nvim_tabpage_is_valid(self.tab)
end

return Tab
