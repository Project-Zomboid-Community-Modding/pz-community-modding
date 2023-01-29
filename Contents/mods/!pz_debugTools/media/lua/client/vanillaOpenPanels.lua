require "DebugUIs/DebugMenu/ISDebugMenu"
require "InitToolBar"

local generic = {}

function generic.Close(self)
    self:setVisible(false)
    self:removeFromUIManager()
end

function generic.RestoreLayout(self, name, layout)
    ISLayoutManager.DefaultRestoreWindow(self, layout)
end

function generic.SaveLayout(self, name, layout)
    ISLayoutManager.DefaultSaveWindow(self, layout)
    ISLayoutManager.SaveWindowVisible(self, layout)
end


---@param classID string used with _G[classID] to fetch `_class`
---@param args table list of arguments to pass into _class:new()
---@param addFuncOnShow function function to run after show with `_class.instance` as the only argument
---@param instantiate boolean|function if true|function runs `instantiate` first, if a function will be ran with _class as an argument after
function generic.OnOpen(classID, args, addFuncOnShow, instantiate)

    local _class = _G[classID]
    if not _class then return end

    _class.close = generic.Close
    _class.RestoreLayout = generic.RestoreLayout
    _class.SaveLayout = generic.SaveLayout

    if _class.instance and _class.instance:getIsVisible() then
        _class.instance:close()
        return
    end

    if _class.instance == nil then

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

    else
        _class.instance:addToUIManager()
        _class.instance:setVisible(true)

        if addFuncOnShow and _class.instance[addFuncOnShow] then
            _class[addFuncOnShow](_class.instance)
        end
    end

    return _class.instance
end


---table of classes, arguments, and additional functions
generic.overwrites = {
    ["DebugUIs/DebugMenu/Climate/ClimateControlDebug"] = {"ClimateControlDebug", { 800, 600, "GENERAL DEBUGGERS" }, nil, ISDebugMenu.RegisterClass},
    ["DebugUIs/DebugMenu/General/ISGeneralDebug"] = {"ISGeneralDebug", { 800, 600, "GENERAL DEBUGGERS" }},
    ["ISUI/PlayerStats/ISPlayerStatsUI"] = {"ISPlayerStatsUI", { 800, 800, getPlayer, getPlayer }},
    ["ISUI/AdminPanel/ISItemsListViewer"] = {"ISItemsListViewer", { 850, 650 }, "setKeyboardFocus"},
    ["DebugUIs/DebugMenu/IsoRegions/IsoRegionsWindow"] = {"IsoRegionsWindow", { 400, 400 }, nil, true},
    ["ISUI/ZombiePopulationWindow"] = {"ZombiePopulationWindow", { 400, 400 }, nil, true},
    ["DebugUIs/StashDebug"] = {"StashDebug", { 400, 400 }, "populateList"},
    ["DebugUIs/DebugMenu/Anims/ISAnimDebugMonitor"] = {"ISAnimDebugMonitor", { 500, 750, getPlayer }},

    ["DebugUIs/DebugMenu/GlobalModData/GlobalModData"] = {"GlobalModDataDebug", { 840, 600, "Global ModData Debugger" }, nil, true},
    ["DebugUIs/DebugMenu/Statistic/ISGameStatisticPanel"] = {"ISGameStatisticPanel", { 800, 800, "Statistic" }, nil, true},
    ["DebugUIs/DebugMenu/WorldFlares/WorldFlaresDebug"] = {"WorldFlaresDebug", { 400, 600, "Flares debugger" }, nil, true},
    ["DebugUIs/DebugMenu/radio/ZomboidRadioDebug"] = {"ZomboidRadioDebug", { 1000, 600, "Zomboid radio debugger" }, nil, true},
}


function generic.openOnStart()
    if not getDebug() then return end

    for req,args in pairs(generic.overwrites) do
        require(req)
        local _class = _G[args[1]]

        for i,arg in pairs(args[2]) do if type(arg)=="function" then args[2][i] = arg() end end

        _class.OnOpenPanel = function() return generic.OnOpen(unpack(args)) end
        _class.OnOpenPanel()
    end
end
Events.OnCreatePlayer.Add(generic.openOnStart)


local StashDebug_onClick = StashDebug.onClick
function StashDebug:onClick(button)
    if button.internal == "CANCEL" then self:close() return end
    StashDebug_onClick(self, button)
end

return generic