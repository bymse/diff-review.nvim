return {
  File_Should_PreserveContent_When_WrittenAndRead = function()
    local path = vim.fn.tempname()
    local passed, result = xpcall(function()
      assert(vim.fn.writefile({ "category harness" }, path) == 0)
      assert(table.concat(vim.fn.readfile(path), "\n") == "category harness")
    end, debug.traceback)

    pcall(vim.fn.delete, path)
    assert(passed, result)
  end,
}
