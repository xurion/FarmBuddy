-- Simple Unit tests

lu = require('luaunit/luaunit')

func = function (val)
  return val
end

function test_true_is_true()
  lu.assertEquals(true, true)
end

function test_two_numbers_add()
  lu.assertEquals(1 + 2, 3)
end

function test_that_numbers_do_not_add()
  lu.assertNotEquals(1 + 2, 4)
end

function test_function_data_type()
  lu.assertIsFunction(func)
end

function test_function_returns_value()
  lu.assertEquals(func('a'), 'a')
end

lu.LuaUnit:run()
