--ISStatsAndBody
require "DebugUIs/DebugMenu/General/ISStatsAndBody.lua"
local Stats = require "CommunityDebugTools/Commands/Stats"

local ISStatsAndBody_onSliderChange = ISStatsAndBody.onSliderChange
function ISStatsAndBody:onSliderChange(_newval, _slider)
	local v = _slider.customData
	ISStatsAndBody_onSliderChange(self, _newval, _slider)
	Stats.queueValue(v.var, _newval - v.applyMod)
end


local ISStatsAndBody_onTicked = ISStatsAndBody.onTicked
function ISStatsAndBody:onTicked(_index, _selected, _arg1, _arg2, _tickbox)
	ISStatsAndBody_onTicked(self, _index, _selected, _arg1, _arg2, _tickbox)
	if not isClient() then return end
	local v = _tickbox.customData
	if v.set == "setGodMod" or v.set == "setInvisible" then
		sendPlayerExtraInfo(getPlayer())
	else
		Stats.sendBool(v.set, v.java[v.get](v.java))
	end
end


local ISStatsAndBody_prerender = ISStatsAndBody.prerender
function ISStatsAndBody:prerender()
	ISStatsAndBody_prerender(self)
	Stats.flush()
end
