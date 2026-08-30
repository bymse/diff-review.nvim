local parsers = require('diffreview.diffs.parsers')
local M = {}

local function assert_parse_fails(raw_out)
  local success = pcall(parsers.parse_diff_output, raw_out)
  assert(not success, 'expected malformed diff output to raise an error')
end

local function assert_ls_files_parse_fails(raw_out)
  local success = pcall(parsers.parse_ls_files_output, raw_out)
  assert(not success, 'expected malformed ls-files output to raise an error')
end

M.parse_diff_output_should_return_empty_list_for_empty_output = function()
  local diffs = parsers.parse_diff_output('')
  assert(#diffs == 0, 'expected no diffs')
end

M.parse_diff_output_should_parse_single_file = function()
  local diff = parsers.parse_diff_output(':000000 100644 0000000 1da2a87 A\0lua/diffreview/diffs/git.lua\0')[1]
  assert(diff.new_mode == '100644', 'expected new_mode to be 100644')
  assert(diff.old_mode == '000000', 'expected old_mode to be 000000')
  assert(diff.old_oid == '0000000', 'expected old_oid to be 0000000')
  assert(diff.new_oid == '1da2a87', 'expected new_oid to be 1da2a87')
  assert(diff.current_path == 'lua/diffreview/diffs/git.lua', 'expected current_path to be lua/diffreview/diffs/git.lua')
  assert(diff.old_path == nil, 'expected old_path to be nil')
  assert(diff.status == 'A', 'expected status to be A')
end

M.parse_diff_output_should_parse_rename = function()
  local diff = parsers.parse_diff_output(':100644 100644 095d886 095d886 R100\0ARCH.md\0TEMP_ARCH.md\0')[1]
  assert(diff.new_mode == '100644', 'expected new_mode to be 100644')
  assert(diff.old_mode == '100644', 'expected old_mode to be 100644')
  assert(diff.old_oid == '095d886', 'expected old_oid to be 095d886')
  assert(diff.new_oid == '095d886', 'expected new_oid to be 095d886')
  assert(diff.current_path == 'TEMP_ARCH.md', 'expected current_path to be TEMP_ARCH.md')
  assert(diff.old_path == 'ARCH.md', 'expected old_path to be ARCH.md')
  assert(diff.status == 'R', 'expected status to be R')
  assert(diff.similarity_score == '100', 'expected similarity_score to be 100')
end

M.parse_diff_output_should_parse_path_containing_colon = function()
  local diffs = parsers.parse_diff_output(':100644 100644 381ca90 0000000 M\0lua/diffreview:parser.lua\0')
  assert(#diffs == 1, 'expected one diff')

  local diff = diffs[1]
  assert(diff.current_path == 'lua/diffreview:parser.lua', 'expected current_path to preserve the colon')
end

M.parse_diff_output_should_parse_multiple_files = function()
  local diffs = parsers.parse_diff_output(
  ':100644 100644 095d886 095d886 R100\0ARCH.md\0TEMP_ARCH.md\0:100644 100644 381ca90 0000000 M\0justfile\0:100644 100644 e69de29 0000000 M\0lua/diffreview/diffs/git.lua\0')
  assert(#diffs == 3, 'expected three diffs')

  local first_diff = diffs[1]
  assert(first_diff.new_mode == '100644', 'expected new_mode to be 100644')
  assert(first_diff.old_mode == '100644', 'expected old_mode to be 100644')
  assert(first_diff.old_oid == '095d886', 'expected old_oid to be 095d886')
  assert(first_diff.new_oid == '095d886', 'expected new_oid to be 095d886')
  assert(first_diff.current_path == 'TEMP_ARCH.md', 'expected current_path to be TEMP_ARCH.md')
  assert(first_diff.old_path == 'ARCH.md', 'expected old_path to be ARCH.md')
  assert(first_diff.status == 'R', 'expected status to be R')
  assert(first_diff.similarity_score == '100', 'expected similarity_score to be 100')

  local second_diff = diffs[2]
  assert(second_diff.new_mode == '100644', 'expected new_mode to be 100644')
  assert(second_diff.old_mode == '100644', 'expected old_mode to be 100644')
  assert(second_diff.old_oid == '381ca90', 'expected old_oid to be 381ca90')
  assert(second_diff.new_oid == '0000000', 'expected new_oid to be 0000000')
  assert(second_diff.current_path == 'justfile', 'expected current_path to be justfile')
  assert(second_diff.old_path == nil, 'expected old_path to be nil')
  assert(second_diff.status == 'M', 'expected status to be M')

  local third_diff = diffs[3]
  assert(third_diff.new_mode == '100644', 'expected new_mode to be 100644')
  assert(third_diff.old_mode == '100644', 'expected old_mode to be 100644')
  assert(third_diff.old_oid == 'e69de29', 'expected old_oid to be e69de29')
  assert(third_diff.new_oid == '0000000', 'expected new_oid to be 0000000')
  assert(third_diff.current_path == 'lua/diffreview/diffs/git.lua', 'expected current_path to be lua/diffreview/diffs/git.lua')
  assert(third_diff.old_path == nil, 'expected old_path to be nil')
  assert(third_diff.status == 'M', 'expected status to be M')
end

M.parse_diff_output_should_error_for_truncated_initial_metadata = function()
  assert_parse_fails(':100644 100644 abcdef0 1234567 M')
end

M.parse_diff_output_should_error_for_truncated_trailing_metadata = function()
  assert_parse_fails(
    ':100644 100644 abcdef0 1234567 M\0one.lua\0:000000 100644 0000000 7654321 A'
  )
end

M.parse_diff_output_should_error_for_trailing_garbage = function()
  assert_parse_fails(':100644 100644 abcdef0 1234567 M\0one.lua\0garbage')
end

M.parse_diff_output_should_error_for_empty_path = function()
  assert_parse_fails(':100644 100644 abcdef0 1234567 M\0\0')
end

M.parse_diff_output_should_error_for_unsupported_status = function()
  assert_parse_fails(':100644 100644 abcdef0 1234567 X\0one.lua\0')
end

M.parse_diff_output_should_error_for_malformed_object_id = function()
  assert_parse_fails(':100644 100644 invalid 1234567 M\0one.lua\0')
end

M.parse_ls_files_output_should_return_empty_list_for_empty_output = function()
  local paths = parsers.parse_ls_files_output('')
  assert(#paths == 0, 'expected no paths')
end

M.parse_ls_files_output_should_parse_single_path = function()
  local paths = parsers.parse_ls_files_output('lua/diffreview/diffs/parsers.lua\0')
  assert(#paths == 1, 'expected one path')
  assert(paths[1] == 'lua/diffreview/diffs/parsers.lua', 'expected parsed path')
end

M.parse_ls_files_output_should_parse_multiple_paths = function()
  local paths = parsers.parse_ls_files_output('one.lua\0directory/two.lua\0path with spaces\nthree.lua\0')
  assert(#paths == 3, 'expected three paths')
  assert(paths[1] == 'one.lua', 'expected first path')
  assert(paths[2] == 'directory/two.lua', 'expected second path')
  assert(paths[3] == 'path with spaces\nthree.lua', 'expected third path to preserve whitespace')
end

M.parse_ls_files_output_should_error_when_output_does_not_end_with_nul = function()
  assert_ls_files_parse_fails('one.lua')
end

M.parse_ls_files_output_should_error_when_output_contains_empty_path = function()
  assert_ls_files_parse_fails('one.lua\0\0')
end

return M
