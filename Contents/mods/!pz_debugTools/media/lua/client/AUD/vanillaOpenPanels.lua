require "DebugUIs/DebugMenu/ISDebugMenu"
require "AUD/Init.lua"

local function genericClose(self)
    self:setVisible(false)
    self:removeFromUIManager()
end

local function genericRestoreLayout(self, name, layout)
    ISLayoutManager.DefaultRestoreWindow(self, layout)
end

local function genericSaveLayout(self, name, layout)
    ISLayoutManager.DefaultSaveWindow(self, layout)
    ISLayoutManager.SaveWindowVisible(self, layout)
end


local function genericOnOpen(classID, args, addFuncOnShow, instantiate)

    local _class = _G[classID]
    if not _class then return end

    if _class.instance and _class.instance:getIsVisible() then
        _class.instance:close()
        return
    end

    if _class.instance == nil then
        _class.close = genericClose
        _class.RestoreLayout = genericRestoreLayout
        _class.SaveLayout = genericSaveLayout

        local x, y = AUD.getDebugMenuAdjacentPos()
        local ui = _class:new(x, y, unpack(args))
        ui:initialise()
        if instantiate then
            ui:instantiate()
            if type(instantiate) == "function" then instantiate(_class) end
        end
        ui:setX(x)
        ui:setY(y)
        _class.instance = ui
        ISLayoutManager.RegisterWindow(classID, _class, _class.instance)
    end
    _class.instance:addToUIManager()
    _class.instance:setVisible(true)

    if addFuncOnShow and _class.instance[addFuncOnShow] then
        _class[addFuncOnShow](_class.instance)
    end

    return _class.instance
end


require "DebugUIs/DebugMenu/Climate/ClimateControlDebug"
function ClimateControlDebug.OnOpenPanel()
    return genericOnOpen("ClimateControlDebug", { 800, 600, "GENERAL DEBUGGERS" }, nil, ISDebugMenu.RegisterClass)
end

require "DebugUIs/DebugMenu/General/ISGeneralDebug"
function ISGeneralDebug.OnOpenPanel()
    return genericOnOpen("ISGeneralDebug", { 800, 600, "GENERAL DEBUGGERS" }, nil, ISDebugMenu.RegisterClass)
end


require "ISUI/PlayerStats/ISPlayerStatsUI"
function ISPlayerStatsUI.OnOpenPanel()
    return genericOnOpen("ISPlayerStatsUI", { 800, 800, getPlayer(), getPlayer() }, nil, nil)
end


require "ISUI/AdminPanel/ISItemsListViewer"
function ISItemsListViewer.OnOpenPanel()
    return genericOnOpen("ISItemsListViewer", { 850, 650 }, "setKeyboardFocus", nil)
end


require "DebugUIs/DebugMenu/IsoRegions/IsoRegionsWindow"
function IsoRegionsWindow.OnOpenPanel()
    return genericOnOpen("IsoRegionsWindow", { 400, 400 }, nil, true)
end


require "ISUI/ZombiePopulationWindow"
function ZombiePopulationWindow.OnOpenPanel()
    return genericOnOpen("ZombiePopulationWindow", { 400, 400 }, nil, true)
end


require "DebugUIs/StashDebug"
function StashDebug.OnOpenPanel()
    return genericOnOpen("StashDebug", { 400, 400 }, "populateList", nil)
end
local StashDebug_onClick = StashDebug.onClick
function StashDebug:onClick(button)
    if button.internal == "CANCEL" then self:close() return end
    StashDebug_onClick(self, button)
end


require "DebugUIs/DebugMenu/Anims/ISAnimDebugMonitor"
function ISAnimDebugMonitor.OnOpenPanel()
    return genericOnOpen("ISAnimDebugMonitor", { 500, 750, getPlayer() }, nil, nil)
end


require "DebugUIs/DebugMenu/GlobalModData/GlobalModData"
function GlobalModDataDebug.OnOpenPanel()
    return genericOnOpen("GlobalModDataDebug", { 840, 600, "Global ModData Debugger" }, nil, true)
end


require "DebugUIs/DebugMenu/Statistic/ISGameStatisticPanel"
function ISGameStatisticPanel.OnOpenPanel()
    return genericOnOpen("ISGameStatisticPanel", { 800, 800, "Statistic" }, nil, true)
end


require "DebugUIs/DebugMenu/WorldFlares/WorldFlaresDebug"
function WorldFlaresDebug.OnOpenPanel()
    return genericOnOpen("WorldFlaresDebug", { 400, 600, "Flares debugger" }, nil, true)
end


require "DebugUIs/DebugMenu/radio/ZomboidRadioDebug"
function ZomboidRadioDebug.OnOpenPanel()
    if isClient() then return end
    return genericOnOpen("ZomboidRadioDebug", { 1000, 600, "Zomboid radio debugger" }, nil, true)
end
