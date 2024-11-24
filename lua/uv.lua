local uv = vim.uv

local constants = {
  features = {
    win32 = 'win32',
  },
  autocmds = {
    BufWinEnter = 'BufWinEnter',
    WinEnter = 'WinEnter',
    WinLeave = 'WinLeave',
    BufWinLeave = 'BufWinLeave',
    BufReadPost = 'BufReadPost',
    BufReadPre = 'BufReadPre',
    BufNewFile = 'BufNewFile',
    BufWritePost = 'BufWritePost',
    BufWritePre = 'BufWritePre',
    BufWrite = 'BufWrite',
    BufRead = 'BufRead',
    BufNew = 'BufNew',
    BufDelete = 'BufDelete',
    BufHidden = 'BufHidden',
    BufLeave = 'BufLeave',
    VimEnter = 'VimEnter',
    VimLeave = 'VimLeave',
    VimLeavePre = 'VimLeavePre',
    FileType = 'FileType',
    LSpAttach = 'LSpAttach',
    LspDetach = 'LspDetach',
    LspProgress = 'LspProgress',
    InsertEnter = 'InsertEnter',
    InsertLeave = 'InsertLeave',
    InsertChange = 'InsertChange',
    InsertCharPre = 'InsertCharPre',
    CmdlineEnter = 'CmdlineEnter',
    CmdlineLeave = 'CmdlineLeave',
    CursorHold = 'CursorHold',
    CursorHoldI = 'CursorHoldI',
    CursorMoved = 'CursorMoved',
    CursorMovedI = 'CursorMovedI',
    ContentChanged = 'ContentChanged',
    TabNew = 'TabNew',
    TabClosed = 'TabClosed',
    TabEnter = 'TabEnter',
    TabLeave = 'TabLeave',
  },
}

Api.is_windows = vim.fn.has(constants.features.win32) == 1

local fs_promise = {}
local Promise = require 'lib.Promise'

function fs_promise.read_file(path, encoding)
  encoding = encoding or 'utf8'
  return Promise.new(function(resolve, reject)
    local fd, err, msg = uv.fs_open(path, 'r', 438)
    if err then
      reject(err, msg)
    end
    resolve(fd)
  end):then_(function(fd)
    uv.fs_read(fd, -1, 0, function(err, data) end)
  end)
end
