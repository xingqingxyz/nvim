local M = {}

---@class Freeze
---@field private _meta table
local Freeze = {}

function Freeze.new(obj)
  ---@class Freeze
  local self = setmetatable({}, Freeze)
  self._meta = obj
  return self
end

function Freeze:__index(k)
  return self._meta[k]
end

function Freeze:__newindex(k, v)
  error('attempt to modify frozen table: ' .. k)
end

function Freeze:pairs()
  return coroutine.wrap(function()
    for key, value in pairs(self._meta) do
      coroutine.yield(key, value)
    end
  end)
end

function Freeze:ipairs()
  return coroutine.wrap(function()
    for key, value in ipairs(self._meta) do
      coroutine.yield(key, value)
    end
  end)
end

function Freeze:list_iter()
  return vim.iter(coroutine.wrap(function()
    for _, value in ipairs(self._meta) do
      coroutine.yield(value)
    end
  end))
end

function Freeze:dangerous_get_raw()
  return self._meta
end

function M.freeze(obj)
  return Freeze.new(obj)
end

return M
