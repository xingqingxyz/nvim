local next_tick = require('lib.timers').next_tick

local function ok_or_error(ok, ...)
  if ok then
    return ...
  end
  error(...)
end

local M = {}

---@async
--- Async runner uses coroutine, give coroutine.wrap() returns resume to runner.
---@returns first yield values
---@param runner fun(resume: function): ... async or sync runner
---@param resolve function? if supplys resolve, it will be called defer current thread although it is sync.
function M.run(runner, resolve)
  local resume
  if resolve then
    resume = coroutine.wrap(function()
      local sync = true
      next_tick(function()
        sync = false
      end);
      (function(...)
        if sync then
          next_tick(resume)
          coroutine.yield()
        end
        resolve(...)
      end)(runner(resume))
    end)
  else
    resume = coroutine.wrap(function()
      return runner(resume)
    end)
  end
  return resume()
end

--- Wrappers around M.run()
---@param runner fun(resume: function, ...): ... async or sync runner
---@param resolve function?
function M.wrap(runner, resolve)
  ---@async
  return function(...)
    local args = vim.F.pack_len(...)
    M.run(function(resume)
      return runner(resume, vim.F.unpack_len(args))
    end, resolve)
  end
end

--- Wrappers around M.run() but for method
---@param runner fun(resume: function, ...): ... async or sync runner
---@param resolve function?
function M.wrap_method(runner, resolve)
  ---@async
  return function(cls, ...)
    local args = vim.F.pack_len(...)
    M.run(function(resume)
      return runner(cls, resume, vim.F.unpack_len(args))
    end, resolve)
  end
end

--- Reenter async context when in fast event, but cannot escape from |textlock|.
function M.reenter()
  if vim.in_fast_event() then
    local co = assert(coroutine.running())
    vim.schedule(function()
      coroutine.resume(co)
    end)
    coroutine.yield()
  end
end

function M.get_resume()
  local co = coroutine.running()
  return function(...)
    return ok_or_error(coroutine.resume(co, ...))
  end
end

return M
