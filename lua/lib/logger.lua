---@class Logger
---@field debug fun(msg: string)
---@field info fun(msg: string)
---@field warn fun(msg: string)
---@field error fun(msg: string)
local M = {}

local log_path = vim.fn.stdpath 'log' .. '/myvim.log'
local log_file = assert(vim.uv.fs_open(log_path, 'a', 0), 'cannot open log file')

for _, key in ipairs { 'debug', 'info', 'warn', 'error' } do
  M[key] = function(msg)
    msg = Api.split_lines(msg)
    msg[1] = ('%s [%s] %s'):format(os.date '%Y-%m-%d %H:%M:%S', key, msg[1])
    vim.uv.fs_write(log_file, msg, -1)
  end
end

function M.setup()
  Au.add('VimLeavePre', {
    callback = function()
      if not vim.uv.fs_close(log_file) then
        M.error 'log file failed to save'
      end
    end,
    group = 'lib/logger',
    desc = "Close log file's fd",
  })
  return M
end

return M
