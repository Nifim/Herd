_addon = {}
_addon.name = 'Herd'
_addon.version = '1.3.5'
_addon.author = 'Nifim'
_addon.commands = {'herd'}

herd = {}

require('strings')
res = require('resources')
state = 'stand' -- default state is stand

haj = 0
roam = 5
htol = 0.157

Sheep = true
Shepherd = ''
shepherd_last = {x=0, y=0}



help_text = [[Herd - Commands:
1. //herd help - Displays this help menu.
2a. //herd (s)hepherd - Will make all other boxs follow the box that sent this command
2b. //herd (s)hepherd [Name]- Will make all this box follow the character with givin name
3. //herd (j)oin - Causes box to join the herd and follow the current shepherd
4. //herd (l)eave - Causes box to leave the herd and follow the current shepherd
5. //herd (r)elease - Causes all boxs to leave herd and cease following
 ]]	
 --
 -- Windower Events (Main)
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
      herd[state]()
    end
  end)
--
-- Herd States
function herd.stand()
  local shepherd = windower.ffxi.get_mob_by_id(Shepherd)
  local sheep = windower.ffxi.get_mob_by_id(windower.ffxi.get_player().id)
  if shepherd ~= nil then
    local x = shepherd.x - sheep.x
    local y = shepherd.y - sheep.y     
    hto = sheep.facing
    if shepherd.distance:sqrt() > roam and (shepherd.x ~= shepherd_last.x or shepherd.y ~= shepherd_last.y) then
      state = 'follow'
      roam = roam - math.random(2.00001,4.49999)
    end
    shepherd_last = shepherd
  end
end

function herd.follow()
  local shepherd = windower.ffxi.get_mob_by_id(Shepherd)
  local sheep = windower.ffxi.get_mob_by_id(windower.ffxi.get_player().id)
  if (shepherd ~= nil and shepherd.distance:sqrt() > roam) then
    local h = herd.get_heading(shepherd, sheep)
    --check for if heading needs to be adjusted
    if hto ~= h and math.abs(math.abs(hto) - math.abs(h)) > htol then    
      --Check for Turn around
      herd.turn_around(h)
      --Turn to the Left
      if hto > h then
        herd.turn_left(h)
        --Turn to the Right
      elseif hto < h then
        herd.turn_right(h)
      end
    --Execute run at calculated heading
    windower.ffxi.run(hto)
  else
    windower.ffxi.run(hto)
  end
else
  --stop running you have reached the shepard
  state = 'stand'
  roam = 5
  haj = 0
  windower.ffxi.run(false) 
end
end
function herd.menu()
  
end
--
-- Envermoment Functions
function herd.get_heading(shepherd, sheep)
  local x = shepherd.x - sheep.x
  local y = shepherd.y - sheep.y 
  local h = math.atan2(x, y)			
  if haj == 0 then
    haj = 0.0559244155884 + math.random(-0.0000000000003, 0.0000000000006)
  end
  --Adjust heading 90 degrees i dont know why but its needed -1.5707963267948966192313216916398 
  if h < -math.pi/2 then
    --headings in the sw quad need to be handled properly
    h = math.pi - (math.abs(h - (math.pi/2)) - math.pi)
  else
    --headings in the remaining quads are handled like so
    h = h - (math.pi/2)
  end
  return h
end
--
-- Turning Functions
function herd.turn_around(h)
  htolo = hto-(math.pi*0.75)
  htohi = hto-(math.pi*1.25) 
  if htolo < -math.pi then
    htolo = math.pi - math.abs(htolo + math.pi)
  end
  if htohi < -math.pi then
    htohi = math.pi - math.abs(htohi + math.pi)
  end
  if htolo < htohi and h > 0 then
    htolo = math.pi + (htolo + math.pi)
  elseif htolo < htohi and h < 0 then
    htohi = -math.pi + (htohi - math.pi)
  end
  --windower.add_to_chat(4, "hto: "..hto.." htohi: "..htohi.." htolo: "..htolo.." h: "..h)      
  if h < htolo and h > htohi then 
    hto = hto-math.pi       
    if hto < -math.pi then
      hto = math.pi - math.abs(hto + math.pi)
    end
    windower.ffxi.turn(hto)
  end 
end
function herd.turn_left(h)   
  --this handles 0 corssing to continue with the correct heading adjustment
  if hto > 0 and  0 > h and hto > 2 then
    hto = hto + 0.0559244155884002
  else
    hto = hto - 0.0559244155884002
  end
  --this handles the actually pi crossing when hto is greater then pi
  if hto > math.pi then
    hto = -math.pi + (hto - math.pi)
  end
end
function herd.turn_right(h)
  if hto < 0 and 0 < h and hto < -2 then
    hto = hto - 0.0559244155884002
  else
    hto = hto + 0.0559244155884002
  end
  if hto < -math.pi then
    hto = math.pi + (hto + math.pi)
  end
end
--
-- Menu Functions
function herd.home_point()
  
end
function herd.way_point()

end

--
-- Misc. Functions
function bustAcap(s)
  return (s:gsub("^%l", string.upper))
end
