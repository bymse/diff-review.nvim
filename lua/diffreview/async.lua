local M = {}

---@param cmd string[]
---@param opts vim.SystemOpts|nil
---@return vim.SystemCompleted
function M.system(cmd, opts)
  local running = assert(coroutine.running(), 'async.system must be called inside coroutine')

  vim.system(cmd, opts or {}, function(result)
    vim.schedule(function()
      coroutine.resume(running, result)
    end)
  end)

  return coroutine.yield()
end

return M
