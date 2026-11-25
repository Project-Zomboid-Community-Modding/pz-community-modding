--- When adding XP in the playerStats debug window the dropdown list starts at [1] - this makes it jump to the selected skill
require "ISUI/PlayerStats/ISPlayerStatsUI"
local ISPlayerStatsUI_onOptionMouseDown = ISPlayerStatsUI.onOptionMouseDown
function ISPlayerStatsUI:onOptionMouseDown(button, x, y)
	ISPlayerStatsUI_onOptionMouseDown(self, button, x, y)

	if button.internal == "ADDXP" and self.selectedPerk and self.selectedPerk.perk then
		local windows = ISPlayerStatsUI.instance.windows
		local modal = windows[#windows]
		if modal and modal.perkList then
			for n,perk in pairs(modal.perkList) do
				if perk == self.selectedPerk.perk then
					modal.combo.selected = n
				end
			end
		end
	end
end

function ISPlayerStatsUI.findLivePlayer(username)
	for i = 0, getNumActivePlayers() - 1 do
		local player = getSpecificPlayer(i)
		if player and not player:isDead() and player:getUsername() == username then return player end
	end
	local players = isClient() and getOnlinePlayers()
	for i = 0, (players and players:size() or 0) - 1 do
		local player = players:get(i)
		if not player:isDead() and player:getUsername() == username then return player end
	end
end

function ISPlayerStatsUI:rebindDeadPlayers()
	local char = self.char:isDead() and ISPlayerStatsUI.findLivePlayer(self.char:getUsername()) or self.char
	local admin = self.admin:isDead() and ISPlayerStatsUI.findLivePlayer(self.admin:getUsername()) or self.admin
	if char:isDead() or admin:isDead() then return false end
	if char == self.char and admin == self.admin then return false end

	local x, y, w, h = self:getX(), self:getY(), self:getWidth(), self:getHeight()
	self:close()
	local ui = ISPlayerStatsUI:new(x, y, w, h, char, admin)
	ui:initialise()
	ui:addToUIManager()
	ui:setVisible(true)
	return true
end

local ISPlayerStatsUI_prerender = ISPlayerStatsUI.prerender
function ISPlayerStatsUI:prerender()
	if (self.char:isDead() or self.admin:isDead()) and self:rebindDeadPlayers() then return end
	ISPlayerStatsUI_prerender(self)
end
