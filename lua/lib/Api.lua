local api = vim.api

--[[api all
nvim_get_autocmds
nvim_create_autocmd
nvim_del_autocmd
nvim_clear_autocmds
nvim_create_augroup
nvim_del_augroup_by_id
nvim_del_augroup_by_name
nvim_exec_autocmds
nvim_parse_cmd
nvim_cmd
nvim_create_user_command
nvim_del_user_command
nvim_get_commands
nvim_create_namespace
nvim_get_namespaces
nvim_set_decoration_provider
nvim_get_option_value
nvim_set_option_value
nvim_get_all_options_info
nvim_get_option_info2
nvim_get_hl_id_by_name
nvim_get_hl
nvim_set_hl
nvim_get_hl_ns
nvim_set_hl_ns
nvim_set_hl_ns_fast
nvim_feedkeys
nvim_input
nvim_input_mouse
nvim_replace_termcodes
nvim_exec_lua
nvim_notify
nvim_strwidth
nvim_list_runtime_paths
nvim_get_runtime_file
nvim_set_current_dir
nvim_get_current_line
nvim_set_current_line
nvim_del_current_line
nvim_get_var
nvim_set_var
nvim_del_var
nvim_get_vvar
nvim_set_vvar
nvim_echo
nvim_out_write
nvim_err_write
nvim_err_writeln
nvim_list_bufs
nvim_get_current_buf
nvim_set_current_buf
nvim_list_wins
nvim_get_current_win
nvim_set_current_win
nvim_create_buf
nvim_open_term
nvim_chan_send
nvim_list_tabpages
nvim_get_current_tabpage
nvim_set_current_tabpage
nvim_paste
nvim_put
nvim_subscribe
nvim_unsubscribe
nvim_get_color_by_name
nvim_get_color_map
nvim_get_context
nvim_load_context
nvim_get_mode
nvim_get_keymap
nvim_set_keymap
nvim_del_keymap
nvim_get_api_info
nvim_set_client_info
nvim_get_chan_info
nvim_list_chans
nvim_call_atomic
nvim_list_uis
nvim_get_proc_children
nvim_get_proc
nvim_select_popupmenu_item
nvim_del_mark
nvim_get_mark
nvim_eval_statusline
nvim_complete_set
nvim_exec2
nvim_command
nvim_eval
nvim_call_function
nvim_call_dict_function
nvim_parse_expression
nvim_open_win
]]

local Api = {}
local empty_opts = vim.empty_dict()

---@param key integer|string|vim.api.keyset.get_autocmds
---@param opts? vim.api.keyset.create_autocmd
function Api.autocmd(key, opts)
  if type(key) == 'string' then
    opts = opts or {}
    return api.nvim_create_autocmd(key, opts)
  elseif type(key) == 'number' then
    api.nvim_del_autocmd(key)
  else
    return api.nvim_get_autocmds(key)
  end
end

function Api.line(...)
  local line = ...
  if select('#', ...) == 0 then
    return api.nvim_get_current_line()
  elseif line == nil then
    api.nvim_del_current_line()
  else
    api.nvim_set_current_line(line)
  end
end

function Api.cwd(dir)
  if dir == nil then
    return vim.uv.cwd()
  end
  api.nvim_set_current_dir(dir)
end

function Api.command(name, cmd, opts)
  if cmd == nil then
    api.nvim_del_user_command(name)
  else
    api.nvim_create_user_command(name, cmd, opts)
  end
end

function Api.commands()
  return api.nvim_get_commands(empty_opts)
end

---@param opts? vim.api.keyset.keymap
function Api.keymap(mode, lhs, rhs, opts)
  if lhs == nil then
    return api.nvim_get_keymap(mode)
  elseif rhs == nil then
    api.nvim_del_keymap(mode, lhs)
  else
    api.nvim_set_keymap(mode, lhs, rhs, opts)
  end
end

function Api.ns(name)
  return api.nvim_create_namespace(name)
end

function Api.highlight() end

function Api.json_dump(obj, file)
  vim.fn.writefile(vim.json.encode(obj), file)
end

function Api.json_load(file)
  return vim.json.decode(vim.fn.readfile(file))
end

function Api.mode()
  return api.nvim_get_mode().mode
end

function Api.split_lines(text)
  if type(text) == 'table' then
    return text
  end
  return vim.split(text, '\r?\n', text)
end

---@param text string|string[]
---@param before? boolean
function Api.put(text, before)
  api.nvim_put(Api.split_lines(text), '', not before, false)
end

return Api
