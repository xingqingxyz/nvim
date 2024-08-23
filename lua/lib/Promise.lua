local timers = require 'lib.timers'

---@alias PromiseFactoryCallback fun(resolve: function, reject: function): ...

---@class PromiseHandler
---@field on_resolve? function
---@field on_reject? function
---@field resolve function
---@field reject function

---@class Promise
---@field _state 'pending'|'fulfilled'|'rejected'
---@field _result? any[]
---@field _handlers PromiseHandler[]
local Promise = {}
Promise.__index = Promise

--- One implementation of JavaScript Promise
---@param cb PromiseFactoryCallback
---@return Promise
function Promise.new(cb)
  ---@class Promise
  local self = setmetatable({}, Promise)
  self._state = 'pending'
  self._handlers = {}
  local ok, err = pcall(cb, function(...)
    self:_resolve(...)
  end, function(e)
    self:_reject(e)
  end)
  if not ok then
    self:_reject(err)
  end
  return self
end

function Promise:_get_result()
  return vim.F.unpack_len(self._result)
end

function Promise:_set_state(state, ...)
  if self._state ~= 'pending' then
    return
  end
  self._state, self._result = state, vim.F.pack_len(...)
  self:_settle()
end

function Promise:_resolve(...)
  self:_set_state('fulfilled', ...)
end

function Promise:_reject(...)
  self:_set_state('rejected', ...)
end

function Promise:_settle()
  if self._state == 'pending' then
    return
  end
  for _, handler in ipairs(self._handlers) do
    timers.next_tick(function()
      local ev_handler = self._state:sub(1, 1) == 'f' and handler.on_resolve or handler.on_reject
      if type(ev_handler) ~= 'function' then
        (self._state:sub(1, 1) == 'f' and handler.resolve or handler.reject)(self:_get_result())
        return
      end
      local function resolve(first, ...)
        if Promise.is_promise(first) then
          first:then_(handler.resolve, handler.reject)
        else
          handler.resolve(first, ...)
        end
      end
      local ok, err = pcall(function()
        resolve(ev_handler(self:_get_result()))
      end)
      if not ok then
        handler.reject(err)
      end
    end)
  end
  self._handlers = {}
end

---Wait promise to finish
---@param on_resolve? function
---@param on_reject? function
function Promise:then_(on_resolve, on_reject)
  return Promise.new(function(resolve, reject)
    table.insert(self._handlers, {
      on_resolve = on_resolve,
      on_reject = on_reject,
      resolve = resolve,
      reject = reject,
    })
    self:_settle()
  end)
end

---catch promise errors
---@param on_reject? fun(e: any): ...
function Promise:catch(on_reject)
  return self:then_(nil, on_reject)
end

---clean up promise
---@param on_finally? fun(): ...
function Promise:finally(on_finally)
  if not vim.is_callable(on_finally) then
    return self:then_()
  end
  return Promise.new(function(resolve, reject)
    table.insert(self._handlers, {
      resolve = function()
        (self._state:sub(1, 1) == 'f' and resolve or reject)(self:_get_result())
      end,
      reject = reject,
      on_resolve = on_finally,
      on_reject = on_finally,
    })
    self:_settle()
  end)
end

function Promise:wait()
  while self._state == 'pending' do
    vim.wait(50)
  end
  return self._state, self._result
end

function Promise.is_promise(obj)
  return type(obj) == 'table' and vim.is_callable(obj.then_)
end

function Promise.resolve(first, ...)
  if Promise.is_promise(first) then
    return first
  end
  local args = vim.F.pack_len(first, ...)
  return Promise.new(function(resolve)
    resolve(vim.F.unpack_len(args))
  end)
end

function Promise.reject(reason)
  return Promise.new(function(_, reject)
    reject(reason)
  end)
end

---@param ... any param of |vim.iter|
function Promise.any(...)
  local idx_promise = vim.iter(...):enumerate()
  return Promise.new(function(resolve, reject)
    local errors = {}
    local count, error_count = 0, 0
    for i, p in idx_promise do
      count = count + 1
      Promise.resolve(p):then_(function(...)
        errors = nil
        resolve(...)
      end, function(e)
        if errors then
          errors[i] = e
          error_count = error_count + 1
          if error_count == count then
            reject(errors)
          end
        end
      end)
    end
  end)
end

---@param ... any param of |vim.iter|
function Promise.race(...)
  local iter = vim.iter(...)
  return Promise.new(function(resolve, reject)
    for p in iter do
      Promise.resolve(p):then_(resolve, reject)
    end
  end)
end

---@param ... any param of |vim.iter|
function Promise.all(...)
  local idx_promise = vim.iter(...):enumerate()
  return Promise.new(function(resolve, reject)
    local results = {}
    local count, result_count = 0, 0
    for i, p in idx_promise do
      count = count + 1
      Promise.resolve(p):then_(function(...)
        if results then
          results[i] = vim.F.pack_len(...)
          result_count = result_count + 1
          if result_count == count then
            resolve(results)
          end
        end
      end, function(e)
        results = nil
        reject(e)
      end)
    end
  end)
end

---@param ... any param of |vim.iter|
function Promise.all_settled(...)
  local idx_promise = vim.iter(...):enumerate()
  return Promise.new(function(resolve)
    local results = {}
    local count, result_count = 0, 0
    local function try_resolve()
      result_count = result_count + 1
      if result_count == count then
        resolve(results)
      end
    end
    for i, p in idx_promise do
      count = count + 1
      Promise.resolve(p):then_(function(...)
        results[i] = { status = 'fulfilled', value = vim.F.pack_len(...) }
        try_resolve()
      end, function(e)
        results[i] = { status = 'rejected', reason = e }
        try_resolve()
      end)
    end
  end)
end

return Promise
