require "DebugUIs/DebugContextMenu"
local Zombies = require "CommunityDebugTools/Commands/Zombies"
local Bodies = require "CommunityDebugTools/Commands/Bodies"

---Restructures the Zombies debug submenu and adds a Bodies submenu after it.

function DebugContextMenu.GetAllDeadBodies(playerObj) return Bodies.getAll(playerObj) end
function DebugContextMenu.OnRemoveAllCorpses(playerObj) Bodies.removeAll(playerObj) end
function DebugContextMenu.OnReanimateAllCorpses(playerObj) Bodies.reanimateAll(playerObj) end

function DebugContextMenu.OnBringCorpsesToMe(playerObj, square)
	Bodies.moveAllTo(playerObj, square)
	ISInventoryPage.renderDirty = true
end

function DebugContextMenu.OnKillAllZombies()
	Zombies.killAll()
	DebugContextMenu.selectedZombie = nil
end

function DebugContextMenu.OnUnselectZombie() DebugContextMenu.selectedZombie = nil end


local doDebugZombieMenu = DebugContextMenu.doDebugZombieMenu
---@param context ISContextMenu
function DebugContextMenu.doDebugZombieMenu(player, context, worldobjects, test, square)
	if DebugContextMenu.selectedZombie and DebugContextMenu.selectedZombie:isDead() then
		DebugContextMenu.selectedZombie = nil
	end

	doDebugZombieMenu(player, context, worldobjects, test, square)

	local playerObj = getSpecificPlayer(player)

	local mainOption = context:getOptionFromName(getText("IGUI_DebugContext_Main"))
	local mainSubmenu = mainOption and mainOption.subOption and context:getSubMenu(mainOption.subOption)
	if mainSubmenu then
		mainSubmenu:removeOptionByName(getText("IGUI_DebugContext_HordeManager"))
	end

	local zombiesOption = context:getOptionFromName(getText("IGUI_DebugContext_Zombies"))
	---@type ISContextMenu
	local zombieSubmenu = zombiesOption and zombiesOption.subOption and context:getSubMenu(zombiesOption.subOption)
	if zombieSubmenu then
		zombieSubmenu:insertOptionAfter(getText("IGUI_DebugContext_RemoveAll"), "Kill All", nil, DebugContextMenu.OnKillAllZombies)
		if DebugContextMenu.selectedZombie then
			zombieSubmenu:addOption("Selected: Unselect", nil, DebugContextMenu.OnUnselectZombie)
		end
	end

	local bodiesOption = context:addOption("Bodies", worldobjects, nil)
	local bodiesSubMenu = ISContextMenu:getNew(context)
	context:addSubMenu(bodiesOption, bodiesSubMenu)

	bodiesSubMenu:addOption("Remove All", playerObj, DebugContextMenu.OnRemoveAllCorpses)
	bodiesSubMenu:addOption("Reanimate All", playerObj, DebugContextMenu.OnReanimateAllCorpses)
	bodiesSubMenu:addOption("Move All (To Cursor)", playerObj, DebugContextMenu.OnBringCorpsesToMe, square)
end
