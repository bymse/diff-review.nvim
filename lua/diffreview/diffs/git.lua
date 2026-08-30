require('diffreview.diffs.types')

local parsers = require('diffreview.diffs.parsers')
local M = {}

---@class GitRepo
---@field private dir string|nil
local GitRepo = {}
GitRepo.__index = GitRepo

---@param cmd string[]
---@param cwd string|nil
---@param parse_output fun(raw_out: string): any
---@param receive_result fun(result: GitResult, output: any|nil)
---@return GitJob
local function run_parsed(cmd, cwd, parse_output, receive_result)
  ---@param result vim.SystemCompleted
  local on_exit = function(result)
    if result.code ~= 0 then
      receive_result({ ok = false, error = result.stderr })
      return
    end

    local success, output = pcall(parse_output, result.stdout)
    if success then
      receive_result({ ok = true }, output)
    else
      receive_result({ ok = false, error = tostring(output) })
    end
  end

  local process = vim.system(cmd, { cwd = cwd }, on_exit)
  return {
    wait = function()
      process:wait()
    end,
  }
end

---@param expression string
---@param receive_result fun(result: GitResult, oid: string|nil)
---@return GitJob
function GitRepo:rev_parse(expression, receive_result)
  local cmd = {
    'git',
    'rev-parse',
    '--verify',
    '--end-of-options',
    expression .. '^{commit}',
  }

  ---@param result vim.SystemCompleted
  local on_exit = function(result)
    if result.code == 0 then
      receive_result({ ok = true }, vim.trim(result.stdout))
    else
      receive_result({ ok = false, error = result.stderr })
    end
  end

  local process = vim.system(cmd, { text = true, cwd = self.dir }, on_exit)
  return {
    wait = function()
      process:wait()
    end,
  }
end

---@param from_commit_oid string|nil
---@param to_commit_oid string|nil
---@param receive_result fun(result: GitResult, diffs: GitDiff[]|nil)
---@return GitJob
function GitRepo:diff(from_commit_oid, to_commit_oid, receive_result)
  if from_commit_oid ~= nil and not from_commit_oid:match('^%x+$') then
    error('invalid from commit object ID: ' .. from_commit_oid)
  end
  if to_commit_oid ~= nil and not to_commit_oid:match('^%x+$') then
    error('invalid to commit object ID: ' .. to_commit_oid)
  end

  local cmd = { 'git', 'diff', '--raw', '-z', '-M', '-C' }
  if from_commit_oid ~= nil then
    table.insert(cmd, from_commit_oid)
  end
  if to_commit_oid ~= nil then
    table.insert(cmd, to_commit_oid)
  end
  table.insert(cmd, '--')

  return run_parsed(cmd, self.dir, parsers.parse_diff_output, receive_result)
end

---@param receive_result fun(result: GitResult, paths: string[]|nil)
---@return GitJob
function GitRepo:ls_files(receive_result)
  local cmd = { 'git', 'ls-files', '--others', '--exclude-standard', '-z' }
  return run_parsed(cmd, self.dir, parsers.parse_ls_files_output, receive_result)
end

---@param dir string|nil
---@return GitRepo
function M.get_repo(dir)
  return setmetatable({ dir = dir }, GitRepo)
end

return M
