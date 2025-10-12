---Hook to the left bar UI which has the inventory, health, etc and replace the debug icon with our own button
require "ISUI/ISEquippedItem"
local ISEquippedItem_new = ISEquippedItem.new
function ISEquippedItem:new(x, y, width, height, chr)
    local o = ISEquippedItem_new(self, x, y, width, height, chr)
    -- replace debug icon with our own button texture
    o.debugIconOff = getTexture("media/textures/_mainMenuButton_Off.png")
    o.debugIconOn = getTexture("media/textures/_mainMenuButton_On.png")
    return o
end

---Resize the debug menu icon to be a bit bigger and adjust its position
local ISEquippedItem_initialise = ISEquippedItem.initialise
function ISEquippedItem:initialise()
    ISEquippedItem_initialise(self)
    if self.debugBtn then
        -- move position
        self.debugBtn:setX(self.debugBtn:getX()-3)
        self.debugBtn:setY(self.debugBtn:getY()+5)
        self.debugBtn:forceImageSize(40, 40) -- resize icon
    end
end