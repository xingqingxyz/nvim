local uv = vim.uv

local M = {}

local function safe_new_timer()
  local timer = uv.new_timer()
  vim.api.nvim_create_autocmd('VimLeavePre', {
    callback = function()
      timer:stop()
      timer:close()
    end,
    desc = 'Auto close timer on VimLeavePre',
  })
  return timer
end

--#region timeout
---@param callback function
---@param delay integer
---@param should_call boolean
function M.debounce(callback, delay, should_call)
  local timer = safe_new_timer()
  if should_call then
    ---@async
    return function(...)
      local args = vim.F.pack_len(...)
      local first_delay = delay
      if should_call then
        should_call = false
        first_delay = 0
      end
      timer:start(first_delay, 0, function()
        timer:start(delay, 0, function()
          should_call = true
        end)
        callback(vim.F.unpack_len(args))
      end)
    end
  end
  ---@async
  return function(...)
    local args = vim.F.pack_len(...)
    timer:start(delay, 0, function()
      callback(vim.F.unpack_len(args))
    end)
  end
end

---@param callback function
---@param interval integer
---@param should_call boolean
function M.throttle(callback, interval, should_call)
  local timer = safe_new_timer()
  return function(...)
    if should_call then
      should_call = false
      timer:start(interval, 0, function()
        should_call = true
      end)
      callback(...)
    end
  end
end

---@param callback function
---@param interval integer
---@param should_call boolean
function M.throttle_time(callback, interval, should_call)
  local now = should_call and -math.huge or math.huge
  return function(...)
    if uv.now() - now >= interval then
      now = uv.now()
      callback(...)
    end
  end
end

---@param ms integer
---@param callback function
function M.set_timeout(ms, callback)
  local timer = uv.new_timer()
  timer:start(ms, 0, function()
    timer:stop()
    timer:close()
    callback()
  end)
  return timer
end

---@param ms integer
---@param callback function
function M.set_interval(ms, callback)
  local timer = safe_new_timer()
  timer:start(ms, ms, callback)
  return timer
end

---@param callback function
function M.next_tick(callback)
  local timer = uv.new_timer()
  timer:start(0, 0, function()
    timer:close()
    callback()
  end)
end

---@generic RT
---@param callback fun(cb: fun(...: RT)) async callback
---@return ...
function M.sync(callback)
  local result
  callback(function(...)
    result = vim.F.pack_len(...)
  end)
  while not result do
    vim.wait(50)
  end
  return vim.F.unpack_len(result)
end

return M
