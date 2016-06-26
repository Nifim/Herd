_addon = {}
_addon.name = 'Herd'
_addon.version = '1.3'
_addon.author = 'Nifim'
_addon.commands = {'herd'}
require('logger')
require('strings')
res = require('resources')
state = 'stand'
to = 0
htol = 0.314
haj = 0
roam = 5
Sheep = true
Shepherd = ''
shepherd_last = {x=0, y=0}
local logger = {}
logger.defaults = {}

logger.defaults.logtofile = false
logger.defaults.defaultfile = 'lua.log'
logger.defaults.logcolor = 207
logger.defaults.errorcolor = 167
logger.defaults.warningcolor = 200
logger.defaults.noticecolor = 160

help_text = [[Herd - Commands:
1. //herd help - Displays this help menu.
2a. //herd (s)hepherd - Will make all other boxs follow the box that sent this command
2b. //herd (s)hepherd [Name]- Will make all this box follow the character with givin name
3. //herd (j)oin - Causes box to join the herd and follow the current shepherd
4. //herd (l)eave - Causes box to leave the herd and follow the current shepherd
5. //herd (r)elease - Causes all boxs to leave herd and cease following
 ]]	 
windower.register_event('ipc message', function (raw_msg)
    local id = windower.ffxi.get_player().id
    raw_msg = raw_msg and raw_msg:lower()
    msg = string.split(''..raw_msg, ',')
    if msg[1] == 'join' and Sheep == false then
      windower.send_ipc_message('shepherd,'..id)
    elseif msg[1] == 'release' then
      windower.send_command('input //herd leave')
    elseif msg[1] == 'shepherd' then
      Shepherd = msg[2]
      shepName = windower.ffxi.get_mob_by_id(msg[2]).name
      Sheep = true
      if shepName then
        windower.add_to_chat(4,'Sheperd is now: '..shepName)
      end
    end	
  end)

windower.register_event('addon command', function (cmd,...)
    local aug = T{...}:map(string.lower)
    local id = windower.ffxi.get_player().id
    cmd = cmd and cmd:lower() or 'help'
    if cmd == 'join' or cmd == 'j' then
      windower.send_ipc_message('join,'..id)
    elseif cmd == 'leave' or cmd == 'l' then
      Sheep = false
      Shepherd = ''		
    elseif (cmd == 'shepherd' or cmd == 's') and aug[1] == nil then
      Sheep = false
      Shepherd = ''
      windower.send_ipc_message('shepherd,'..id)
    elseif (cmd == 'shepherd' or cmd == 's') and aug[1] ~= nil then
      Sheep = true
      Aug = bustAcap(aug[1])
      Shepherd = windower.ffxi.get_mob_by_name(Aug).id
    elseif cmd == 'release' or 'r' then
      windower.send_ipc_message('release')
    elseif cmd == 'help' then
      print(help_text)
    end
  end)

windower.register_event('postrender', function()
    if Shepherd ~= '' then
      if state == 'stand' then
        stand()
      elseif state == 'follow' then
        follow()
      end
    end
  end)

function stand()
  local shepherd = windower.ffxi.get_mob_by_id(Shepherd)
  local sheep = windower.ffxi.get_mob_by_id(windower.ffxi.get_player().id)
  if shepherd ~= nil then
    local x = shepherd.x - sheep.x
    local y = shepherd.y - sheep.y 
    hto = math.atan2(x, y)
    if hto < -1.5707963267948966192313216916398 then
      hto = math.pi - (math.abs(math.atan2(x, y) - (math.pi/2)) - math.pi)
    else
      hto = hto - (math.pi/2)
    end
    if shepherd.distance:sqrt() > roam and (shepherd.x ~= shepherd_last.x or shepherd.y ~= shepherd_last.y) then
      start = os.clock
      state = 'follow'
      roam = roam - math.random(2.00001,4.49999)
    end
    shepherd_last = shepherd
  end
end

function follow()
  local shepherd = windower.ffxi.get_mob_by_id(Shepherd)
  local sheep = windower.ffxi.get_mob_by_id(windower.ffxi.get_player().id)
  if (shepherd ~= nil and shepherd.distance:sqrt() > roam and (to <= 0 or os.clock - start < to)) then
    local x = shepherd.x - sheep.x
    local y = shepherd.y - sheep.y 
    local h = math.atan2(x, y)			
    if haj == 0 then
      haj = 0.0559244155884 + math.random(0.00000000000000001, 0.00000000000000009)
    end
    if h < -1.5707963267948966192313216916398 then
      h = math.pi - (math.abs(math.atan2(x, y) - (math.pi/2)) - math.pi)
    else
      h = math.atan2(x, y) - (math.pi/2)
    end
    if hto ~= h and math.abs(hto - h) > htol then
      local herr = math.abs(hto - h) 
      if hto > h then
        if hto > 0 and  0 > h and hto > 2 then
          hto = hto + 0.0559244155884002
        else
          hto = hto - 0.0559244155884002
        end
        if hto > math.pi then
          hto = -math.pi + (hto - math.pi)
        end
      elseif hto < h then
        if hto < 0 and 0 < h and hto < -2 then
          hto = hto - 0.0559244155884002
        else
          hto = hto + 0.0559244155884002
        end
        if hto < -math.pi then
          hto = math.pi + (hto + math.pi)
        end
      end

      windower.ffxi.run(hto)
    else

    end
    if sheep.autorun == nil then
      windower.ffxi.run(hto)
    end	
  else
    state = 'stand'
    roam = 5
    windower.ffxi.run(false) 
  end
end
function bustAcap(s)
  return (s:gsub("^%l", string.upper))
end