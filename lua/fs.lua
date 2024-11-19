local uv = vim.uv
local Promise = require 'lib.Promise'

local fs = {}

---@param path string
---@param data string|string[]
---@param encoding 'utf8'
function fs.writeFile(path, data, encoding)
  encoding = encoding or 'utf8'
  local fd, err, msg = uv.fs_open(path, 'w', 438)
  if err then
    error(msg .. err)
  end
  return Promise.new(function(resolve, reject)
    uv.fs_write(fd, data, 0, function(err, bytes)
      if err then
        reject(err)
      end
      resolve(bytes)
    end)
  end)
end

---@param path string
---@param encoding 'utf8'
function fs.readFile(path, encoding)
  encoding = encoding or 'utf8'
  local fd, err, msg = uv.fs_open(path, 'r', 438)
  if err then
    error(msg .. err)
  end
  return Promise.new(function(resolve, reject)
    uv.fs_read(fd, math.huge, 0, function(err, data)
      if err then
        reject(err)
      end
      resolve(data)
    end)
  end)
end

function fs.chmod(path, mode)
  return Promise.new(function(resolve, reject)
    uv.fs_chmod(path, mode, function(err, success)
      if err then
        reject(err)
      end
      resolve(success)
    end)
  end)
end

function fs.mkdir(path, mode)
  return Promise.new(function(resolve, reject)
    uv.fs_mkdir(path, mode, function(err, success)
      if err then
        reject(err)
      end
      resolve(success)
    end)
  end)
end

function fs.rmdir(path)
  return Promise.new(function(resolve, reject)
    uv.fs_rmdir(path, function(err, success)
      if err then
        reject(err)
      end
      resolve(success)
    end)
  end)
end

function fs.realpath(path)
  return Promise.new(function(resolve, reject)
    uv.fs_realpath(path, function(err, path)
      if err then
        reject(err)
      end
      resolve(path)
    end)
  end)
end

function fs.link(path, new_path)
  return Promise.new(function(resolve, reject)
    uv.fs_link(path, new_path, function(err, success)
      if err then
        reject(err)
      end
      resolve(success)
    end)
  end)
end

function fs.unlink(path)
  return Promise.new(function(resolve, reject)
    uv.fs_unlink(path, function(err, success)
      if err then
        reject(err)
      end
      resolve(success)
    end)
  end)
end

function fs.access(path, mode)
  return Promise.new(function(resolve, reject)
    uv.fs_access(path, mode, function(err, permission)
      if err then
        reject(err)
      end
      resolve(permission)
    end)
  end)
end

function fs.mkstemp(template)
  return Promise.new(function(resolve, reject)
    uv.fs_mkstemp(template, function(err, fd, path)
      if err then
        reject(err)
      end
      resolve(fd, path)
    end)
  end)
end

function fs.mkdtemp(template)
  return Promise.new(function(resolve, reject)
    uv.fs_mkdtemp(template, function(err, path)
      if err then
        reject(err)
      end
      resolve(path)
    end)
  end)
end

---@param path string
---@param uid integer
---@param gid integer
---@return Promise
function fs.chown(path, uid, gid)
  return Promise.new(function(resolve, reject)
    uv.fs_chown(path, uid, gid, function(err, success)
      if err then
        reject(err)
      end
      resolve(success)
    end)
  end)
end

function fs.close(fd)
  return Promise.new(function(resolve, reject)
    uv.fs_close(fd, function(err, success)
      if err then
        reject(err)
      end
      resolve(success)
    end)
  end)
end

---@param dir luv_dir_t
---@return Promise
function fs.closedir(dir)
  return Promise.new(function(resolve, reject)
    uv.fs_closedir(dir, function(err, success)
      if err then
        reject(err)
      end
      resolve(success)
    end)
  end)
end

---@param path string
---@param new_path string
---@param flags? { excl: boolean,  ficlone: boolean, ficlone_force: boolean }
---@return Promise
function fs.copyfile(path, new_path, flags)
  flags = flags or { excl = false, ficlone = false, ficlone_force = false }
  return Promise.new(function(resolve, reject)
    uv.fs_copyfile(path, new_path, flags, function(err, success)
      if err then
        reject(err)
      end
      resolve(success)
    end)
  end)
end

---@param path string
---@param options { recursive?: boolean, force?: boolean }
function fs.rm(path, options)
  return Promise.new(function(resolve, reject)
    local t = uv.fs_stat(path).type
    if t == 'directory' then
      uv.fs_rmdir(path, function(err, success)
        if err then
          reject(err)
        end
        resolve(success)
      end)
    else
      uv.fs_unlink(path, function(err, success)
        if err then
          reject(err)
        end
        resolve(success)
      end)
    end
  end)
end

return fs
