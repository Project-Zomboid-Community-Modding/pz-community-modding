require "DebugUIs/ISSpawnVehicleUI.lua"
local AUD = require "InitToolBar"
require "DebugUIs/DebugMenu/ISDebugMenu"

local ISDebugMenu_setupButtons = ISDebugMenu.setupButtons
function ISDebugMenu:setupButtons()
    ISDebugMenu_setupButtons(self)
    self:addButtonInfoAfter("Cheats", "Vehicle", function() DebugContextMenu.onSpawnVehicle(getPlayer()) end, "MAIN")
end


local update = ISSpawnVehicleUI.update
function ISSpawnVehicleUI:update()
    update(self)
    self.vehicle = self.vehicle or self.player:getVehicle()
    if self.vehicle then
        self.repair:setEnable(true)
        self.getKey:setEnable(true)
        if self.hotWireButton then
            self.hotWireButton:setEnable(true)
        end
    else
        self.repair:setEnable(false)
        self.getKey:setEnable(false)
        if self.hotWireButton then
            self.hotWireButton:setEnable(false)
        end
    end
end


--[[ add more buttons ]]
require "DebugUIs/ISSpawnVehicleUI"
local ceDebug = require "!!!communityPatchDebugTools - shared"
local Vehicles = ceDebug.Vehicles

local function removeAll() Vehicles.removeAll() end
local function reload(ui,button) Vehicles.reload(ui:getVehicle()) end

local function addButton(ui,x,y,w,h,text,target,fn)
    local button = ISButton:new(x,y,w,h,text,target,fn)
    button.borderColor = {r=1, g=1, b=1, a=0.1}
    button:initialise()
    ui:addChild(button)
    return button
end

local initialise = ISSpawnVehicleUI.initialise
ISSpawnVehicleUI.initialise = function(self)
    initialise(self)

    local height = self:getHeight()
    local x = 10
    local w, h = 80, 25
    local y = height-h-10

    self.zxReload = addButton(self, x, y, w, h, ("Reload"), self, reload)
    y = y-h-10
    self.zxRemoveAll = addButton(self, x, y, w, h, ("Remove All"), self, removeAll)
    y = y-h-10
    self.hotWireButton = addButton(self, x, y, w, h, ("Toggle Hotwire"), self, ISSpawnVehicleUI.onClick)
end


local onClick = ISSpawnVehicleUI.onClick
function ISSpawnVehicleUI:onClick(button)
    if self.player and self.vehicle then
        if button.internal == "TOGGLE_HOTWIRE" then
            ---@type BaseVehicle
            local car = self.vehicle
            if car then
                sendClientCommand(self.player, "vehicle", "cheatHotwire", { vehicle = car:getId(), hotwired = (not car:isHotwired()), broken = false })
            end
        end
    end
    onClick(self, button)
end