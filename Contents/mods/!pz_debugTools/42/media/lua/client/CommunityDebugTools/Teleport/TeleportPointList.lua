require "ISUI/ISCollapsableWindow"
local HoverButtonList = require "CommunityDebugTools/HoverButtonList"

TeleportPointList = HoverButtonList:derive("TeleportPointList")

function TeleportPointList:onMouseDoubleClickFile(item)
	if not item then return end
	if instanceof(item, "IsoPlayer") then
		AUDTeleport.teleportTo(item:getX(), item:getY(), item:getZ())
	else
		AUDTeleport.teleportTo(item.x, item.y, item.z)
	end
end
