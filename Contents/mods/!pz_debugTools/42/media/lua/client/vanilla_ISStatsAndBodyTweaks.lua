--ISStatsAndBody
require "DebugUIs/DebugMenu/General/ISStatsAndBody.lua"

--- Concept From: https://steamcommunity.com/sharedfiles/filedetails/?id=2553859246
-- Implementation by Chuck
-- Rip through the slider's behavior rather than overwrite the entire create children section.

local ISStatsAndBody_onSliderChange = ISStatsAndBody.onSliderChange
function ISStatsAndBody:onSliderChange(_newval, _slider)
    local v = _slider.customData
    if v.var=="Fitness" then

        local label = v.label
        if label then self:removeChild(label) end

        local labelValue = v.labelValue
        if labelValue then self:removeChild(labelValue) end

        self:removeChild(_slider)
        return
    end
    ISStatsAndBody_onSliderChange(self, _newval, _slider)
end