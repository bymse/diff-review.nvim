return {
  Hello_Should_ReturnHelloWorld_When_Called = function()
    assert(require('diffreview').hello() == 'Hello World')
  end,
}
