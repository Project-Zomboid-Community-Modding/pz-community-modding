require("AUD/Init")

local vehicleDebugFunctions = {}

local function vehicleDebugFunctions_onClick()
    local player = getPlayer()
    if player == nil then return end

    local z = getPlayer():getZ()
    local x, y = ISCoordConversion.ToWorld(getMouseXScaled(), getMouseYScaled(), z)
    local sq = getCell():getGridSquare(math.floor(x), math.floor(y), z)

    if AUD.Config.isSpawnVehicle then
        if sq then
            addVehicleDebug(AUD.Config.spawnVehicleScript:getFullName(), IsoDirections.S, nil, sq)
        end
    elseif AUD.Config.isSelectVehicle then
        local vehicle = sq:getVehicleContainer()
        if vehicle ~= nil then
            AUD.Config.selectedVehicle = vehicle
            AUD.Config.isSelectVehicle = false
            getPlayer():Say(getText("IGUI_VehicleName" .. vehicle:getScript():getName()) .. " selected")
        end
    end
end
Events.OnMouseDown.Add(vehicleDebugFunctions_onClick)


function vehicleDebugFunctions.addRepairVehicle(UIElement)
    local func = function(target, self)
        if AUD.Config.selectedVehicle then
            AUD.Config.selectedVehicle:repair()
        else
            getPlayer():Say("Vehicle not selected")
        end
    end
    return "Repair Vehicle", func
end


function vehicleDebugFunctions.addGetVehicleKey(UIElement)
    local func = function(target, self)
        if AUD.Config.selectedVehicle then
            getPlayer():getInventory():AddItem(AUD.Config.selectedVehicle:createVehicleKey())
        else
            getPlayer():Say("Vehicle not selected")
        end
    end
    return "Get Key", func
end


function vehicleDebugFunctions.addToggleHotwire(UIElement)
    local func = function(target, self)
        if AUD.Config.selectedVehicle then
            if AUD.Config.selectedVehicle:isHotwired() then
                AUD.Config.selectedVehicle:setHotwired(false)
            else
                AUD.Config.selectedVehicle:setHotwired(true)
            end
        else
            getPlayer():Say("Vehicle not selected")
        end
    end
    return "Toggle Hotwire", func
end


function vehicleDebugFunctions.addSelectVehicle(UIElement)
    local func = function(target, self)
        if AUD.Config.isSelectVehicle then
            AUD.Config.isSelectVehicle = false
            self.backgroundColor = AUD.Config.Buttons.RED
            self.backgroundColorMouseOver = AUD.Config.Buttons.RED_HIGHLIGHT
        else
            AUD.Config.isSelectVehicle = true
            self.backgroundColor = AUD.Config.Buttons.GREEN
            self.backgroundColorMouseOver = AUD.Config.Buttons.GREEN_HIGHLIGHT
        end
    end
    return "Select Vehicle", func
end


function vehicleDebugFunctions.addSelectThisVehicle(UIElement)
    local func = function(target, self)
        local pl = getPlayer()
        local veh = pl:getVehicle()

        if veh then
            AUD.Config.selectedVehicle = veh
            pl:Say(getText("IGUI_VehicleName" .. veh:getScript():getName()) .. " selected")
        else
            pl:Say("Player not in vehicle")
        end
    end
    return "Select this Vehicle", func
end


function vehicleDebugFunctions.addSpawnVehicle(UIElement)
    local func = function(target, self)
        local modal = AUDSpawnVehiclePanel:new(Core:getInstance():getScreenWidth() - 290, Core:getInstance():getScreenHeight() - 285 - 40 - 400, 250, 300, nil, ISPlayerStatsUI.onAddTrait)
        modal:initialise()
        modal:addToUIManager()
    end
    return "Spawn vehicle", func
end


return vehicleDebugFunctions