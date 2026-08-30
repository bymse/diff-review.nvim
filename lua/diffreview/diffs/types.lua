---@class GitDiff
---@field old_oid string
---@field new_oid string
---@field old_mode string
---@field new_mode string
---@field status string
---@field similarity_score string|nil
---@field current_path string
---@field old_path string|nil

---@class GitResult
---@field ok boolean
---@field error string|nil

---@class GitJob
---@field wait fun(self: GitJob)

local M = {}

return M
