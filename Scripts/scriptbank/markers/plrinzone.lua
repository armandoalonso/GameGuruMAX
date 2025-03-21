-- LUA Script - precede every function and global member with lowercase name of script + '_main'
-- Player In Zone v15 by Necrym59 and Lee
-- DESCRIPTION: Re-triggerable zone to trigger an event.
-- DESCRIPTION: [ZONEHEIGHT=100] controls how far above the zone the player can be before the zone is not triggered.
-- DESCRIPTION: Set for [@MULTI_TRIGGER=2(1=Yes, 2=No)]
-- DESCRIPTION: Set [DELAY=0(0,100)] in seconds to delay triggered event.
-- DESCRIPTION: [SpawnAtStart!=1] if unchecked use a switch or other trigger to spawn this zone
-- DESCRIPTION: [SoundVolume=100[1,100] adjust this sounds volume
-- DESCRIPTION: <Sound0> when entering zone

local g_plrinzone 	= {}
local multi_dead	= {}
local multi_switch	= {}
local status		= {}
local doonce		= {}
local wait			= {}
local waittime 		= {}

function plrinzone_properties(e, zoneheight, multi_trigger, delay, spawnatstart, soundvolume)
	g_plrinzone[e].zoneheight = zoneheight or 100
	g_plrinzone[e].multi_trigger = multi_trigger or 2
	g_plrinzone[e].delay = delay or 0
	g_plrinzone[e].spawnatstart = spawnatstart or 1
	g_plrinzone[e].soundvolume = soundvolume or 1
end

function plrinzone_init(e)
	g_plrinzone[e] = {}
	g_plrinzone[e].zoneheight = 100
	g_plrinzone[e].multi_trigger = 2
	g_plrinzone[e].delay = 0
	g_plrinzone[e].spawnatstart = 1
	g_plrinzone[e].soundvolume = 100	
	status[e] = "init"
	doonce[e] = 0
	multi_dead[e] = 0
	multi_switch[e] = 0
	waittime[e] = 0
	wait[e] = math.huge
end

function plrinzone_main(e)
	if status[e] == "init" then
		if g_plrinzone[e].delay ~= nil then waittime[e] = g_plrinzone[e].delay * 1000 end
		if g_plrinzone[e].spawnatstart > 0 then SetActivated(e,1) end
		if g_plrinzone[e].spawnatstart == 0 then SetActivated(e,0) end
		status[e] = "endinit"
	end
	if g_Entity[e]['activated'] == 1 then
		if g_Entity[e]['plrinzone'] == 1 and multi_switch[e] == 0 and g_PlayerPosY > g_Entity[e]['y'] and g_PlayerPosY < g_Entity[e]['y']+g_plrinzone[e]['zoneheight'] then
			if doonce[e] == 0 then
				PlaySound(e,0)
				SetSound(e,0)
				SetSoundVolume(g_plrinzone[e].soundvolume)
				wait[e] = g_Time + waittime[e]
				doonce[e] = 1
			end
		end
		if g_Time > wait[e] then
			if g_plrinzone[e].multi_trigger == 1 and multi_switch[e] == 0 then
				if doonce[e] == 1 then
					multi_switch[e] = 1				
					ActivateIfUsed(e)
					PerformLogicConnections(e)
					doonce[e] = 2
				end	
			end
			if g_plrinzone[e].multi_trigger == 2 then
				if multi_dead[e] == 0 then
					ActivateIfUsed(e)
					PerformLogicConnections(e)
					Destroy(e)
					multi_dead[e] = 1
				end
			end
		end	
		if g_Entity[e]['plrinzone'] == 0 and multi_switch[e] == 1 then
			StopSound(e,0)
			doonce[e] = 0
			multi_switch[e] = 0
		end		
	end
	-- restore logic
	if g_EntityExtra[e]['restoremenow'] ~= nil then
     if g_EntityExtra[e]['restoremenow'] == 1 then
      g_EntityExtra[e]['restoremenow'] = 0
	  status[e] = "init"
	  -- no good, as GetEntitySpawnAtStart is always 1 and different from plrinzone[e].spawnatstart
	  -- plrinzone[e].spawnatstart = GetEntitySpawnAtStart(e)
	  -- instead the 'init' will use the newly renamed g_plrinzone state that is correct for new and reloaded level states!
     end
	end	
	
end