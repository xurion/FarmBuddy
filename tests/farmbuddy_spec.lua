package.path = '../?.lua;./?.lua'

local match = require("luassert.match")

describe('FarmBuddy', function ()

    local get_addon = function ()

        package.loaded['FarmBuddy'] = nil
        return require('FarmBuddy')
    end

    local sent_chats

    before_each(function ()

        sent_chats = {}
        _G._addon = {}
        _G.windower = {

            register_event = function () end,
            add_to_chat = function (_, message)

                table.insert(sent_chats, message)
            end
        }
    end)

    it('sets the available _addon commands to be farmbuddy and fb', function ()

        get_addon()
        assert.are.same(_G._addon.commands, {'farmbuddy', 'fb'})
    end)

    it('sets the _addon name to FarmBuddy', function ()

        get_addon()
        assert.is.equal(_G._addon.name, 'FarmBuddy')
    end)

    it('sets the _addon author as Dean James (Xurion of Bismarck)', function ()

        get_addon()
        assert.is.equal(_G._addon.author, 'Dean James (Xurion of Bismarck)')
    end)

    it('sets the _addon version', function ()

        get_addon()
        assert.is.truthy(_G._addon.version)
    end)

    it('sets the farm_data to an empty table', function ()

        local addon = get_addon()
        assert.is.same(addon.farm_data, {})
    end)

    it('sets the status to running', function ()

        local addon = get_addon()
        assert.is.equal(addon.status, 'running')
    end)

    describe('send_text_to_game()', function ()

        it('executes the windower add_to_chat function with mode 7 and the message argument', function ()

            local add_to_chat_spy = spy.on(_G.windower, 'add_to_chat')
            local addon = get_addon()
            addon.send_text_to_game('text for game')

            assert.spy(add_to_chat_spy).was.called_with(7, 'text for game')
        end)
    end)

    describe('incoming text event', function ()

        it('registers the incoming text event to windower', function ()

            local register_event_listener_spy = spy.on(_G.windower, 'register_event')
            get_addon()

            assert.spy(register_event_listener_spy).was.called_with('incoming text', match._)
        end)

        it('registers the handle_incoming_text function as the callback', function ()

            local register_event_listener_spy = spy.on(_G.windower, 'register_event')
            local addon = get_addon()

            assert.spy(register_event_listener_spy).was.called_with(match._, addon.handle_incoming_text)
        end)
    end)

    describe('addon command event', function ()

        it('registers the addon command event to windower', function ()

            local register_event_listener_spy = spy.on(_G.windower, 'register_event')
            get_addon()

            assert.spy(register_event_listener_spy).was.called_with('addon command', match._)
        end)

        it('registers the handle_addon_command function as the callback', function ()

            local register_event_listener_spy = spy.on(_G.windower, 'register_event')
            local addon = get_addon()

            assert.spy(register_event_listener_spy).was.called_with(match._, addon.handle_addon_command)
        end)
    end)

    describe('handle_incoming_text()', function ()

        it('returns nil if the text argument is an empty string', function ()

            local addon = get_addon()
            assert.is.equal(addon.handle_incoming_text(_, ''), nil)
        end)

        it('returns nil if the addon status is paused', function ()

            local addon = get_addon()
            addon.pause()
            assert.is.equal(addon.handle_incoming_text(_, 'something'), nil)
        end)

        it('returns true if the text matches a kill message', function ()

            local addon = get_addon()
            assert.is.equal(addon.handle_incoming_text(_, 'Xurion defeats the mob.'), true)
        end)

        it('returns true if the text matches an item found message', function ()

            local addon = get_addon()
            assert.is.equal(addon.handle_incoming_text(_, 'You find an thing on the mob.'), true)
        end)

        it('returns false if the text does not match an item found or a kill message', function ()

            local addon = get_addon()
            assert.is.equal(addon.handle_incoming_text(_, 'some other message'), false)
        end)

        it('stores kill information when a kill confirmtion message is handled', function ()

            local addon = get_addon()
            addon.handle_incoming_text(_, 'Xurion defeats the Monster.')
            assert.is.same(addon.farm_data, {
                [1] = {
                    name = 'Monster',
                    kills = 1,
                    drops = {}
                }
            })
        end)

        it('increments the kill count of multiple kills of the same monster', function ()

            local addon = get_addon()
            addon.handle_incoming_text(_, 'Xurion defeats the Monster.')
            addon.handle_incoming_text(_, 'Xurion defeats the Monster.')
            assert.is.same(addon.farm_data, {
                [1] = {
                    name = 'Monster',
                    kills = 2,
                    drops = {}
                }
            })
        end)

        it('stores different monster type kills', function ()

            local addon = get_addon()
            addon.handle_incoming_text(_, 'Xurion defeats the MonsterA.')
            addon.handle_incoming_text(_, 'Xurion defeats the MonsterB.')
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

        it('stores drop information when a drop message is handled', function ()

            local addon = get_addon()
            addon.handle_incoming_text(_, 'Xurion defeats the Monster.')
            addon.handle_incoming_text(_, 'You find a Crystal on the Monster.')
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

        it('resets farm_data when the command argument is reset', function ()

            local addon = get_addon()
            addon.farm_data = {'mock data'}

            addon.handle_addon_command('reset')

            assert.is.same(addon.farm_data, {})
        end)

        it('informs the player if there is nothing to report when the command argument is report', function ()

            local addon = get_addon()
            addon.farm_data = {}
            local send_text_to_game_spy = spy.on(addon, 'send_text_to_game')

            addon.handle_addon_command('report')

            assert.spy(send_text_to_game_spy).was.called_with('No data to report')
        end)

        it('reports a kill when the command argument is report', function ()

            local addon = get_addon()
            addon.farm_data = {
                [1] = {
                    name = 'Monster',
                    kills = 1,
                    drops = {}
                }
            }
            local send_text_to_game_spy = spy.on(addon, 'send_text_to_game')

            addon.handle_addon_command('report')

            assert.spy(send_text_to_game_spy).was.called_with('Monster: 1 kill')
        end)

        it('reports multiple kills when the command argument is report', function ()

            local addon = get_addon()
            addon.farm_data = {
                [1] = {
                    name = 'Monster',
                    kills = 2,
                    drops = {}
                }
            }
            local send_text_to_game_spy = spy.on(addon, 'send_text_to_game')

            addon.handle_addon_command('report')

            assert.spy(send_text_to_game_spy).was.called_with('Monster: 2 kills')
        end)

        it('reports multiple numbers of kills when the command argument is report', function ()

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
            local send_text_to_game_spy = spy.on(addon, 'send_text_to_game')

            addon.handle_addon_command('report')

            assert.spy(send_text_to_game_spy).was.called_with('MonsterA: 2 kills')
            assert.spy(send_text_to_game_spy).was.called_with('MonsterB: 1 kill')
        end)

        it('reports numbers of drops and drop rate percentage when the command argument is report', function ()

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
            local send_text_to_game_spy = spy.on(addon, 'send_text_to_game')

            addon.handle_addon_command('report')

            assert.spy(send_text_to_game_spy).was.called_with(' > Crystal: 2/3 (66.7%)')
            assert.spy(send_text_to_game_spy).was.called_with(' > Crystal: 1/2 (50.0%)')
        end)

        it('provides kill and drop data in a readable order when the command argument is report', function ()

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

            addon.handle_addon_command('report')

            assert.is.equal(sent_chats[1], 'MonsterA: 3 kills')
            assert.is.equal(sent_chats[2], ' > Crystal: 2/3 (66.7%)')
            assert.is.equal(sent_chats[3], 'MonsterB: 2 kills')
            assert.is.equal(sent_chats[4], ' > Crystal: 1/2 (50.0%)')
        end)

        it('executes the pause function if the command argument is pause', function ()

            local addon = get_addon()
            local pause_spy = spy.on(addon, 'pause')

            addon.handle_addon_command('pause')

            assert.spy(pause_spy).was.called(1)
        end)

        it('executes the resume function if the command argument is resume', function ()

            local addon = get_addon()
            local resume_spy = spy.on(addon, 'resume')

            addon.handle_addon_command('resume')

            assert.spy(resume_spy).was.called(1)
        end)

        it('provides the status if the command argument is status', function ()

            local addon = get_addon()
            local send_text_to_game_spy = spy.on(addon, 'send_text_to_game')

            addon.handle_addon_command('status')

            assert.spy(send_text_to_game_spy).was.called_with('running')
        end)
    end)

    describe('pause()', function ()

        it('sets the status to paused', function ()

            local addon = get_addon()
            addon.pause()

            assert.is.equal(addon.status, 'paused')
        end)

        it('does not track kills after paused', function ()

            local addon = get_addon()
            addon.pause()
            addon.handle_incoming_text(_, 'Xurion defeats the Monster.')
            addon.handle_incoming_text(_, 'You find a Crystal on the Monster.')

            assert.is.same(addon.farm_data, {})
        end)
    end)

    describe('resume()', function ()

        it('sets the status to running', function ()

            local addon = get_addon()
            addon.status = 'mock'
            addon.resume()

            assert.is.equal(addon.status, 'running')
        end)

        it('continues to track kills after resuming', function ()

            local addon = get_addon()
            addon.status = 'paused'
            addon.resume()
            addon.handle_incoming_text(_, 'Xurion defeats the Monster.')

            assert.is.same(addon.farm_data, {
                [1] = {
                    name = 'Monster',
                    kills = 1,
                    drops = {}
                }
            })
        end)
    end)
end)
