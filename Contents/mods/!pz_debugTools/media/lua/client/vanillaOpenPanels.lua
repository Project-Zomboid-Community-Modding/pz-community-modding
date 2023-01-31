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
end


---@param classID string used with _G[classID] to fetch `_class`
---@param args table list of arguments to pass into _class:new()
---@param addFuncOnShow function function to run after show with `_class.instance` as the only argument
---@param instantiate boolean if true runs `instantiate`
function generic.OnOpen(classID, args, addFuncOnShow, instantiate, debugMenuRegisterClass)

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
        if instantiate then ui:instantiate() end
        ui:setX(x)
        ui:setY(y)
        _class.instance = ui
        ISLayoutManager.RegisterWindow(classID, _class, _class.instance)
        if debugMenuRegisterClass then ISDebugMenu.RegisterClass(_class) end
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
    ["DebugUIs/DebugMenu/Climate/ClimateControlDebug"] = {"ClimateControlDebug", { 800, 600, "CLIMATE CONTROL" }, nil, true},
    ["DebugUIs/DebugMenu/General/ISGeneralDebug"] = {"ISGeneralDebug", { 800, 600, "GENERAL DEBUGGERS" }, nil, true, true},
    ["ISUI/PlayerStats/ISPlayerStatsUI"] = {"ISPlayerStatsUI", { 800, 800, getPlayer, getPlayer }},
    ["ISUI/AdminPanel/ISItemsListViewer"] = {"ISItemsListViewer", { 850, 650 }, "setKeyboardFocus"},
    ["DebugUIs/DebugMenu/IsoRegions/IsoRegionsWindow"] = {"IsoRegionsWindow", { 400, 400 }, nil, true, true},
    ["ISUI/ZombiePopulationWindow"] = {"ZombiePopulationWindow", { 400, 400 }, nil, true},
    ["DebugUIs/StashDebug"] = {"StashDebug", { 400, 400 }, "populateList"},
    ["DebugUIs/DebugMenu/Anims/ISAnimDebugMonitor"] = {"ISAnimDebugMonitor", { 500, 750, getPlayer }},

    ["DebugUIs/DebugMenu/GlobalModData/GlobalModData"] = {"GlobalModDataDebug", { 840, 600, "Global ModData Debugger" }, nil, true},
    ["DebugUIs/DebugMenu/Statistic/ISGameStatisticPanel"] = {"ISGameStatisticPanel", { 800, 800, "Statistic" }, nil, true},
    ["DebugUIs/DebugMenu/WorldFlares/WorldFlaresDebug"] = {"WorldFlaresDebug", { 400, 600, "Flares debugger" }, nil, true},
    ["DebugUIs/DebugMenu/radio/ZomboidRadioDebug"] = {"ZomboidRadioDebug", { 1000, 600, "Zomboid radio debugger" }, nil, true},
}

---This window is disabled from opening in vanilla MP
if isClient() then
    generic.overwrites["DebugUIs/DebugMenu/radio/ZomboidRadioDebug"] = nil
    --- aesthetics
    local ISDebugMenu_onClick_Dev = ISDebugMenu.onClick_Dev
    function ISDebugMenu:onClick_Dev()
        ISDebugMenu_onClick_Dev(self)
        for _, b in ipairs(ISDebugMenu.instance.devTab._buttons) do
            if b.title == "Zomboid Radio" then
                b:setEnable(false)
            end
        end
    end
end


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


Events.OnPlayerDeath.Remove(ISDebugMenu.OnPlayerDeath)
function ISDebugMenu.OnPlayerDeath(playerObj)
    ISLayoutManager.OnPostSave()

    for _,class in ipairs(ISDebugMenu.classes) do
        if class.instance then
            class.instance:setVisible(false)
            class.instance:removeFromUIManager()
            class.instance = nil
        end
    end
end
Events.OnPlayerDeath.Add(ISDebugMenu.OnPlayerDeath)


local StashDebug_populateList = StashDebug.populateList
function StashDebug:populateList()
    local stashes = StashSystem.getPossibleStashes()
    if stashes then StashDebug_populateList(self) end
end


local StashDebug_onClick = StashDebug.onClick
function StashDebug:onClick(button)
    if button.internal == "CANCEL" then self:close() return end
    StashDebug_onClick(self, button)
end


return generic