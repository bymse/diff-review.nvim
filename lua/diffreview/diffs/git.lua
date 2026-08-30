require('diffreview.diffs.types')

local M = {}

---@param receive_result fun(result: GitResult, oid: string|nil)
---@return GitJob
local function rev_parse(expression, cwd, receive_result)
  local cmd = {
    'git', 'rev-parse', '--verify', '--end-of-options',
    expression .. '^{commit}'
  }

  ---@param result vim.SystemCompleted
  local on_exit = function(result)
    if result.code == 0 then
      receive_result({ ok = true }, vim.trim(result.stdout))
    else
      receive_result({ ok = false, error = result.stderr })
    end
  end

  local process = vim.system(cmd, { text = true, cwd = cwd }, on_exit)
  return {
    wait = function()
      process:wait()
    end
  }
end

---@param _from_commit_oid string|nil
---@param _to_commit_oid string|nil
function M.diff(_from_commit_oid, _to_commit_oid)

end

function M.ls_files()
end

---@param dir string|nil
---@return GitRepo
function M.get_repo(dir)
  return {
    rev_parse = function(expression, receive_result)
      return rev_parse(expression, dir, receive_result)
    end
  }
end

return M
