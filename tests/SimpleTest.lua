-- Simple Unit tests

describe("SimpleTest", function()

    local func, mod

    before_each(function()

        func = function(val)
            return val
        end

        mod = {
            func = function(val)
                return val
            end
        }
    end)

    it('should assert true equals true', function()

        assert.is_true(true)
    end)

    it('should assert that two numbers together equal the expected number', function()

        assert.is_equal(1 + 2, 3)
    end)

    it('should assert that two numbers toegther do not equal a number that is not the expected number', function()

        assert.is_not_equal(1 + 2, 4)
    end)

    it('should assert the returned value from a function is as expected', function()

        assert(func('a'), 'a')
    end)

    it('should be able to spy on a function', function()

        local func_spy = spy.on(mod, 'func')
        mod.func('b')
        assert.spy(func_spy).was.called_with('b')
    end)
end)
