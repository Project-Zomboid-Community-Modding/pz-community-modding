--[[

Overrides parts of ISCheatPanelUI to use our own ISTickBoxCheatPanel, to customize the UI in a nicer way.
This is basically a code rewrite of the previous method from the B41 version of the mod which broke in B42.12.0

It goes in pair with ISTickBoxCheatPanel.lua

]]--

---CACHE VALUES
local ISTickBoxCheatPanel = require "ISUI/ISTickBoxCheatPanel"
local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)
local UI_BORDER_SPACING = 10
local BUTTON_HGT = FONT_HGT_SMALL + 6

-- init persistentData
ISCheatPanelUI.persistentData = ISCheatPanelUI.persistentData or {}

---Override to replace with our own ISTickBox (ISTickBoxCheatPanel) and change a bit the close button
function ISCheatPanelUI:initialise()
    ISPanel.initialise(self)
    local btnWid = 100

    -- button is now "Close" instead of "Save" and changed its color
    self.ok = ISButton:new((self:getWidth()-btnWid)/2, self:getHeight() - UI_BORDER_SPACING - BUTTON_HGT - 1, btnWid, BUTTON_HGT, getText("IGUI_RadioClose"), self, ISCheatPanelUI.onClick)
    self.ok.internal = "SAVE"
    self.ok.anchorTop = false
    self.ok.anchorBottom = true
    self.ok:initialise()
    self.ok:instantiate()
    self.ok.borderColor = {r=1, g=1, b=1, a=0.5}
    self.ok.backgroundColor = {r=0.1, g=0.1, b=0.1, a=0.5}
    -- self.ok:enableAcceptColor()
    self:addChild(self.ok)

    -- here we use our custom ISTickBoxCheatPanel
    self.tickBox = ISTickBoxCheatPanel:new(UI_BORDER_SPACING+1, UI_BORDER_SPACING+FONT_HGT_MEDIUM+1, self.width - (UI_BORDER_SPACING+1)*2, BUTTON_HGT, "Admin Powers", self, self.onTicked)
    self.tickBox.choicesColor = {r=1, g=1, b=1, a=1}
    self.tickBox:setFont(UIFont.Small)
    self:addChild(self.tickBox)

    self:addAdminPowerOptions()
end

---Override to save options when changed
---@param index integer
---@param selected boolean
function ISCheatPanelUI:onTicked(index, selected)
    if not self.player:isDead() then
        for i,option in ipairs(ISCheatPanelUI.OptionList) do
            option.player = self.player
            option:setValue(self.tickBox:isSelected(i))
        end
        if isClient() then sendPlayerExtraInfo(self.player) end
    end
    self:saveOptions()
end

---Override to save x y position when closed
function ISCheatPanelUI:setVisible(bVisible)
    -- if hiding and instance exists, save x y position
    ---@TODO: save with mod data instead for a persistent save across sessions and Lua reloads ?
    if not bVisible and ISCheatPanelUI.instance then
        ISCheatPanelUI.persistentData = {
            x = ISCheatPanelUI.instance.x,
            y = ISCheatPanelUI.instance.y,
        }
    end
    if self.javaObject == nil then
		self:instantiate();
	end
	self.javaObject:setVisible(bVisible);
    if self.visibleTarget and self.visibleFunction then
        self.visibleFunction(self.visibleTarget, self);
    end
end

---Override to close and open cheat menu from the ISDebugMenu Cheat button instead of the ok save button
function ISCheatPanelUI.OnOpenPanel()
    -- creates a new instance of non exists
    if not ISCheatPanelUI.instance then
        local x,y = ISCheatPanelUI.persistentData.x, ISCheatPanelUI.persistentData.y
        ISCheatPanelUI.instance = ISCheatPanelUI:new(x, y, 212+(getCore():getOptionFontSizeReal()*35), 350, getPlayer())
        ISCheatPanelUI.instance:initialise()
        ISCheatPanelUI.instance:addToUIManager()
        ISCheatPanelUI.instance:setVisible(true)

    -- hide instance if already open
    else
        ISCheatPanelUI.instance:setVisible(false)
        ISCheatPanelUI.instance:removeFromUIManager()
        ISCheatPanelUI.instance = nil
    end

    return ISCheatPanelUI.instance
end

---Override to set x y persistent data
function ISCheatPanelUI:new(x, y, width, height, player)
    local o = {}
    x = x or getCore():getScreenWidth() - (width) - 50
    y = y or getCore():getScreenHeight() / 4 - (height / 2)
    o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
    o.backgroundColor = {r=0, g=0, b=0, a=0.7}
    o.width = width
    o.height = height
    o.player = player
    o.moveWithMouse = true
    ISCheatPanelUI.instance = o
    return o
end