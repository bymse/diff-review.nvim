local M = {}

M.added = 'A'
M.copied = 'C'
M.deleted = 'D'
M.modified = 'M'
M.renamed = 'R'
M.type_changed = 'T'
M.unmerged = 'U'

local valid_statuses = {
  [M.added] = true,
  [M.copied] = true,
  [M.deleted] = true,
  [M.modified] = true,
  [M.renamed] = true,
  [M.type_changed] = true,
  [M.unmerged] = true,
}

---@param status any
---@return boolean
function M.is_valid_status(status)
  return valid_statuses[status] == true
end

return M
