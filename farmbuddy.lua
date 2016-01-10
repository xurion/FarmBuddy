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

function split(msg, match)
    local length = msg:len()
    local splitarr = {}
    local u = 1
    while u < length do
        local nextanch = msg:find(match,u)
        if nextanch ~= nil then
            splitarr[#splitarr+1] = msg:sub(u,nextanch-1)
            if nextanch~=length then
                u = nextanch+1
            else
                u = length
            end
        else
            splitarr[#splitarr+1] = msg:sub(u,length)
            u = length
        end
    end
    return splitarr
end

farm_data = {}

windower.register_event('addon command', function (...)
  local concat_args = table.concat({...}, ' ')
  local args = split(concat_args, ' ')
  if args[1] ~= nil then
    if args[1]:upper() == "REPORT" then
      local report = {}
      for mob_name, mob_data in pairs(farm_data) do
        local kills = mob_data.kills
        local drop_data = mob_data.drops
        for drop_name, amount in pairs(drop_data) do
          print(kills .. ' ' .. mob_name .. ' kills resulted in ' .. amount .. ' ' .. drop_name .. '(s)')
        end
      end
    end
  end
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
