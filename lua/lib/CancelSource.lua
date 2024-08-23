---@class CancelSource
local CancelSource = {}
CancelSource.__index = CancelSource

---@class CancelToken
local CancelToken = {}
CancelToken.__index = CancelToken

---@param source CancelSource
function CancelToken.new(source)
  ---@class CancelToken
  local self = setmetatable({}, CancelToken)
  self.canceled = false
  self._source = source
  self._callbacks = {}
  return self
end

function CancelToken:on_cancel(on_cancel)
  if self.canceled then
    return
  end
  table.insert(self._callbacks, on_cancel)
end

function CancelToken:_cancel(reason)
  if self.canceled then
    return
  end
  self.canceled = true
  self.reason = reason
  for _, on_cancel in ipairs(self._callbacks) do
    pcall(on_cancel)
  end
  self._callbacks = nil
  self._source = nil
end

function CancelSource.new()
  ---@class CancelSource
  local self = setmetatable({}, CancelSource)
  self.token = CancelToken.new(self)
  return self
end

function CancelSource:cancel(reason)
  self.token:_cancel(reason)
end

return CancelSource
