-- FarmBuddy Unit tests

package.path = '../?.lua;./?.lua'

local match = require("luassert.match")

expose('an exposed test', function()

    describe('FarmBuddy', function()

        local get_addon = function ()

            package.loaded['FarmBuddy'] = nil
            return require('FarmBuddy')
        end

        before_each(function()

            _G._addon = {}
            _G.windower = {

                register_event = function () end
            }
        end)

        it('should set the available _addon commands to be farmbuddy and fb', function()

            get_addon()
            assert.are.same(_G._addon.commands, { 'farmbuddy', 'fb' })
        end)

        it('should set the _addon name to FarmBuddy', function()

            get_addon()
            assert.is.equal(_G._addon.name, 'FarmBuddy')
        end)

        it('should set the _addon author as Xurion of Bismarck', function ()

            get_addon()
            assert.is.equal(_G._addon.author, 'Xurion of Bismarck')
        end)

        it('should set the _addon version', function ()

            get_addon()
            assert.is.truthy(_G._addon.version)
        end)

        it('should set the farm_data to an empty table', function ()

            local addon = get_addon()
            assert.is.same(addon.farm_data, {})
        end)

        describe('incoming text event', function ()

            it('should register the incoming text event to windower', function ()

                local register_event_listener_spy = spy.on(_G.windower, 'register_event')
                get_addon()

                assert.spy(register_event_listener_spy).was.called_with('incoming text', match._)
            end)

            it('should register the handle_incoming_message function as the callback', function()

                local register_event_listener_spy = spy.on(_G.windower, 'register_event')
                local addon = get_addon()

                assert.spy(register_event_listener_spy).was.called_with(match._, addon.handle_incoming_message)
            end)
        end)

        it('should register the addon command event to windower', function ()

            local register_event_listener_spy = spy.on(_G.windower, 'register_event')
            get_addon()

            assert.spy(register_event_listener_spy).was.called_with('addon command', match._)
        end)

        describe('handle_incoming_text()', function()

            it('should return false if the text argument is an empty string', function ()

                local addon = get_addon()
                assert.is.equal(addon.handle_incoming_message(''), false)
            end)

            it('should return false if the text argument is nil', function ()

                local addon = get_addon()
                assert.is.equal(addon.handle_incoming_message(), false)
            end)

            it('should store kill information when a kill confirmtion message is handled', function ()

                local addon = get_addon()
                addon.handle_incoming_message(_, 'Xurion defeats the Monster.')
                assert.is.same(addon.farm_data, {
                    Monster = {
                        kills = 1,
                        drops = {}
                    }
                })
            end)

            it('should increment the kill count of multiple kills of the same monster', function ()

                local addon = get_addon()
                addon.handle_incoming_message(_, 'Xurion defeats the Monster.')
                addon.handle_incoming_message(_, 'Xurion defeats the Monster.')
                assert.is.same(addon.farm_data, {
                    Monster = {
                        kills = 2,
                        drops = {}
                    }
                })
            end)

            it('should store different monster type kills', function ()

                local addon = get_addon()
                addon.handle_incoming_message(_, 'Xurion defeats the MonsterA.')
                addon.handle_incoming_message(_, 'Xurion defeats the MonsterB.')
                assert.is.same(addon.farm_data, {
                    MonsterA = {
                        kills = 1,
                        drops = {}
                    },
                    MonsterB = {
                        kills = 1,
                        drops = {}
                    }
                })
            end)

            it('should store drop information when a drop message is handled', function ()

                local addon = get_addon()
                addon.handle_incoming_message(_, 'Xurion defeats the Monster.')
                addon.handle_incoming_message(_, 'You find a Crystal on the Monster.')
                assert.is.same(addon.farm_data, {
                    Monster = {
                        kills = 1,
                        drops = {
                            Crystal = 1
                        }
                    }
                })
            end)
        end)
    end)
end)

function print_r(t)
    local print_r_cache = {}
    local function sub_print_r(t, indent)
        if (print_r_cache[tostring(t)]) then
            print(indent .. "*" .. tostring(t))
        else
            print_r_cache[tostring(t)] = true
            if (type(t) == "table") then
                for pos, val in pairs(t) do
                    if (type(val) == "table") then
                        print(indent .. "[" .. pos .. "] => " .. tostring(t) .. " {")
                        sub_print_r(val, indent .. string.rep(" ", string.len(pos) + 8))
                        print(indent .. string.rep(" ", string.len(pos) + 6) .. "}")
                    elseif (type(val) == "string") then
                        print(indent .. "[" .. pos .. '] => "' .. val .. '"')
                    else
                        print(indent .. "[" .. pos .. "] => " .. tostring(val))
                    end
                end
            else
                print(indent .. tostring(t))
            end
        end
    end

    if (type(t) == "table") then
        print(tostring(t) .. " {")
        sub_print_r(t, "  ")
        print("}")
    else
        sub_print_r(t, "  ")
    end
    print()
end