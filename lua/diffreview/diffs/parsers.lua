local file_mode = require('diffreview.diffs.file_mode')
local diff_status = require('diffreview.diffs.status')
local M = {}
local colon_byte = string.byte(':')

---@class ParsedDiff
---@field old_oid string
---@field new_oid string
---@field old_mode string
---@field new_mode string
---@field status string
---@field similarity_score string|nil
---@field current_path string
---@field old_path string|nil

---@param raw_meta string
---@return ParsedDiff
local function parse_diff_meta(raw_meta)
  local parts = {}
  for word in raw_meta:gmatch('%S+') do
    table.insert(parts, word)
  end

  if #parts ~= 5 then
    error('invalid git diff metadata: ' .. raw_meta)
  end

  local status = parts[5]:sub(1, 1)
  local similarity_score = nil
  if #parts[5] > 1 then
    similarity_score = parts[5]:sub(2)
  end

  return {
    old_mode = parts[1],
    new_mode = parts[2],
    old_oid = parts[3],
    new_oid = parts[4],
    status = status,
    similarity_score = similarity_score
  }
end

---@param diff ParsedDiff
local function validate_diff(diff)
  if diff.old_oid == nil then
    error('missing required parsed diff field: old_oid')
  end

  if diff.new_oid == nil then
    error('missing required parsed diff field: new_oid')
  end

  if diff.old_mode == nil then
    error('missing required parsed diff field: old_mode')
  end

  if diff.new_mode == nil then
    error('missing required parsed diff field: new_mode')
  end

  if diff.status == nil then
    error('missing required parsed diff field: status')
  end

  if diff.current_path == nil or diff.current_path == '' then
    error('missing required parsed diff field: current_path')
  end

  if not file_mode.is_valid_mode(diff.old_mode) then
    error('invalid old file mode: ' .. tostring(diff.old_mode))
  end

  if not file_mode.is_valid_mode(diff.new_mode) then
    error('invalid new file mode: ' .. tostring(diff.new_mode))
  end

  if not diff.old_oid:match('^%x+$') then
    error('invalid old object ID: ' .. diff.old_oid)
  end

  if not diff.new_oid:match('^%x+$') then
    error('invalid new object ID: ' .. diff.new_oid)
  end

  if not diff_status.is_valid_status(diff.status) then
    error('unsupported diff status: ' .. diff.status)
  end

  if (diff.status == diff_status.copied or diff.status == diff_status.renamed)
      and (diff.old_path == nil or diff.old_path == '') then
    error('missing required parsed diff field: old_path')
  end
end

---@return ParsedDiff[]
---@param raw_out string
function M.parse_diff_output(raw_out)
  if raw_out == '' then
    return {}
  end

  if raw_out:byte(1) ~= colon_byte then
    error('git diff output expected to start with ":"')
  end

  if raw_out:byte(#raw_out) ~= 0 then
    error('git diff output expected to end with NUL')
  end

  local section_start = 2
  local state = 'meta'
  local diffs = {}

  ---@type ParsedDiff|nil
  local current_diff = nil
  for i = section_start, #raw_out do
    local byte = raw_out:byte(i)

    if byte ~= 0 then
      goto continue
    end


    if state == 'meta' then
      current_diff = parse_diff_meta(raw_out:sub(section_start, i - 1))
      section_start = i + 1
      state = 'path'
    elseif current_diff ~= nil and state == 'path' then
      local expect_two_paths = current_diff.status == diff_status.copied or current_diff.status == diff_status.renamed
      local path = raw_out:sub(section_start, i - 1)
      if expect_two_paths then
        current_diff.old_path = path
        section_start = i + 1
        state = 'second_path'
      else
        current_diff.current_path = path
        section_start = i + 2
        state = 'meta'
      end
    elseif current_diff ~= nil and state == 'second_path' then
      current_diff.current_path = raw_out:sub(section_start, i - 1)
      section_start = i + 2
      state = 'meta'
    end

    if state == 'meta' and current_diff ~= nil then
      validate_diff(current_diff)
      table.insert(diffs, current_diff)
      current_diff = nil

      if i < #raw_out and raw_out:byte(i + 1) ~= colon_byte then
        error('git diff record expected to start with ":"')
      end
    end

    ::continue::
  end

  if current_diff ~= nil then
    validate_diff(current_diff)
  end

  return diffs
end

return M
