---Soft patch protection for B42.16+
if not ISAdminPowerUI then return end

-- init persistentData
ISAdminPowerUI.persistentData = ISAdminPowerUI.persistentData or {}

---Override initialise to:
--- Reassign tickbox changeOptionTarget to themselves
--- Hide the Save button (changes are now applied instantly on tick)
--- Center the Close button in place of where both buttons used to be
local _original_initialise = ISAdminPowerUI.initialise
function ISAdminPowerUI:initialise()
    _original_initialise(self)
    self.tickBoxLeft.changeOptionTarget  = self.tickBoxLeft
    self.tickBoxRight.changeOptionTarget = self.tickBoxRight
    self.ok:setVisible(false)
    self.cancel:setX(self:getWidth() / 2 - self.cancel.width / 2)
end

---Applies the change for whichever option was just ticked, then syncs the player.
---@param index integer
---@param selected boolean
function ISAdminPowerUI:onTicked(index, selected)
    local adminPowerUI = self.parent
    if adminPowerUI.player:isDead() then return end
    local setFunction = self == adminPowerUI.tickBoxLeft and adminPowerUI.setFunctionLeft or adminPowerUI.setFunctionRight
    if setFunction[index] then
        setFunction[index](adminPowerUI, selected)
        sendPlayerExtraInfo(adminPowerUI.player)
    end
end

function ISAdminPowerUI:onClick(button)
    if button.internal == "SAVE" or button.internal == "CLOSE" then
        self:setVisible(false)
        self:removeFromUIManager()
    end
end

---Override to save x y position when closed.
---@TODO: save with mod data instead for a persistent save across sessions and Lua reloads?
function ISAdminPowerUI:setVisible(bVisible)
    ISPanel.setVisible(self, bVisible)
    if not bVisible and ISAdminPowerUI.instance then
        ISAdminPowerUI.persistentData = {
            x = ISAdminPowerUI.instance.x,
            y = ISAdminPowerUI.instance.y,
        }
    end
end

---Override to apply x y position.
function ISAdminPowerUI.OnOpenPanel()
    if ISAdminPowerUI.instance==nil then
        local x, y = ISAdminPowerUI.persistentData.x, ISAdminPowerUI.persistentData.y
        ISAdminPowerUI.instance = ISAdminPowerUI:new(x, y, 212 + (getCore():getOptionFontSizeReal() * 35), 350, getPlayer())
        ISAdminPowerUI.instance:initialise()
    end
    ISAdminPowerUI.instance:addToUIManager()
    ISAdminPowerUI.instance:setVisible(true)
    return ISAdminPowerUI.instance
end