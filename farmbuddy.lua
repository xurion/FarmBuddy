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

windower.register_event('addon command', function (...)
    windower.send_command('@input /echo Executed addon command event')
end)

windower.register_event('incoming text', function(_, text, _, _, blocked)
    if blocked or text == '' then
        return
    end

    local kill_confirmation_regex = 'Xurion defeats.*'
    local is_kill_confirmation = string.match(text, kill_confirmation_regex)
    if is_kill_confirmation then
      kill_count = kill_count + 1
      print('Total kills: ' .. kill_count)
    end
end)
