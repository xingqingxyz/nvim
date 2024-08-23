local api = vim.api

---@param cmd string|string[]
---@param opts? vim.fn.keyset.jobstart_opts
---@return integer?
local function open_term(cmd, opts)
  local bufnr = api.nvim_create_buf(false, true)
  local width, height = math.floor(vim.go.columns * 0.80), math.floor(vim.go.lines * 0.75)
  local winid = api.nvim_open_win(bufnr, true, {
    relative = 'editor',
    row = math.floor(vim.go.lines * 0.10),
    col = math.floor(vim.go.columns * 0.10),
    style = 'minimal',
    noautocmd = true,
    width = width,
    height = height,
  })
  -- only trigger this autocmd to free memory
  api.nvim_create_autocmd('WinClosed', {
    buffer = bufnr,
    once = true,
    desc = 'Delete auto created terminal buffer',
    callback = function()
      api.nvim_buf_delete(bufnr, { force = true })
    end,
  })

  local job_id = vim.fn.termopen(cmd, opts or vim.empty_dict())
  if job_id <= 0 then
    api.nvim_win_close(winid, true)
    return
  end
  return job_id
end

---@param cmd string|string[]
---@param opts? vim.fn.keyset.jobstart_opts
---@param e vim.UserCmdParams
---@return integer?
local function open_term_wrapper(cmd, opts, e)
  local text
  if e.range > 0 then
    text = table.concat(api.nvim_buf_get_lines(0, e.line1 - 1, e.line2, true), '\n') .. '\n\x04\x04'
  end
  local id = open_term(cmd, opts)
  if text then
    api.nvim_chan_send(id, text)
  end
  return id
end

local exec_cmd_map = {
  --[[always colored: hexyl, delta, fzf, chafa]]
  jq = 'jq -C',
}

for _, cmd in ipairs { 'grep', 'bat', 'ls', 'eza', 'rg', 'fd', 'sg' } do
  exec_cmd_map[cmd] = cmd .. ' --color=always'
end

---@param e vim.UserCmdParams
local function exec(e)
  if e.bang then
    vim.print(e)
  end
  local cmd = e.fargs[1]
  cmd = (exec_cmd_map[cmd] or cmd) .. e.args:sub(#cmd + 1)
  if e.range > 0 then
    open_term_wrapper('cat | ' .. cmd, nil, e)
  else
    open_term(cmd)
  end
end

---@param e vim.UserCmdParams
local function glow(e)
  local cmd = vim.list_extend({ 'glow', '-s', 'dark' }, e.fargs)
  if e.range > 0 then
    table.insert(cmd, '-')
  end
  open_term_wrapper(cmd, nil, e)
end

---@param e vim.UserCmdParams
local function term(e)
  local cmd
  if e.bang then
    cmd = { 'zsh' }
  else
    cmd = { 'bash', '-c', e.args }
  end
  local id = open_term(cmd)
  if id <= 0 then
    return
  end
  local info = api.nvim_get_chan_info(id)
  vim.bo[info.buffer].bh = 'hide'
end

local M = {}

function M.setup()
  api.nvim_create_user_command('Exec', exec, {
    nargs = '+',
    range = true,
    bang = true,
    complete = 'shellcmd',
    desc = 'Start any terminal program with pty and UI',
  })
  api.nvim_create_user_command('Term', term, {
    nargs = '*',
    bang = true,
    complete = 'shellcmd',
    desc = 'Start bash / zsh with pty and UI',
  })
  api.nvim_create_user_command('Glow', glow, {
    nargs = '*',
    range = true,
    complete = 'file',
    desc = 'Open glow UI',
  })
end

return M
