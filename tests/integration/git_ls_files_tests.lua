local git = require('diffreview.diffs.git')
local git_repo = require('helpers.git_repo')
local M = {}

---@param repo GitRepo
---@return string[]
local function ls_files(repo)
  ---@type GitResult|nil
  local received_result
  ---@type string[]|nil
  local received_paths

  local job = repo:ls_files(function(result, paths)
    received_result = result
    received_paths = paths
  end)

  job:wait()

  assert(received_result ~= nil, 'expected ls-files result')
  assert(received_result.ok, 'expected ls-files to succeed: ' .. (received_result.error or 'unknown error'))
  assert(received_paths ~= nil, 'expected parsed paths')
  return received_paths
end

M.ls_files_should_return_empty_array_when_repository_is_empty = function()
  git_repo.with_repo(function(test_repo)
    local paths = ls_files(git.get_repo(test_repo.cwd))

    assert(#paths == 0, 'expected no untracked files')
  end)
end

M.ls_files_should_return_only_untracked_files_when_one_file_is_staged = function()
  git_repo.with_repo(function(test_repo)
    test_repo:write_file('first.txt', { 'first' })
    test_repo:write_file('second.txt', { 'second' })
    test_repo:write_file('staged.txt', { 'staged' })
    test_repo:add('staged.txt')

    local paths = ls_files(git.get_repo(test_repo.cwd))

    assert(vim.deep_equal(paths, { 'first.txt', 'second.txt' }), 'expected only untracked files')
  end)
end

return M
