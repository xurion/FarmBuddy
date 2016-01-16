-- FarmBuddy Unit tests

package.path = '../?.lua;./?.lua'

local match = require("luassert.match")

expose('an exposed test', function ()

    describe('FarmBuddy', function ()

        local get_addon = function ()

            package.loaded['FarmBuddy'] = nil
            return require('FarmBuddy')
        end

        local sent_commands

        before_each(function ()

            sent_commands = {}
            _G._addon = {}
            _G.windower = {

                register_event = function () end,
                send_command = function (command)

                    table.insert(sent_commands, command)
                end
            }
        end)

        it('should set the available _addon commands to be farmbuddy and fb', function ()

            get_addon()
            assert.are.same(_G._addon.commands, {'farmbuddy', 'fb'})
        end)

        it('should set the _addon name to FarmBuddy', function ()

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

        it('should set the status to running', function ()

            local addon = get_addon()
            assert.is.equal(addon.status, 'running')
        end)

        describe('incoming text event', function ()

            it('should register the incoming text event to windower', function ()

                local register_event_listener_spy = spy.on(_G.windower, 'register_event')
                get_addon()

                assert.spy(register_event_listener_spy).was.called_with('incoming text', match._)
            end)

            it('should register the handle_incoming_message function as the callback', function ()

                local register_event_listener_spy = spy.on(_G.windower, 'register_event')
                local addon = get_addon()

                assert.spy(register_event_listener_spy).was.called_with(match._, addon.handle_incoming_message)
            end)
        end)

        describe('addon command event', function ()

            it('should register the addon command event to windower', function ()

                local register_event_listener_spy = spy.on(_G.windower, 'register_event')
                get_addon()

                assert.spy(register_event_listener_spy).was.called_with('addon command', match._)
            end)

            it('should register the handle_addon_command function as the callback', function ()

                local register_event_listener_spy = spy.on(_G.windower, 'register_event')
                local addon = get_addon()

                assert.spy(register_event_listener_spy).was.called_with(match._, addon.handle_addon_command)
            end)
        end)

        describe('handle_incoming_text()', function ()

            it('should return false if the text argument is an empty string', function ()

                local addon = get_addon()
                assert.is.equal(addon.handle_incoming_message(_, ''), false)
            end)

            it('should store kill information when a kill confirmtion message is handled', function ()

                local addon = get_addon()
                addon.handle_incoming_message(_, 'Xurion defeats the Monster.')
                assert.is.same(addon.farm_data, {
                    [1] = {
                        name = 'Monster',
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
                    [1] = {
                        name = 'Monster',
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
                    [1] = {
                        name = 'MonsterA',
                        kills = 1,
                        drops = {}
                    },
                    [2] = {
                        name = 'MonsterB',
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
                    [1] = {
                        name = 'Monster',
                        kills = 1,
                        drops = {
                            Crystal = 1
                        }
                    }
                })
            end)
        end)

        describe('handle_addon_command()', function ()

            it('should reset farm_data when the command argument is reset', function ()

                local addon = get_addon()
                addon.farm_data = {'mock data'}

                addon.handle_addon_command(_, 'reset')

                assert.is.same(addon.farm_data, {})
            end)

            it('should report a kill when the command argument is report', function ()

                local addon = get_addon()
                addon.farm_data = {
                    [1] = {
                        name = 'Monster',
                        kills = 1,
                        drops = {}
                    }
                }
                local windower_send_command_spy = spy.on(_G.windower, 'send_command')

                addon.handle_addon_command(_, 'report')

                assert.spy(windower_send_command_spy).was.called_with('Monster: 1 kill')
            end)

            it('should report the number of kills when the command argument is report', function ()

                local addon = get_addon()
                addon.farm_data = {
                    [1] = {
                        name = 'Monster',
                        kills = 2,
                        drops = {}
                    }
                }
                local windower_send_command_spy = spy.on(_G.windower, 'send_command')

                addon.handle_addon_command(_, 'report')

                assert.spy(windower_send_command_spy).was.called_with('Monster: 2 kills')
            end)

            it('should report multiple numbers of kills when the command argument is report', function ()

                local addon = get_addon()
                addon.farm_data = {
                    [1] = {
                        name = 'MonsterA',
                        kills = 2,
                        drops = {}
                    },
                    [2] = {
                        name = 'MonsterB',
                        kills = 1,
                        drops = {}
                    }
                }
                local windower_send_command_spy = spy.on(_G.windower, 'send_command')

                addon.handle_addon_command(_, 'report')

                assert.spy(windower_send_command_spy).was.called_with('MonsterA: 2 kills')
                assert.spy(windower_send_command_spy).was.called_with('MonsterB: 1 kill')
            end)

            it('should report numbers of drops and drop rate percentage when the command argument is report', function ()

                local addon = get_addon()
                addon.farm_data = {
                    [1] = {
                        name = 'MonsterA',
                        kills = 3,
                        drops = {
                            Crystal = 2
                        }
                    },
                    [2] = {
                        name = 'MonsterB',
                        kills = 2,
                        drops = {
                            Crystal = 1
                        }
                    }
                }
                local windower_send_command_spy = spy.on(_G.windower, 'send_command')

                addon.handle_addon_command(_, 'report')

                assert.spy(windower_send_command_spy).was.called_with('Crystal: 2/3 (67%)')
                assert.spy(windower_send_command_spy).was.called_with('Crystal: 1/2 (50%)')
            end)

            it('should provide kill and drop data in a readable order when the command argument is report', function ()

                local addon = get_addon()
                addon.farm_data = {
                    [1] = {
                        name = 'MonsterA',
                        kills = 3,
                        drops = {
                            Crystal = 2
                        }
                    },
                    [2] = {
                        name = 'MonsterB',
                        kills = 2,
                        drops = {
                            Crystal = 1
                        }
                    }
                }

                addon.handle_addon_command(_, 'report')

                assert.is.equal(sent_commands[1], 'MonsterA: 3 kills')
                assert.is.equal(sent_commands[2], 'Crystal: 2/3 (67%)')
                assert.is.equal(sent_commands[3], 'MonsterB: 2 kills')
                assert.is.equal(sent_commands[4], 'Crystal: 1/2 (50%)')
            end)
        end)

        describe('pause()', function ()

            it('should set the status to paused', function ()

                local addon = get_addon()
                addon.pause()

                assert.is.equal(addon.status, 'paused')
            end)

            it('should not track kills after paused', function ()

                local addon = get_addon()
                addon.pause()
                addon.handle_incoming_message(_, 'Xurion defeats the Monster.')
                addon.handle_incoming_message(_, 'You find a Crystal on the Monster.')

                assert.is.same(addon.farm_data, {})
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
