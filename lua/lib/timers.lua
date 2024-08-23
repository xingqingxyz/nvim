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
---@param debouced function
---@param delay integer
---@param should_call boolean
function M.debounce(debouced, delay, should_call)
  local timer = safe_new_timer()
  if should_call then
    ---@async
    return function(...)
      local args = vim.F.pack_len(...)
      if should_call then
        should_call = false
        timer:start(0, 0, function()
          timer:start(delay, 0, function()
            should_call = true
          end)
          debouced(vim.F.unpack_len(args))
        end)
        return
      end
      timer:start(delay, 0, function()
        timer:start(delay, 0, function()
          should_call = true
        end)
        debouced(vim.F.unpack_len(args))
      end)
    end
  end
  ---@async
  return function(...)
    local args = vim.F.pack_len(...)
    timer:start(delay, 0, function()
      debouced(vim.F.unpack_len(args))
    end)
  end
end

---@param throttled function
---@param interval integer
---@param should_call boolean
function M.throttle(throttled, interval, should_call)
  local timer = safe_new_timer()
  return function(...)
    if should_call then
      should_call = false
      timer:start(interval, 0, function()
        should_call = true
      end)
      throttled(...)
    end
  end
end

---@param throttled function
---@param interval integer
---@param should_call boolean
function M.throttle_time(throttled, interval, should_call)
  local now = should_call and -math.huge or math.huge
  return function(...)
    if uv.now() - now >= interval then
      now = uv.now()
      throttled(...)
    end
  end
end

---@param ms integer
---@param timeout_cb function
function M.set_timeout(ms, timeout_cb)
  local timer = uv.new_timer()
  timer:start(ms, 0, function()
    timer:stop()
    timer:close()
    timeout_cb()
  end)
  return timer
end

---@param ms integer
---@param interval_cb function
function M.set_interval(ms, interval_cb)
  local timer = safe_new_timer()
  timer:start(ms, ms, interval_cb)
  return timer
end

---@param next_tick_cb function
function M.next_tick(next_tick_cb)
  local timer = uv.new_timer()
  timer:start(0, 0, function()
    timer:close()
    next_tick_cb()
  end)
end

---@generic RT
---@param async_fn fun(cb: fun(...: RT)) async callback
---@return RT
function M.sync(async_fn)
  local result
  async_fn(function(...)
    result = vim.F.pack_len(...)
  end)
  while not result do
    vim.wait(50)
  end
  return vim.F.unpack_len(result)
end

return M
