_addon.commands = {'farmbuddy', 'fb'}
_addon.name = 'FarmBuddy'
_addon.author = 'Xurion of Bismarck'
_addon.version = '1.0.0'

local FarmBuddy = {
    farm_data = {},
    status = 'running'
}

function round(num, idp)
    local mult = 10^(idp or 0)
    return math.floor(num * mult + 0.5) / mult
end

function getExistingDataKey(mob_name)
    for key, existing_kill_data in pairs(FarmBuddy.farm_data) do
        if existing_kill_data.name == mob_name then
            return key
        end
    end

    return false
end

FarmBuddy.handle_incoming_message = function (_, text)

    if text == '' or FarmBuddy.status == 'paused' then
        return false
    end

    local kill_confirmation_regex = 'Xurion defeats the (.*)%.'
    local killed_mob_name = string.match(text, kill_confirmation_regex)
    local key

    if killed_mob_name then
        key = getExistingDataKey(killed_mob_name)
        if key == false then
            table.insert(FarmBuddy.farm_data, {
                name = killed_mob_name,
                kills = 1,
                drops = {}
            })
        else
            FarmBuddy.farm_data[key].kills = FarmBuddy.farm_data[key].kills + 1
        end
    end

    local drop_confirmation_regex = 'You find an? (.*) on the (.*)%.'
    local drop_name, drop_mob_name = string.match(text, drop_confirmation_regex)
    if drop_name and drop_mob_name then
        key = getExistingDataKey(drop_mob_name)
        if key == false then
            FarmBuddy.farm_data[key].drops[drop_name] = 0
        else
            if FarmBuddy.farm_data[key].drops[drop_name] then
                FarmBuddy.farm_data[key].drops[drop_name] = FarmBuddy.farm_data[key].drops[drop_name] + 1
            else
                FarmBuddy.farm_data[key].drops[drop_name] = 1
            end
        end
    end
end

FarmBuddy.handle_addon_command = function (command)

    local action, kill_plural

    if command ~= nil then
        action = command:lower()
    end

    if action == 'report' then
        for _, monster_data in pairs(FarmBuddy.farm_data) do
            if monster_data.kills > 1 then
                kill_plural = 's'
            else
                kill_plural = ''
            end
            FarmBuddy.send_text_to_game(monster_data.name .. ': ' .. monster_data.kills .. ' kill' .. kill_plural)
            for drop_name, drop_amount in pairs(monster_data.drops) do
                FarmBuddy.send_text_to_game(' > ' .. drop_name .. ': ' .. drop_amount .. '/' .. monster_data.kills .. ' (' .. round(drop_amount / monster_data.kills * 100) .. '%)')
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

windower.register_event('incoming text', FarmBuddy.handle_incoming_message)
windower.register_event('addon command', FarmBuddy.handle_addon_command)

return FarmBuddy
