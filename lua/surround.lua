local M = {}

M.pairs = {
  ['('] = { '( ', ' )' },
  [')'] = { '(', ')' },
  ['['] = { '[ ', ' ]' },
  [']'] = { '[', ']' },
  ['{'] = { '{ ', ' }' },
  ['}'] = { '{', '}' },
  ['<'] = { '< ', ' >' },
  ['>'] = { '<', '>' },
  ['（'] = { '（', '）' },
  ['【'] = { '【', '】' },
  ['《'] = { '《', '》' },
  ['‘'] = { '‘', '’' },
  ['“'] = { '“', '”' },
  __index = function(_, key)
    return { key, key }
  end,
}
setmetatable(M.pairs, M.pairs)
M.pairs.a = M.pairs['<']
M.pairs.b = M.pairs['(']
M.pairs.q = M.pairs['[']
M.pairs.B = M.pairs['{']
M.pairs.ca = M.pairs['《']
M.pairs.cb = M.pairs['（']
M.pairs.cq = M.pairs['【']
M.last_pair = nil
M.last_pair2 = nil
M.cursor = nil

function M.get_pair()
  if M.last_pair then
    return unpack(M.last_pair)
  end
  local char = vim.fn.getcharstr()
  if char == '' then
    return
  end
  local pair = M.pairs[char]
  M.last_pair = pair
  return pair[1]:rep(vim.v.count1), pair[2]:rep(vim.v.count1)
end

function M.get_pair2()
  if M.last_pair2 then
    return unpack(M.last_pair2)
  end
  local char1, char2 = vim.fn.getcharstr(), vim.fn.getcharstr()
  if #char1 + #char2 ~= 2 then
    return
  end
  local pair = vim.list_extend({}, M.pairs[char1])
  vim.list_extend(pair, M.pairs[char2])
  return vim
    .iter(pair)
    :map(function(key)
      return vim.fn.escape(key, '\\.*{}[]')
    end)
    :totable()
end

function M.surround(motion_type)
  local lquote, rquote = M.get_pair()
  if lquote == nil then
    return
  end
  local x1, y1, x2, y2
  if Api.mode() == 'n' then
    x1, y1, x2, y2 = unpack(Buf:mark '['), unpack(Buf:mark ']')
  else
    x1, y1, x2, y2 = Buf:selection()
  end
  local l1, l2 = Buf:line(x1), Buf:line(x2)
  if motion_type == 'line' then
    l1 = lquote .. l1
    l2 = l2 .. rquote
  else
    l1 = l1:sub(1, y1) .. lquote .. l1:sub(y1 + 1)
    l2 = l2:sub(1, y2) .. rquote .. l2:sub(y2 + 1)
  end
  local cursor = M.cursor or Win:cursor()
  if cursor[1] == x1 then
    cursor[2] = cursor[2] + #lquote
  end
  Buf:line(x1, l1)
  Buf:line(x2, l2)
  Win:cursor(cursor)
  M.cursor = nil
end

function M.del_surround() end

function M.change_surround()
  local src_pair, target_pair = M.get_pair(), M.get_pair()
  if not (src_pair and target_pair) then
    return
  end
  local pair = M.get_pair2()
  if pair == nil then
    return
  end
  local follower = Buf.Follower.new()
  follower:store()
  for _ = 1, vim.v.count1 do
    local row, col = unpack(vim.fn.searchpairpos(pair[1], '', pair[2], 'b'))
    Buf:text(row - 1, col - 1, row - 1, col + #pair[1], { pair[3] })
    row, col = unpack(vim.fn.searchpairpos(pair[1], '', pair[2]))
    Buf:text(row - 1, col - 1, row - 1, col + #pair[2], { pair[4] })
  end
  follower:restore()
end

function M.setup()
  vim.keymap.set('n', 'ys', function()
    M.last_pair = nil
    M.cursor = Win:cursor()
    vim.go.operatorfunc = [[v:lua.require'surround'.surround]]
    return 'g@'
  end, { expr = true, desc = 'surround with pairs' })
  vim.keymap.set('v', '<C-S>', function()
    M.last_pair = nil
    M.surround()
  end, { desc = 'surround with pairs' })
  vim.keymap.set('n', 'cs', M.change_surround, { desc = 'change surround with pairs' })
  vim.keymap.set('n', 'ds', M.del_surround, { desc = 'delete surround pairs' })
end

return M
