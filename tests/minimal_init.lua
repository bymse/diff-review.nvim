local root = vim.fn.fnamemodify(vim.fn.resolve(vim.fn.expand('<sfile>:p')), ':h:h')

vim.opt.runtimepath = { root, vim.env.VIMRUNTIME }
vim.opt.packpath = {}
package.path = table.concat({
  root .. '/tests/?.lua',
  root .. '/tests/?/init.lua',
  package.path,
}, ';')

local plugin_files = vim.fn.globpath(root, 'plugin/**/*.lua', false, true)
vim.list_extend(plugin_files, vim.fn.globpath(root, 'plugin/**/*.vim', false, true))
table.sort(plugin_files)

for _, path in ipairs(plugin_files) do
  vim.cmd('source ' .. vim.fn.fnameescape(path))
end
