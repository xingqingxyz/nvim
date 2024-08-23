local M = {}

local function move_to_bottom(lines, count)
  local saved = vim.list_extend({}, lines, count + 1)
  for i = #lines, #saved + 1, -1 do
    lines[i] = lines[i - #saved]
  end
  for i = 1, #saved do
    lines[i] = saved[i]
  end
end

local function dup_lines(lines, count)
  local raw_len = #lines
  for i = 1, count do
    local linr = i * raw_len
    for j = 1, raw_len do
      lines[linr + j] = lines[j]
    end
  end
end

function M.move_lines_down()
  local cursor = Win:cursor()
  if cursor[1] + 1 == Buf:count() then
    return
  end
  local mode = Api.mode():sub(1, 1)
  local l1, l2
  if mode == 'i' or mode == 'n' then
    l1 = cursor[1]
    l2 = l1 + 1
  elseif ('vV\x16sS\x13'):find(mode) then
    l1, _, l2 = Buf:selection()
    l2 = l2 + 1
  else
    return
  end
  -- L - L1 - (L2 - L1)
  local count = math.min(Buf:count() - l2, vim.v.count1)
  local l4 = l2 + count
  local l3 = l4 - (l2 - l1)
  local lines = Buf:lines(l1, l4)
  move_to_bottom(lines, l2 - l1)
  Buf:lines(l1, l4, lines)
  cursor[1] = l3
  Win:cursor(cursor)
  if l2 - l1 > 1 then
    vim.cmd(('norm VV%dj'):format(l2 - l1 - 1))
  end
end

function M.move_lines_up()
  local cursor = Win:cursor()
  if cursor[1] == 0 then
    return
  end
  local mode = Api.mode():sub(1, 1)
  local l3, l4
  if mode == 'i' or mode == 'n' then
    l3 = cursor[1]
    l4 = l3 + 1
  elseif ('vV\x16sS\x13'):find(mode) then
    l3, _, l4 = Buf:selection()
    l4 = l4 + 1
  else
    return
  end
  local count = math.min(l3, vim.v.count1)
  local l1 = l3 - count
  local l2 = l1 + l4 - l3
  local lines = Buf:lines(l1, l4)
  move_to_bottom(lines, count)
  Buf:lines(l1, l4, lines)
  cursor[1] = l2 - 1
  Win:cursor(cursor)
  if l4 - l3 > 1 then
    vim.cmd(('norm VV%dk'):format(l4 - l3 - 1))
  end
end

function M.dup_lines_down()
  local cursor = Win:cursor()
  local mode = Api.mode():sub(1, 1)
  local l1, l2
  if mode == 'i' or mode == 'n' then
    l1 = cursor[1]
    l2 = l1 + 1
  elseif ('vV\x16sS\x13'):find(mode) then
    l1, _, l2 = Buf:selection()
    l2 = l2 + 1
  else
    return
  end
  local count = vim.v.count1
  local l3 = l1 + count * (l2 - l1)
  local lines = Buf:lines(l1, l2)
  dup_lines(lines, count)
  Buf:lines(l1, l2, lines)
  cursor[1] = l3
  Win:cursor(cursor)
  if l2 - l1 > 1 then
    vim.cmd(('norm VV%dj'):format(l2 - l1 - 1))
  end
end

function M.dup_lines_up()
  local cursor = Win:cursor()
  local mode = Api.mode():sub(1, 1)
  local l3, l4
  if mode == 'i' or mode == 'n' then
    l3 = cursor[1]
    l4 = l3 + 1
  elseif ('vV\x16sS\x13'):find(mode) then
    l3, _, l4 = Buf:selection()
    l4 = l4 + 1
  else
    return
  end
  local count = vim.v.count1
  local lines = Buf:lines(l3, l4)
  dup_lines(lines, count)
  Buf:lines(l3, l4, lines)
  cursor[1] = l4 - 1
  Win:cursor(cursor)
  if l4 - l3 > 1 then
    vim.cmd(('norm VV%dk'):format(l4 - l3 - 1))
  end
end

return M
