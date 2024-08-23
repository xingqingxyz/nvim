local M = {}

function M.print(...)
  if os.getenv 'DEV' then
    vim.print(...)
  end
end

return M
