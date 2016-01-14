_addon.commands = {'farmbuddy', 'fb'}
_addon.name = 'FarmBuddy'
_addon.author = 'Xurion of Bismarck'
_addon.version = '1.0.0'

function round(num, idp)
    local mult = 10^(idp or 0)
    return math.floor(num * mult + 0.5) / mult
end

local FarmBuddy = {}

FarmBuddy.farm_data = {}

FarmBuddy.handle_incoming_message = function (_, text)

    if text == '' or text == nil then return false end

    local kill_confirmation_regex = 'Xurion defeats the (.*)%.'
    local killed_mob_name = string.match(text, kill_confirmation_regex)

    if killed_mob_name then
        if FarmBuddy.farm_data[killed_mob_name] == nil then
            FarmBuddy.farm_data[killed_mob_name] = {

                kills = 0,
                drops = {}
            }
        end

        FarmBuddy.farm_data[killed_mob_name].kills = FarmBuddy.farm_data[killed_mob_name].kills + 1
    end

    local drop_confirmation_regex = 'You find an? (.*) on the (.*)%.'
    local drop_name, drop_mob_name = string.match(text, drop_confirmation_regex)
    if drop_name and drop_mob_name then

        if FarmBuddy.farm_data[drop_mob_name].drops[drop_name] == nil then
            FarmBuddy.farm_data[drop_mob_name].drops[drop_name] = 0
        end

        FarmBuddy.farm_data[drop_mob_name].drops[drop_name] = FarmBuddy.farm_data[drop_mob_name].drops[drop_name] + 1
     end
end

FarmBuddy.handle_addon_command = function (_, command)

    local action, report, kill_plural

    if command ~= nil then
        action = command:lower()
    end

    if action == 'reset' then
        FarmBuddy.farm_data = {}
    end

    if action == 'report' then
        for monster_name, monster_data in pairs(FarmBuddy.farm_data) do
            if monster_data.kills > 1 then
                kill_plural = 's'
            else
                kill_plural = ''
            end
            windower.send_command(monster_name .. ': ' .. monster_data.kills .. ' kill' .. kill_plural)
            for drop_name, drop_amount in pairs(monster_data.drops) do
                windower.send_command(drop_name .. ': ' .. drop_amount .. '/' .. monster_data.kills .. ' (' .. round(drop_amount / monster_data.kills * 100) .. '%)')
            end
        end
    end
end

windower.register_event('incoming text', FarmBuddy.handle_incoming_message)
windower.register_event('addon command', FarmBuddy.handle_addon_command)

return FarmBuddy

-- function split(msg, match)
--     local length = msg:len()
--     local splitarr = {}
--     local u = 1
--     while u < length do
--         local nextanch = msg:find(match,u)
--         if nextanch ~= nil then
--             splitarr[#splitarr+1] = msg:sub(u,nextanch-1)
--             if nextanch~=length then
--                 u = nextanch+1
--             else
--                 u = length
--             end
--         else
--             splitarr[#splitarr+1] = msg:sub(u,length)
--             u = length
--         end
--     end
--     return splitarr
-- end
--
-- function round(num, idp)
--   local mult = 10^(idp or 0)
--   return math.floor(num * mult + 0.5) / mult
-- end
--
-- windower.register_event('addon command', function (...)
--   local concat_args = table.concat({...}, ' ')
--   local args = split(concat_args, ' ')
--   if args[1] ~= nil then
--     if args[1]:upper() == "REPORT" then
--       local report = {}
--       for mob_name, mob_data in pairs(farm_data) do
--         report.insert(mob_name .. '(' .. kills .. ' kills)')
--         local kills = mob_data.kills
--         local drop_data = mob_data.drops
--         for drop_name, amount in pairs(drop_data) do
--           local percentage = amount / kills * 100
--           report.insert(drop_name .. ': ' .. amount .. '/' .. percentage .. '%')
--         end
--         report.insert('')
--       end
--       for line in report do
--         print(line)
--       end
--     end
--   end
-- end)
--
-- windower.register_event('incoming text', function(_, text, _, _, blocked)
--     if blocked or text == '' then
--         return
--     end
--
--     local kill_confirmation_regex = 'Xurion defeats the (.*).'
--     local killed_mob_name = string.match(text, kill_confirmation_regex)
--
--     if killed_mob_name then
--       if farm_data[killed_mob_name] == nil then
--         farm_data[killed_mob_name] = {
--           kills = 0,
--           drops = {}
--         }
--       end
--
--       farm_data[killed_mob_name]["kills"] = farm_data[killed_mob_name]["kills"] + 1
--     end
--
--     local drop_confirmation_regex = 'You find an? (.*) on the (.*).'
--     local drop_name, drop_mob_name = string.match(text, drop_confirmation_regex)
--     if drop_name and drop_mob_name then
--
--       if farm_data[drop_mob_name]['drops'][drop_name] == nil then
--         farm_data[drop_mob_name]['drops'][drop_name] = 0
--       end
--
--       farm_data[drop_mob_name]['drops'][drop_name] = farm_data[drop_mob_name]['drops'][drop_name] + 1
--
--     end
--
--     -- print_r(farm_data)
-- end)
