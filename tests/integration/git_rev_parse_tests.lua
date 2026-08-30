local git = require('diffreview.diffs.git')
local git_repo = require('helpers.git_repo')
local M = {}

---@param repo GitRepo
---@return string
local function resolve(repo, expression)
  ---@type GitResult|nil
  local received_result
  local received_oid

  local job = repo:rev_parse(expression, function(result, oid)
    received_result = result
    received_oid = oid
  end)

  job:wait()

  assert(received_result ~= nil, 'expected rev-parse result')
  assert(received_result.ok, 'expected rev-parse to succeed: ' .. (received_result.error or 'unknown error'))
  assert(received_oid ~= nil, 'expected a commit object ID')
  return received_oid
end

M.rev_parse_should_return_error_when_repository_has_no_commits = function()
  git_repo.with_repo(function(test_repo)
    local repo = git.get_repo(test_repo.cwd)
    ---@type GitResult|nil
    local received_result
    local received_oid

    local job = repo:rev_parse('HEAD', function(result, oid)
      received_result = result
      received_oid = oid
    end)

    job:wait()

    assert(received_result ~= nil, 'expected rev-parse result')
    assert(not received_result.ok, 'expected rev-parse to fail')
    assert(received_result.error ~= nil, 'expected rev-parse error details')
    assert(received_oid == nil, 'expected no object ID')
  end)
end

M.rev_parse_should_return_expected_oid_for_head_short_commit_and_branch = function()
  git_repo.with_repo(function(test_repo)
    local repo = git.get_repo(test_repo.cwd)
    test_repo:write_file('file.txt', { 'content' })
    test_repo:add('file.txt')
    test_repo:commit('Initial commit')

    local expected_oid = '1773588d46327a71b4e30591371d2c12dae9329c'
    local short_oid = expected_oid:sub(1, 7)
    local branch = 'review-branch'
    test_repo:branch(branch)

    assert(resolve(repo, 'HEAD') == expected_oid, 'expected HEAD to resolve to the commit')
    assert(resolve(repo, short_oid) == expected_oid, 'expected short commit ID to resolve to the commit')
    assert(resolve(repo, branch) == expected_oid, 'expected branch to resolve to the commit')
  end)
end

return M
