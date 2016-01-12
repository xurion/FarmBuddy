-- FarmBuddy Unit tests

package.path = '../?.lua;./?.lua'

expose('an exposed test', function()

    describe('FarmBuddy', function()

        before_each(function ()

            _G._addon = {}

            -- windower = {
            -- register_event = function () end
            -- }

            require('FarmBuddy')

        end)

        it('should set the available _addon commands to be farmbuddy and fb', function()

            assert.are.same(_G._addon.commands, {'farmbuddy', 'fb'})
        end)
    end)
end)
