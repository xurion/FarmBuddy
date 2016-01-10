_addon.commands = {'farmbuddy', 'fb'}
_addon.name = 'FarmBuddy'
_addon.author = 'Xurion of Bismarck'
_addon.version = '0.0.1'

function print_r(t)
    local print_r_cache={}
    local function sub_print_r(t,indent)
        if (print_r_cache[tostring(t)]) then
            print(indent.."*"..tostring(t))
        else
            print_r_cache[tostring(t)]=true
            if (type(t)=="table") then
                for pos,val in pairs(t) do
                    if (type(val)=="table") then
                        print(indent.."["..pos.."] => "..tostring(t).." {")
                        sub_print_r(val,indent..string.rep(" ",string.len(pos)+8))
                        print(indent..string.rep(" ",string.len(pos)+6).."}")
                    elseif (type(val)=="string") then
                        print(indent.."["..pos..'] => "'..val..'"')
                    else
                        print(indent.."["..pos.."] => "..tostring(val))
                    end
                end
            else
                print(indent..tostring(t))
            end
        end
    end
    if (type(t)=="table") then
        print(tostring(t).." {")
        sub_print_r(t,"  ")
        print("}")
    else
        sub_print_r(t,"  ")
    end
    print()
end

--player = windower.ffxi.get_player()
--player_name = player.name

kill_count = 0
farm_data = {}

windower.register_event('addon command', function (...)
    windower.send_command('@input /echo Executed addon command event')
end)

windower.register_event('incoming text', function(_, text, _, _, blocked)
    if blocked or text == '' then
        return
    end

    local kill_confirmation_regex = 'Xurion defeats the (.*).'
    local killed_mob_name = string.match(text, kill_confirmation_regex)

    if killed_mob_name then
      if farm_data[killed_mob_name] == nil then
        farm_data[killed_mob_name] = {
          kills = 0,
          drops = {}
        }
      end

      farm_data[killed_mob_name]["kills"] = farm_data[killed_mob_name]["kills"] + 1
    end

    local drop_confirmation_regex = 'You find an? (.*) on the (.*).'
    local drop_name, drop_mob_name = string.match(text, drop_confirmation_regex)
    if drop_name and drop_mob_name then

      if farm_data[drop_mob_name]['drops'][drop_name] == nil then
        farm_data[drop_mob_name]['drops'][drop_name] = 0
      end

      farm_data[drop_mob_name]['drops'][drop_name] = farm_data[drop_mob_name]['drops'][drop_name] + 1

      --print('Drop info: ' .. drop_name .. ' from ' .. drop_mob_name)
      --windower.send_command('@input /echo Drop info: ' .. drop_name .. ' from ' .. drop_mob_name)
    end

    print_r(farm_data)
end)
