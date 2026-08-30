return {
  Plugin_Should_DisplayHelloWorld_When_Loaded = function()
    assert(vim.g.loaded_diffreview == true)
    assert(package.loaded.diffreview ~= nil)

    local messages = vim.api.nvim_exec2('messages', { output = true }).output
    assert(messages:find('Hello World', 1, true) ~= nil)
  end,
}
