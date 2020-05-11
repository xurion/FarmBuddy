--[[
Copyright © 2020, Dean James (Xurion of Bismarck)
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of FarmBuddy nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL Dean James (Xurion of Bismarck) BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]

_addon.commands = {'farmbuddy', 'fb'}
_addon.name = 'FarmBuddy'
_addon.author = 'Dean James (Xurion of Bismarck)'
_addon.version = '1.0.0'

local FarmBuddy = {
    farm_data = {},
    status = 'running'
}

function round(num, idp)
    local mult = 10^(idp or 0)
    return math.floor(num * mult + 0.5) / mult
end

--TODO can be replaced with a an easier helper method for less code
function getExistingDataKey(mob_name)
    for key, existing_kill_data in pairs(FarmBuddy.farm_data) do
        if existing_kill_data.name == mob_name then
            return key
        end
    end

    return false
end

FarmBuddy.handle_incoming_text = function (_, text)
    if text == '' or FarmBuddy.status == 'paused' then return end

    local kill_confirmation_regex = 'Xurion defeats the (.*)%.'
    local killed_mob_name = string.match(text, kill_confirmation_regex)

    if killed_mob_name then
        local key = getExistingDataKey(killed_mob_name)
        if key == false then
            table.insert(FarmBuddy.farm_data, {
                name = killed_mob_name,
                kills = 1,
                drops = {}
            })
        else
            FarmBuddy.farm_data[key].kills = FarmBuddy.farm_data[key].kills + 1
        end

        return true
    end

    local drop_confirmation_regex = 'You find an? (.*) on the (.*)%.'
    local drop_name, drop_mob_name = string.match(text, drop_confirmation_regex)
    if drop_name and drop_mob_name then
        local key = getExistingDataKey(drop_mob_name)
        if key == false then
            FarmBuddy.farm_data[key].drops[drop_name] = 0
        else
            if FarmBuddy.farm_data[key].drops[drop_name] then
                FarmBuddy.farm_data[key].drops[drop_name] = FarmBuddy.farm_data[key].drops[drop_name] + 1
            else
                FarmBuddy.farm_data[key].drops[drop_name] = 1
            end
        end
        return true
    end

    return false
end

--TODO implement commands table pattern from EmpyPopTracker
FarmBuddy.handle_addon_command = function(command)
    local action, kill_plural

    if command ~= nil then
        action = command:lower()
    end

    if action == 'report' then
        if #FarmBuddy.farm_data == 0 then
            FarmBuddy.send_text_to_game('No data to report')
            return
        end

        for _, monster_data in ipairs(FarmBuddy.farm_data) do
            --TOD can be a one-liner
            if monster_data.kills > 1 then
                kill_plural = 's'
            else
                kill_plural = ''
            end
            FarmBuddy.send_text_to_game(monster_data.name .. ': ' .. monster_data.kills .. ' kill' .. kill_plural)
            for drop_name, drop_amount in pairs(monster_data.drops) do
                FarmBuddy.send_text_to_game(' > ' .. drop_name .. ': ' .. drop_amount .. '/' .. monster_data.kills .. ' (' .. round(drop_amount / monster_data.kills * 100, 1) .. '%)')
            end
        end
    end

    if action == 'reset' then
        FarmBuddy.farm_data = {}
    end

    if action == 'pause' then
        FarmBuddy.pause()
    end

    if action == 'resume' then
        FarmBuddy.resume()
    end

    if action == 'status' then
        FarmBuddy.send_text_to_game(FarmBuddy.status)
    end
end

FarmBuddy.pause = function ()
    FarmBuddy.status = 'paused'
end

FarmBuddy.resume = function ()
    FarmBuddy.status = 'running'
end

FarmBuddy.send_text_to_game = function (text)
    windower.add_to_chat(7, text)
end

windower.register_event('incoming text', FarmBuddy.handle_incoming_text)
windower.register_event('addon command', FarmBuddy.handle_addon_command)

return FarmBuddy
