require("AUD/DebugPanel/VehicleTab/VehicleTab")


function AUD.VehicleTab.onClick()
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

Events.OnMouseDown.Add(AUD.VehicleTab.onClick)