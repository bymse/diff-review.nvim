local M = {}

local valid_modes = {
  ['000000'] = true,
  ['100644'] = true,
  ['100755'] = true,
  ['120000'] = true,
  ['160000'] = true,
}

---@param mode any
---@return boolean
function M.is_valid_mode(mode)
  return valid_modes[mode] == true
end

return M
