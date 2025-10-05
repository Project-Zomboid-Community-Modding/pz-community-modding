--- Some debug panels expand beyond certain resolutions + windows don't stay within screen bounds if window size is changed.
require "ISUI/ISUIElement"

function ISUIElement.fitToParent(self, oldW, oldH, newW, newH)

    local scaleW = newW/oldW
    local scaleH = newH/oldH

    self.origW = self.origW or self.width
    self.origH = self.origH or self.height
    self.origX = self.origX or self.x
    self.origY = self.origY or self.y

    self:setX(self.origX*scaleW)
    self:setY(self.origY*scaleH)
    self:setWidth(self.origW*scaleW)
    self:setHeight(self.origH*scaleH)

    local children = self:getChildren()
    if not children then return end
    for _,child in pairs(children) do
        ISUIElement.fitToParent(child, self.origW, self.origH, self.width, self.height)
    end
end

function ISUIElement.fitOnScreen(self)
    if not self or self:getParent() then return end

    self.oldX = self.oldX or self.x
    local maxX = getCore():getScreenWidth()
    self:setX(math.max(0, math.min(self.oldX, maxX - self.width)))

    self.oldY = self.oldY or self.y
    local maxY = getCore():getScreenHeight()
    self:setY(math.max(0, math.min(self.oldY, maxY - self.height)))

    self.oldW = self.oldW or self.width
    local maxW = maxX
    if self.width > maxW then self:setWidth(maxW) end
    if self.oldW < maxW then self:setWidth(self.oldW) end

    self.oldH = self.oldH or self.height
    local maxH = maxY
    if self.height > maxH then self:setHeight(maxH) end
    if self.oldH < maxH then self:setHeight(self.oldH) end

    local children = self:getChildren()
    if not children then return end
    for _,child in pairs(children) do
        ISUIElement.fitToParent(child, self.oldW, self.oldH, self.width, self.height)
    end
end


---@TODO(SirDoggyJvla): this is a function creep in the OnResolutionChange event which will pose problems the more and more ISUIElements are created.
---Until a better solution is found, this is commented out.
---I'm also personally not familiar with the issue this is trying to patch and idk if that's actually a thing

-- local ISUIElement_initialise = ISUIElement.initialise
-- function ISUIElement:initialise()
--     ISUIElement_initialise(self)
--     Events.OnResolutionChange.Add(function() ISUIElement.fitOnScreen(self) end)
-- end