local M = {}

function M.hello()
  return 'Hello World'
end

vim.notify(M.hello())

return M
