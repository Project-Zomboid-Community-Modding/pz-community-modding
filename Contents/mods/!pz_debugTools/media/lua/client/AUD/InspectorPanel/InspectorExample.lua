local function showPlayerStats()
    local player = getPlayer()

    AUD.insp("Player", "Player position:", math.floor(player:getX()*10)/10, math.floor(player:getY()*10)/10)

    local vehicle = player:getVehicle()

    local x = nil
    local y = nil
    local vehName = nil

    if vehicle then
        x = math.floor(vehicle:getX()*10)/10
        y = math.floor(vehicle:getY()*10)/10
        vehName = vehicle:getScript():getName()
    end

    AUD.insp("Player", "Vehicle:", vehName)
    AUD.insp("Player", "Vehicle position:", x, y)
end


Events.OnTick.Add(showPlayerStats)