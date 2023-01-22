require "DebugUIs/DebugMenu/ISDebugMenu"

require "DebugUIs/DebugMenu/Base/ISDebugPanelBase"

function ISDebugPanelBase:close()
    self:setVisible(false)
    self:removeFromUIManager()
end

function ISDebugPanelBase.OnOpenPanel(_class,_x, _y, _w, _h, _title)

    if _class.instance and _class.instance:getIsVisible() then
        _class.instance:close()
        return
    end

    if _class.instance == nil then
        local x = ISDebugMenu.instance:getX()+ISDebugMenu.instance:getWidth()+5
        local y = ISDebugMenu.instance:getY()
        _class.instance = _class:new(x, y, _w, _h, _title)
        _class.instance:initialise()
        _class.instance:instantiate()
        _class.instance:setX(x)
        _class.instance:setY(y)
        ISDebugMenu.RegisterClass(_class)
    end
    _class.instance:addToUIManager()
    _class.instance:setVisible(true)


    return _class.instance
end


local function genericClose(self)
    self:setVisible(false)
    self:removeFromUIManager()
end


local function genericOnOpen(_class, args, addFuncOnShow, instantiate)

    if _class.instance and _class.instance:getIsVisible() then
        _class.instance:close()
        return
    end

    if _class.instance == nil then
        _class.close = genericClose
        local x = ISDebugMenu.instance:getX()+ISDebugMenu.instance:getWidth()+5
        local y = ISDebugMenu.instance:getY()
        local ui = _class:new(x, y, unpack(args))
        ui:initialise()
        if instantiate then ui:instantiate() end
        ui:setX(x)
        ui:setY(y)
        _class.instance = ui

    end
    _class.instance:addToUIManager()
    _class.instance:setVisible(true)

    if addFuncOnShow and _class.instance[addFuncOnShow] then
        _class[addFuncOnShow](_class.instance)
    end

    return _class.instance
end


require "ISUI/PlayerStats/ISPlayerStatsUI"
function ISPlayerStatsUI.OnOpenPanel()
    return genericOnOpen(ISPlayerStatsUI, { 800, 800, getPlayer(), getPlayer() }, nil, nil)
end


require "ISUI/AdminPanel/ISItemsListViewer"
function ISItemsListViewer.OnOpenPanel()
    return genericOnOpen(ISItemsListViewer, { 850, 650 }, "setKeyboardFocus", nil)
end


require "DebugUIs/DebugMenu/IsoRegions/IsoRegionsWindow"
function IsoRegionsWindow.OnOpenPanel()
    return genericOnOpen(IsoRegionsWindow, { 400, 400 }, nil, true)
end


require "ISUI/ZombiePopulationWindow"
function ZombiePopulationWindow.OnOpenPanel()
    return genericOnOpen(ZombiePopulationWindow, { 400, 400 }, nil, true)
end


require "DebugUIs/StashDebug"
function StashDebug.OnOpenPanel()
    return genericOnOpen(StashDebug, { 400, 400 }, "populateList", nil)
end
local StashDebug_onClick = StashDebug.onClick
function StashDebug:onClick(button)
    if button.internal == "CANCEL" then self:close() return end
    StashDebug_onClick(self, button)
end


require "DebugUIs/DebugMenu/Anims/ISAnimDebugMonitor"
function ISAnimDebugMonitor.OnOpenPanel()
    return genericOnOpen(ISAnimDebugMonitor, { 500, 750, getPlayer() })
end


require "DebugUIs/DebugMenu/GlobalModData/GlobalModData"
function GlobalModDataDebug.OnOpenPanel()
    return genericOnOpen(GlobalModDataDebug, { 840, 600, "Global ModData Debugger" }, nil, true)
end


require "DebugUIs/DebugMenu/Statistic/ISGameStatisticPanel"
function ISGameStatisticPanel.OnOpenPanel()
    return genericOnOpen(ISGameStatisticPanel, { 800, 800, "Statistic" }, nil, true)
end


require "DebugUIs/DebugMenu/WorldFlares/WorldFlaresDebug"
function WorldFlaresDebug.OnOpenPanel()
    return genericOnOpen(WorldFlaresDebug, { 400, 600, "Flares debugger" }, nil, true)
end


require "DebugUIs/DebugMenu/radio/ZomboidRadioDebug"
function ZomboidRadioDebug.OnOpenPanel()
    if isClient() then return end
    return genericOnOpen(ZomboidRadioDebug, { 1000, 600, "Zomboid radio debugger" }, nil, true)
end
