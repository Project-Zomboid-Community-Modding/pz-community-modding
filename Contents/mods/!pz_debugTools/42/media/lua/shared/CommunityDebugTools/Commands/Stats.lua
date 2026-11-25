local debug = require "!!!communityPatchDebugTools - shared"

local Stats = {}
Stats.delay = 250
Stats.pending = {}
Stats.flushAt = nil

Stats.values = {
	HealthFromFoodTimer = {target = "body", set = "setHealthFromFoodTimer"},
	ColdDamageStage = {target = "body", set = "setColdDamageStage"},
	ColdStrength = {target = "body", set = "setColdStrength"},
	OverallBodyHealth = {target = "body"},
	TimeSinceLastSmoke = {target = "player", set = "setTimeSinceLastSmoke"},
}

Stats.bools = {
	setInfected = "body",
	setIsFakeInfected = "body",
	setIsOnFire = "body",
	setGhostMode = "player",
}

function Stats.getTarget(player, target)
	if target == "body" then return player:getBodyDamage() end
	return player
end

function Stats.queueValue(var, value)
	if not isClient() or not Stats.values[var] then return end
	Stats.pending[var] = value
	Stats.flushAt = getTimestampMs() + Stats.delay
end

function Stats.flush()
	if not Stats.flushAt or getTimestampMs() < Stats.flushAt then return end
	Stats.flushAt = nil
	sendClientCommand("ceDebug","Stats.setValues",{values = Stats.pending})
	Stats.pending = {}
end

function Stats.sendBool(set, value)
	if not isClient() or not Stats.bools[set] then return end
	sendClientCommand("ceDebug","Stats.setBool",{set = set, value = value})
end

function Stats.applyValue(player, var, value)
	local entry = Stats.values[var]
	if not entry or type(value) ~= "number" then return end
	local body = player:getBodyDamage()
	if var == "OverallBodyHealth" then
		local current = body:getOverallBodyHealth()
		if value < current then
			body:ReduceGeneralHealth(current - value)
		elseif value > current then
			body:AddGeneralHealth(value - current)
		end
		return
	end
	if var == "ColdStrength" then body:setHasACold(value > 0) end
	local target = Stats.getTarget(player, entry.target)
	target[entry.set](target, value)
end

debug.serverCommands["Stats.setValues"] = function(player,args)
	if not player then return end
	for var,value in pairs(args and args.values or {}) do
		Stats.applyValue(player, var, value)
	end
end

debug.serverCommands["Stats.setBool"] = function(player,args)
	local target = args and Stats.bools[args.set]
	if not player or not target then return end
	local obj = Stats.getTarget(player, target)
	obj[args.set](obj, args.value == true)
end

debug.Stats = Stats
return Stats
