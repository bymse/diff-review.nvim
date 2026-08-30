return {
  Buffer_Should_ContainEditedText_When_NormalCommandRuns = function()
    local buffer = vim.api.nvim_create_buf(false, true)
    local passed, result = xpcall(function()
      vim.api.nvim_set_current_buf(buffer)
      vim.api.nvim_buf_set_lines(buffer, 0, -1, false, { 'category' })
      vim.cmd('normal! A harness')
      assert(vim.api.nvim_buf_get_lines(buffer, 0, -1, false)[1] == 'category harness')
    end, debug.traceback)

    pcall(vim.api.nvim_buf_delete, buffer, { force = true })
    assert(passed, result)
  end,
}
