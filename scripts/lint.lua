local result = vim
  .system({ 'lua-language-server', '--check=.', '--checklevel=Warning', '--check_format=pretty' }, {
    text = true,
    env = { VIMRUNTIME = vim.env.VIMRUNTIME },
  })
  :wait()

if result.stdout then
  io.stdout:write(result.stdout)
end
if result.stderr then
  io.stderr:write(result.stderr)
end

if result.code ~= 0 then
  os.exit(result.code)
end
