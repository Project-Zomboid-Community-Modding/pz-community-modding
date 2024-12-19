local debug = require "!!!communityPatchDebugTools - shared"

local Vehicles = {}

function Vehicles.add(scriptName,square,direction,skinIndex)
    scriptName = scriptName or "Base.CarLightsPolice"
    square = square or getPlayer():getSquare()
    direction = direction or IsoDirections.S
    --skinIndex = nil--skinIndex or 0

    local vehicle = addVehicleDebug(scriptName,direction,skinIndex,square)

    return vehicle
end

function Vehicles.remove(vehicle)
    local vehicleId
    if type(vehicle) == "number" then vehicleId = vehicle
    elseif instanceof(vehicle, "BaseVehicle") then vehicleId = vehicle:getId()
    elseif type(vehicle) == "string" then vehicleId = tonumber(vehicle)
    end
    if not vehicleId then print("Vehicles: attempted to remove ",vehicle) return end

    if isClient then
        sendClientCommand("vehicle","remove",{vehicle=vehicleId})
    else
        triggerEvent("OnClientCommand","vehicle","remove",nil,{vehicle = vehicleId})
    end
end

--returns the most recent vehicle matching the scriptName
function Vehicles.getLast(scriptName)
    local allVehicles = getCell():getVehicles()
    local test
    for i = allVehicles:size() - 1, 0, -1 do
        test = allVehicles:get(i)
        if not scriptName or scriptName == test:getScriptName() then
            return test
        end
    end
end

function Vehicles.reload(scriptName)
    local vehicle = Vehicles.getLast(scriptName)

    reloadVehicles()
    reloadVehicleTextures(scriptName)

    if vehicle ~= nil then vehicle:scriptReloaded() end
    --if vehicle then Vehicles.remove(vehicle) end
    --Vehicles.add(scriptName)
end

function Vehicles.removeAll(scriptName)
    if isClient() then sendClientCommand("ceDebug","Vehicles.removeAll",{scriptName}) return end
    local vehicles = getCell():getVehicles()
    for i = vehicles:size() - 1, 0, -1 do
        local vehicle = vehicles:get(i)
        if not scriptName or scriptName == vehicle:getScriptName() then
            vehicle:permanentlyRemove()
        end
    end
end
debug.serverCommands["Vehicles.removeAll"] = function(player,args) Vehicles.removeAll(args and args[1]) end

function Vehicles.unlock(vehicle)
    for seat=1,vehicle:getMaxPassengers() do
        local part = vehicle:getPassengerDoor(seat-1)
        if part then
            if isClient() then
                sendClientCommand('vehicle', 'setDoorLocked', { vehicle = vehicle:getId(), part = part:getId(), locked = false })
            else
                part:getDoor():setLocked(false)
            end
        end
    end
end

--example to test all parts
function Vehicles.testAllParts(v,test)
    if not v then return end
    local vehicle
    if instanceof(v,"BaseVehicle") then vehicle = v
    elseif type(v) == "string" then vehicle = Vehicles.getLast(v)
    end
    if not vehicle then return end

    if not (test and type(test) == "function") then
        test = function(i,part)
            if part ~= nil then
                return string.format("\nid:%d | %s | condition: %d", i, part:getId(), part:getCondition())
            else
                return string.format("\nid:%d | no part", i)
            end
        end
    end

    local printTable = {[1]=string.format("\n/*** %s Parts ***/",vehicle:getScriptName() or "unscripted")}
    for i = 0, vehicle:getPartCount() - 1 do
        printTable[i+2] = test(i,vehicle:getPartByIndex(i))
    end
    print(table.concat(printTable))
end

debug.Vehicles = Vehicles
return Vehicles
