local api = vim.api

--[[api (No types yet?)
nvim_ui_attach
nvim_ui_set_focus
nvim_ui_detach
nvim_ui_try_resize
nvim_ui_set_option
nvim_ui_try_resize_grid
nvim_ui_pum_set_height
nvim_ui_pum_set_bounds
nvim_ui_term_event
]]

---@class UI
local UI = {}
UI.__index = UI

function UI.new()
  local self = setmetatable({}, UI)
  return self
end

function UI:attach()
  api.nvim_ui_attach()
end

return UI
