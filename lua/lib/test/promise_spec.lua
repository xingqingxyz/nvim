local Promise, timers = require 'lib.promise', require 'lib.timers'

local M = {}

function M.test_order()
  print '1'
  local p = Promise.new(function(resolve, reject)
    print '2'
    timers.set_timeout(500, function()
      print '3'
      resolve(1)
    end)
  end)
  print '4'
  p:then_(function(v)
    print '5'
    return v
  end)
  print '6'
  p:then_(function(v)
    print '7'
  end, function(e)
    print '8'
  end):then_(function(v)
    print '9'
  end)
  print '10'
  vim.wait(600)
end

function M.test_static()
  local print = vim.schedule_wrap(vim.print)
  local function eprint(...)
    print('error', ...)
  end

  Promise.any({ 1, 2 }):then_(print, eprint)
  Promise.race({ 1, 2 }):then_(print, eprint)
  Promise.all({ 1, 2 }):then_(print, eprint)
  Promise.all_settled({ 1, 2 }):then_(print, eprint)

  Promise.any({ Promise.reject(1), 2 }):then_(print, eprint)
  Promise.any({ Promise.reject(1), Promise.reject(2) }):then_(print, eprint)
  Promise.race({ Promise.reject(1), 2 }):then_(print, eprint)
  Promise.all({ Promise.reject(1), 2 }):then_(print, eprint)
  Promise.all_settled({ Promise.reject(1), 2 }):then_(print, eprint)

  vim.wait(10)
end

function M.test_finally()
  Promise.resolve(13)
    :finally(function()
      return Promise.resolve(14)
    end)
    :then_(function()
      print(15)
    end, function()
      print(16)
    end)
  Promise.resolve(9)
    :finally(function()
      return Promise.reject(10)
    end)
    :then_(function()
      print(11)
    end, function()
      print(12)
    end)
  Promise.resolve(1)
    :then_(function()
      return Promise.resolve(2)
    end)
    :then_(function()
      print(3)
    end)
  Promise.resolve(4):then_():then_(function()
    print(6)
  end)
  Promise.resolve(7):finally():then_(function()
    print(8)
  end)

  vim.wait(100)
end

M.test_finally()

return M
