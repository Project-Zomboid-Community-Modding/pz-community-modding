
local VehicleMenuAPI = {}

local sliceTableInside = {}
local sliceTableOutside = {}


function VehicleMenuAPI.registerSlice(sliceName, sliceFunction)
	sliceTableInside[sliceName] = sliceFunction
end

function VehicleMenuAPI.unregisterSlice(sliceName)
	sliceTableInside[sliceName] = nil
end

function VehicleMenuAPI.registerSliceOutside(sliceName, sliceFunction)
	sliceTableOutside[sliceName] = sliceFunction
end

function VehicleMenuAPI.unregisterSliceOutside(sliceName)
	sliceTableOutside[sliceName] = nil
end

--modified version of the default ISVehicleMenu.showRadialMenu allowing editing of the radial menu
function ISVehicleMenu.showRadialMenu(playerObj)
	local isPaused = UIManager.getSpeedControls() and UIManager.getSpeedControls():getCurrentGameSpeed() == 0
	if isPaused then return end

	local vehicle = playerObj:getVehicle()
	if not vehicle then
		ISVehicleMenu.showRadialMenuOutside(playerObj)
		return
	end

	local menu = getPlayerRadialMenu(playerObj:getPlayerNum())
	menu:clear()
	if menu:isReallyVisible() then
		if menu.joyfocus then
			setJoypadFocus(playerObj:getPlayerNum(), nil)
		end
		menu:undisplay()
		return
	end

	for _, f in pairs(sliceTableInside) do
		f(menu, playerObj, vehicle)
	end

	menu:center()
	menu:display(Joypad.DPadUp)

	getSoundManager():playUISound("UIVehicleMenuOpen")
	menu.sounds.undisplay = "UIVehicleMenuClose" -- this is cleared when the menu is hidden
end

--modified version of the default ISVehicleMenu.showRadialMenuOutside allowing editing of the radial menu
function ISVehicleMenu.showRadialMenuOutside(playerObj)
	if playerObj:getVehicle() then return end

	local menu = getPlayerRadialMenu(playerObj:getPlayerNum())
	if menu:isReallyVisible() then
		if menu.joyfocus then
			setJoypadFocus(playerObj:getPlayerNum(), nil)
		end
		menu:undisplay()
		return
	end

	menu:clear()

	local vehicle = ISVehicleMenu.getVehicleToInteractWith(playerObj)
	if vehicle then
		for _, f in pairs(sliceTableOutside) do
			f(menu, playerObj, vehicle)
		end
	end

	menu:center()
	menu:display(Joypad.DPadUp)

	getSoundManager():playUISound("UIVehicleMenuOpen")
	menu.sounds.undisplay = "UIVehicleMenuClose" -- this is cleared when the menu is hidden
end

------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------		Base Game Slices		------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------

VehicleMenuAPI.registerSlice("SwitchSeat", function(menu, player, vehicle)
	menu:addSlice(getText("IGUI_SwitchSeat"), getTexture("media/ui/vehicles/vehicle_changeseats.png"), ISVehicleMenu.onShowSeatUI, player, vehicle)
end)

VehicleMenuAPI.registerSlice("StartStopEngine", function(menu, player, vehicle)
	if vehicle:isDriver(player) and vehicle:isEngineWorking() then
		if vehicle:isEngineRunning() then
			menu:addSlice(getText("ContextMenu_VehicleShutOff"), getTexture("media/ui/vehicles/vehicle_ignitionOFF.png"), ISVehicleMenu.onShutOff, player)
		else
			if vehicle:isEngineStarted() then
				--				menu:addSlice("Ignition", getTexture("media/ui/vehicles/vehicle_ignitionON.png"), ISVehicleMenu.onStartEngine, player)
			else
				if (SandboxVars.VehicleEasyUse) then
					menu:addSlice(getText("ContextMenu_VehicleStartEngine"), getTexture("media/ui/vehicles/vehicle_ignitionON.png"), ISVehicleMenu.onStartEngine, player)
				elseif player:getInventory():haveThisKeyId(vehicle:getKeyId()) or vehicle:isKeysInIgnition() or vehicle:isHotwired() then
					menu:addSlice(getText("ContextMenu_VehicleStartEngine"), getTexture("media/ui/vehicles/vehicle_ignitionON.png"), ISVehicleMenu.onStartEngine, player)
				end
			end
		end
	end
end)

VehicleMenuAPI.registerSlice("Hotwire", function(menu, player, vehicle)
	if vehicle:isDriver(player) and
		not vehicle:isHotwired() and
		not vehicle:isEngineStarted() and
		not vehicle:isEngineRunning() and
		not SandboxVars.VehicleEasyUse and
		not vehicle:isKeysInIgnition() and
		not player:getInventory():haveThisKeyId(vehicle:getKeyId()) then
		if ((player:getPerkLevel(Perks.Electricity) >= 1 and player:getPerkLevel(Perks.Mechanics) >= 2) or player:HasTrait("Burglar")) then
			menu:addSlice(getText("ContextMenu_VehicleHotwire"), getTexture("media/ui/vehicles/vehicle_ignitionON.png"), ISVehicleMenu.onHotwire, player)
		else
			menu:addSlice(getText("ContextMenu_VehicleHotwireSkill"), getTexture("media/ui/vehicles/vehicle_ignitionOFF.png"), nil, player)
		end
	end
end)

VehicleMenuAPI.registerSlice("Headlights", function(menu, player, vehicle)
	if vehicle:isDriver(player) and vehicle:hasHeadlights() then
		if vehicle:getHeadlightsOn() then
			menu:addSlice(getText("ContextMenu_VehicleHeadlightsOff"), getTexture("media/ui/vehicles/vehicle_lightsOFF.png"), ISVehicleMenu.onToggleHeadlights, player)
		else
			menu:addSlice(getText("ContextMenu_VehicleHeadlightsOn"), getTexture("media/ui/vehicles/vehicle_lightsON.png"), ISVehicleMenu.onToggleHeadlights, player)
		end
	end
end)

VehicleMenuAPI.registerSlice("Heater", function(menu, player, vehicle)
	if vehicle:getPartById("Heater") then
		local tex = getTexture("media/ui/vehicles/vehicle_temperatureHOT.png")
		if (vehicle:getPartById("Heater"):getModData().temperature or 0) < 0 then
			tex = getTexture("media/ui/vehicles/vehicle_temperatureCOLD.png")
		end
		if vehicle:getPartById("Heater"):getModData().active then
			menu:addSlice(getText("ContextMenu_VehicleHeaterOff"), tex, ISVehicleMenu.onToggleHeater, player)
		else
			menu:addSlice(getText("ContextMenu_VehicleHeaterOn"), tex, ISVehicleMenu.onToggleHeater, player)
		end
	end
end)

VehicleMenuAPI.registerSlice("Horn", function(menu, player, vehicle)
	if vehicle:isDriver(player) and vehicle:hasHorn() then
		menu:addSlice(getText("ContextMenu_VehicleHorn"), getTexture("media/ui/vehicles/vehicle_horn.png"), ISVehicleMenu.onHorn, player)
	end
end)

VehicleMenuAPI.registerSlice("Lightbar", function(menu, player, vehicle)
	if (vehicle:hasLightbar()) then
		menu:addSlice(getText("ContextMenu_VehicleLightbar"), getTexture("media/ui/vehicles/vehicle_lightbar.png"), ISVehicleMenu.onLightbar, player)
	end
end)

VehicleMenuAPI.registerSlice("Device", function(menu, player, vehicle)
	local seat = vehicle:getSeat(player)
	if seat <= 1 then -- only front seats can access the radio
		for partIndex = 1, vehicle:getPartCount() do
			local part = vehicle:getPartByIndex(partIndex - 1)
			if part:getDeviceData() and part:getInventoryItem() then
				menu:addSlice(getText("IGUI_DeviceOptions"), getTexture("media/ui/vehicles/vehicle_speakersON.png"), ISVehicleMenu.onSignalDevice, player, part)
			end
		end
	end
end)

VehicleMenuAPI.registerSlice("Window", function(menu, player, vehicle)
	local seat = vehicle:getSeat(player)
	local door = vehicle:getPassengerDoor(seat)
	local windowPart = VehicleUtils.getChildWindow(door)
	if windowPart and (not windowPart:getItemType() or windowPart:getInventoryItem()) then
		local window = windowPart:getWindow()
		if window:isOpenable() and not window:isDestroyed() then
			if window:isOpen() then
				option = menu:addSlice(getText("ContextMenu_Close_window"), getTexture("media/ui/vehicles/vehicle_windowCLOSED.png"), ISVehiclePartMenu.onOpenCloseWindow, player, windowPart, false)
			else
				option = menu:addSlice(getText("ContextMenu_Open_window"), getTexture("media/ui/vehicles/vehicle_windowOPEN.png"), ISVehiclePartMenu.onOpenCloseWindow, player, windowPart, true)
			end
		end
	end
end)

VehicleMenuAPI.registerSlice("Locks", function(menu, player, vehicle)
	local locked = vehicle:isAnyDoorLocked()
	if JoypadState.players[player:getPlayerNum() + 1] then
		-- Hack: Mouse players click the trunk icon in the dashboard.
		locked = locked or vehicle:isTrunkLocked()
	end
	if locked then
		menu:addSlice(getText("ContextMenu_Unlock_Doors"), getTexture("media/ui/vehicles/vehicle_lockdoors.png"), ISVehiclePartMenu.onLockDoors, player, vehicle, false)
	else
		menu:addSlice(getText("ContextMenu_Lock_Doors"), getTexture("media/ui/vehicles/vehicle_lockdoors.png"), ISVehiclePartMenu.onLockDoors, player, vehicle, true)
	end
end)

VehicleMenuAPI.registerSlice("Mechanics", function(menu, player, vehicle)
	if vehicle:getCurrentSpeedKmHour() > 1 then
		menu:addSlice(getText("ContextMenu_VehicleMechanicsStopCar"), getTexture("media/ui/vehicles/vehicle_repair.png"), nil, player, vehicle)
	else
		menu:addSlice(getText("ContextMenu_VehicleMechanics"), getTexture("media/ui/vehicles/vehicle_repair.png"), ISVehicleMenu.onMechanic, player, vehicle)
	end
end)

VehicleMenuAPI.registerSlice("Sleep", function(menu, player, vehicle)
	if (not isClient() or getServerOptions():getBoolean("SleepAllowed")) then
		local doSleep = true
		local sleepNeeded = not isClient() or getServerOptions():getBoolean("SleepNeeded")

		local isZombies = player:getStats():getNumVisibleZombies() > 0 or player:getStats():getNumChasingZombies() > 0 or player:getStats():getNumVeryCloseZombies() > 0
		if sleepNeeded and (player:getStats():getFatigue() <= 0.3) then
			menu:addSlice(getText("IGUI_Sleep_NotTiredEnough"), getTexture("media/ui/vehicles/vehicle_sleep.png"), nil, player, vehicle)
			doSleep = false
		elseif not vehicle:isStopped() then
			menu:addSlice(getText("IGUI_PlayerText_CanNotSleepInMovingCar"), getTexture("media/ui/vehicles/vehicle_sleep.png"), nil, player, vehicle)
			doSleep = false
		elseif sleepNeeded and isZombies then
			menu:addSlice(getText("IGUI_Sleep_NotSafe"), getTexture("media/ui/vehicles/vehicle_sleep.png"), nil, player, vehicle)
			doSleep = false
		else
			if sleepNeeded and ((player:getHoursSurvived() - player:getLastHourSleeped()) <= 1) then
				-- cant go right back to sleep even with pills (sleeping pill exploit)
				menu:addSlice(getText("ContextMenu_NoSleepTooEarly"), getTexture("media/ui/vehicles/vehicle_sleep.png"), nil, player, vehicle)
				doSleep = false
				-- Sleeping pills counter those sleeping problems
			elseif player:getSleepingTabletEffect() < 2000 then
				-- In pain, can still sleep if really tired
				if player:getMoodles():getMoodleLevel(MoodleType.Pain) >= 2 and player:getStats():getFatigue() <= 0.85 then
					menu:addSlice(getText("ContextMenu_PainNoSleep"), getTexture("media/ui/vehicles/vehicle_sleep.png"), nil, player, vehicle)
					doSleep = false
					-- In panic
				elseif player:getMoodles():getMoodleLevel(MoodleType.Panic) >= 1 then
					menu:addSlice(getText("ContextMenu_PanicNoSleep"), getTexture("media/ui/vehicles/vehicle_sleep.png"), nil, player, vehicle)
					doSleep = false
					-- tried to sleep not so long ago
				end
			end
		end
		if doSleep then
			menu:addSlice(getText("ContextMenu_Sleep"), getTexture("media/ui/vehicles/vehicle_sleep.png"), ISVehicleMenu.onSleep, player, vehicle);
		end
	end
end)

VehicleMenuAPI.registerSlice("ExitVehicle", function(menu, player, vehicle)
	menu:addSlice(getText("IGUI_ExitVehicle"), getTexture("media/ui/vehicles/vehicle_exit.png"), ISVehicleMenu.onExit, player)
end)

--Outside--
VehicleMenuAPI.registerSliceOutside("Mechanics", function(menu, player, vehicle)
	menu:addSlice(getText("ContextMenu_VehicleMechanics"), getTexture("media/ui/vehicles/vehicle_repair.png"), ISVehicleMenu.onMechanic, player, vehicle)
end)

VehicleMenuAPI.registerSliceOutside("AnimalTrailer", function(menu, player, vehicle)
	if vehicle:getAnimalTrailerSize() > 0 then
		local doorOpen = true;
		local trunkDoor = vehicle:getPartById("TrunkDoor") or vehicle:getPartById("DoorRear") or vehicle:getPartById("TrunkDoorOpened")
		if trunkDoor and trunkDoor:getDoor() then
			if not trunkDoor:getDoor():isOpen() then doorOpen = false end
		end
		if doorOpen then
			menu:addSlice(getText("ContextMenu_CheckAnimalInsideTrailer"), getTexture("media/ui/Item_SheepWhite_Lamb.png"), ISVehicleMenu.onCheckAnimalInside, vehicle, player)
		end
	end
end)

VehicleMenuAPI.registerSliceOutside("EnterVehicle", function(menu, player, vehicle)
	if vehicle:getScript() and vehicle:getScript():getPassengerCount() > 0 then
		menu:addSlice(getText("IGUI_EnterVehicle"), getTexture("media/ui/vehicles/vehicle_changeseats.png"), ISVehicleMenu.onShowSeatUI, player, vehicle)
	end
end)

VehicleMenuAPI.registerSliceOutside("Fuel", function(menu, player, vehicle)
	ISVehicleMenu.FillPartMenu(player:getPlayerNum(), nil, menu, vehicle)
end)

VehicleMenuAPI.registerSliceOutside("OpenCloseLock", function(menu, player, vehicle)
	local doorPart = vehicle:getUseablePart(player)
	if doorPart and doorPart:getDoor() and doorPart:getInventoryItem() then
		local isHood = doorPart:getId() == "EngineDoor"
		local isTrunk = doorPart:getId() == "TrunkDoor" or doorPart:getId() == "DoorRear"
		if doorPart:getDoor():isOpen() then
			local label = "ContextMenu_Close_door"
			if isHood then label = "IGUI_CloseHood" end
			if isTrunk then label = "IGUI_CloseTrunk" end
			menu:addSlice(getText(label), getTexture("media/ui/vehicles/vehicle_exit.png"), ISVehicleMenu.onCloseDoor, player, doorPart)
		else
			local label = "ContextMenu_Open_door"
			if isHood then label = "IGUI_OpenHood" end
			if isTrunk then label = "IGUI_OpenTrunk" end
			menu:addSlice(getText(label), getTexture("media/ui/vehicles/vehicle_exit.png"), ISVehicleMenu.onOpenDoor, player, doorPart)
			if vehicle:canUnlockDoor(doorPart, player) then
				label = "ContextMenu_UnlockDoor"
				if isHood then label = "IGUI_UnlockHood" end
				if isTrunk then label = "IGUI_UnlockTrunk" end
				menu:addSlice(getText(label), getTexture("media/ui/vehicles/vehicle_lockdoors.png"), ISVehicleMenu.onUnlockDoor, player, doorPart)
			elseif vehicle:canLockDoor(doorPart, player) then
				label = "ContextMenu_LockDoor"
				if isHood then label = "IGUI_LockHood" end
				if isTrunk then label = "IGUI_LockTrunk" end
				menu:addSlice(getText(label), getTexture("media/ui/vehicles/vehicle_lockdoors.png"), ISVehicleMenu.onLockDoor, player, doorPart)
			end
		end
	end
end)

VehicleMenuAPI.registerSliceOutside("SmashWindow", function(menu, player, vehicle)
	local part = vehicle:getClosestWindow(player);
	if part then
		local window = part:getWindow()
		if window:isHittable() then
			menu:addSlice(getText("ContextMenu_Vehicle_Smashwindow", getText("IGUI_VehiclePart" .. part:getId())),
				getTexture("media/ui/vehicles/vehicle_smash_window.png"),
				ISVehiclePartMenu.onSmashWindow, player, part)
		end
	end
end)

VehicleMenuAPI.registerSliceOutside("Towing", function(menu, player, vehicle)
	ISVehicleMenu.doTowingMenu(player, vehicle, menu)
end)

--local function onExample(player)
--	player:Say("This is a custom slice!")
--end
--
--local function exampleFunction(menu, player, vehicle)
--	menu:addSlice("What's This?", getTexture("media/ui/emotes/shrug.png"), onExample, player)
--end
--
--VehicleMenuAPI.registerSlice("example", exampleFunction)

return VehicleMenuAPI
