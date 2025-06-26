--[[ bugfix ]]
---credit: Poltergeist-ix
---Fixes hoods remaining "up" when exiting mechanics window.
require "Vehicles/ISUI/ISVehicleMechanics"
local close = ISVehicleMechanics.close
function ISVehicleMechanics.close(self)
    if self.usedHood and (not self.vehicle or not self.vehicle:getSquare() or self.vehicle:getSquare():getMovingObjects():indexOf(self.vehicle) < 0) then self.usedHood = nil end
    if self.vehicle ~= nil and not self.vehicle:getSquare() then self.vehicle = nil end
    return close(self)
end