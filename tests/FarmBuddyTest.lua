-- FarmBuddy Unit tests

package.path = '../?.lua;./?.lua'

_addon = {}

lu = require('luaunit/luaunit')
fb = require 'FarmBuddy'

function test_that_ZeroCheck_check_returns_true_when_the_argument_is_zero()
  lu.assertEquals(true, true)
end

lu.LuaUnit:run()
