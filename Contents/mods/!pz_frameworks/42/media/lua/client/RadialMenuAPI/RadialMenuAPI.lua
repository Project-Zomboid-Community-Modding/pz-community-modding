
function ISRadialMenu:getSliceIndex(sliceText)
    for index, slice in ipairs(self.slices) do
        if slice.text == sliceText then
            return index
        end
    end
    return nil
end

function ISRadialMenu:getSliceText(sliceIndex)
    if sliceIndex < 1 or sliceIndex > #self.slices then return end
    return self.slices[sliceIndex].text
end

function ISRadialMenu:getSliceTexture(sliceIndex)
    if sliceIndex < 1 or sliceIndex > #self.slices then return end
    return self.slices[sliceIndex].texture
end

function ISRadialMenu:setSliceCommand(sliceIndex, command, arg1, arg2, arg3, arg4, arg5, arg6)
    if sliceIndex < 1 or sliceIndex > #self.slices then return end
    self.slices[sliceIndex].command = { command, arg1, arg2, arg3, arg4, arg5, arg6 }
end

function ISRadialMenu:display(releaseButton, joypadIgnoreAimUntilCentered)
    releaseButton = releaseButton or self.hideWhenButtonReleased or Joypad.DPadUp
    joypadIgnoreAimUntilCentered = joypadIgnoreAimUntilCentered ~= false
    self:addToUIManager()
    if JoypadState.players[self.playerNum + 1] then
        self:setHideWhenButtonReleased(releaseButton)
        setJoypadFocus(self.playerNum, self)
        getSpecificPlayer(self.playerNum):setJoypadIgnoreAimUntilCentered(joypadIgnoreAimUntilCentered)
    end
end

local function radialBack(menu, oldSlices)
    menu:clear()
    for _, oldSlice in ipairs(oldSlices) do
        menu:addSlice(oldSlice.text, oldSlice.texture, oldSlice.command[1], oldSlice.command[2], oldSlice.command[3], oldSlice.command[4], oldSlice.command[5], oldSlice.command[6], oldSlice.command[7])
    end
    menu:display()
end

function ISRadialMenu:createSubMenu(onSubMenu, args)
    local oldSlices = self.slices
    self:clear()
    onSubMenu(self, args)
    self:addSlice(getText("IGUI_Emote_Back"), getTexture("media/ui/emotes/back.png"), radialBack, self, oldSlices)
    self:display()
end
