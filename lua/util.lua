local M = {}

---@param t table
---@param ... table
function M.assign(t, ...)
  for i = 1, select('#', ...) do
    local arg = select(i, ...)
    for k, v in pairs(arg) do
      if type(v) == 'table' then
        t[k] = t[k] or {}
        M.assign(t[k], v)
      else
        t[k] = v
      end
    end
  end
  return t
end

function M.get_border_size(border)
  if not border then
    return 0, 0
  end

  if type(border) == 'string' then
    local border_size = {
      none = { 0, 0 },
      single = { 2, 2 },
      double = { 2, 2 },
      rounded = { 2, 2 },
      solid = { 2, 2 },
      shadow = { 1, 1 },
    }
    if border_size[border] == nil then
      error(string.format('invalid floating preview border: %s. :help vim.api.nvim_open_win()', vim.inspect(border)))
    end
    return unpack(border_size[border])
  else
    if 8 % #border ~= 0 then
      error(string.format('invalid floating preview border: %s. :help vim.api.nvim_open_win()', vim.inspect(border)))
    end
    local function border_width(id)
      id = (id - 1) % #border + 1
      if type(border[id]) == 'table' then
        -- border specified as a table of <character, highlight group>
        return vim.fn.strdisplaywidth(border[id][1])
      elseif type(border[id]) == 'string' then
        -- border specified as a list of border characters
        return vim.fn.strdisplaywidth(border[id])
      end
      error(string.format('invalid floating preview border: %s. :help vim.api.nvim_open_win()', vim.inspect(border)))
    end
    local function border_height(id)
      id = (id - 1) % #border + 1
      if type(border[id]) == 'table' then
        -- border specified as a table of <character, highlight group>
        return #border[id][1] > 0 and 1 or 0
      elseif type(border[id]) == 'string' then
        -- border specified as a list of border characters
        return #border[id] > 0 and 1 or 0
      end
      error(string.format('invalid floating preview border: %s. :help vim.api.nvim_open_win()', vim.inspect(border)))
    end
    local height = border_height(2) + border_height(6)
    local width = border_width(4) + border_width(8)
    return width, height
  end
end

---@param path string
function M.load_json(path)
  return vim.json.decode(io.open(path):read '*a')
end

function M.normal_validate(opts, defaults, pre)
  pre = pre or ''
  local values = {}
  for k, v in pairs(opts) do
    if type(v) == 'table' then
      assert(type(defaults[k]) == 'table', 'invalid table for ' .. pre .. k .. ', expected ' .. type(defaults[k]))
      M.normal_validate(v, defaults[k], pre .. k .. '.')
    else
      values[pre .. k] = { v, type(defaults[k]), true }
    end
  end
  vim.validate(values)
end

--#region iter
--- Unlike `Iter:flatten()`, this function doesn't rely on `ListIter` but need nested
--- items of `Iter` instance.
---@param parent Iter|fun(...):Iter the iter iterates sub-iters
function M.merge_iter(parent)
  return vim.iter(coroutine.wrap(function()
    local function yield(v, ...)
      if v then
        coroutine.yield(v, ...)
        return true
      end
    end
    for it in parent do
      while yield(it:next()) do
      end
    end
  end))
end

---@param list any[]
function M.list_iter(list)
  return vim.iter(coroutine.wrap(function()
    for _, value in ipairs(list) do
      coroutine.yield(value)
    end
  end))
end
--#endregion

---@param str string
---@param p string|vim.regex
---@return fun(): string?
function M.vim_gmatch(str, p)
  if type(p) == 'string' then
    p = vim.regex(p)
  end
  return function()
    ---@type string|integer
    local s, e = p:match_str(str)
    if not s then
      return
    end
    s = str:sub(s + 1, e)
    str = str:sub(e + 1)
    return s
  end
end

function M.get_theme()
  local file = vim.fs.normalize '$HOME/.config/$USER/theme.json'
  local theme
  if vim.uv.fs_access(file, 'R') then
    theme = M.load_json(file).theme
  end
  if not theme then
    local hour = tonumber(os.date '%H')
    if hour >= 8 and hour < 17 then
      theme = 'light'
    else
      theme = 'dark'
    end
  end
  return theme
end

function M.once(cb)
  return function(...)
    if cb then
      local bak = cb
      cb = nil
      return bak(...)
    end
  end
end

return M
