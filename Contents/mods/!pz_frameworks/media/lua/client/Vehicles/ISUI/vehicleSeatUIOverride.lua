require "Vehicles/ISUI/ISVehicleSeatUI"
require "Vehicles/ISUI/ISVehicleMenu"

--- This file creates a dynamic UI for the SeatUI to:
--- 1. support 4k or larger resolutions.
--- 2. adapt the UI to vehicles with less conventional seating.

ISVehicleSeatUI.SeatScale = ISVehicleSeatUI.SeatScale or {}--soft protection for copies of this file in potential circulation
ISVehicleSeatUI.fonts = {UIFont.Large,UIFont.Medium,UIFont.Small}
ISVehicleSeatUI.fontMeasured = false
ISVehicleSeatUI.fontHeights = {}

function ISVehicleSeatUI.setFontHeights()
    if ISVehicleSeatUI.fontMeasured then return end
    ISVehicleSeatUI.fontMeasured = true
    for _,font in pairs(ISVehicleSeatUI.fonts) do
        ISVehicleSeatUI.fontHeights[font] = getTextManager():getFontHeight(font)
    end
end


function ISVehicleSeatUI.getAdaptiveFontAndSize(sizeY)
    ISVehicleSeatUI.setFontHeights()
    for _,font in pairs(ISVehicleSeatUI.fonts) do
        if ISVehicleSeatUI.fontHeights[font] <= sizeY then
            return font, ISVehicleSeatUI.fontHeights[font]
        end
    end

    return UIFont.NewSmall, getTextManager():getFontHeight(UIFont.NewSmall)
end


local original_ISVehicleMenu_onShowSeatUI = ISVehicleMenu.onShowSeatUI
function ISVehicleMenu.onShowSeatUI(playerObj, vehicle)
    original_ISVehicleMenu_onShowSeatUI(playerObj, vehicle)

    local playerNum = playerObj:getPlayerNum()
    local ui = ISVehicleMenu.seatUI[playerNum]
    if not ui then return end

    local width = getPlayerScreenWidth(playerNum)*0.13
    local height = getPlayerScreenHeight(playerNum)*0.5

    ui:setX((getPlayerScreenLeft(playerNum)+width)/2)
    ui:setY((getPlayerScreenTop(playerNum)+height)/2)

    ui:setWidth(width)
    ui:setHeight(height)

    ui.richText:setWidth(ui:getWidth())

    ui.close:setX((ui:getWidth()-ui.close:getWidth())/2)
    ui.close:setY(ui:getHeight()-ui.close:getHeight()-10)
end


function ISVehicleSeatUI:render()
    ISPanelJoypad.render(self)

    self.mouseOverSeat = nil
    self.mouseOverExit = nil

    if not self.vehicle then return end

    ---@type VehicleScript
    local script = self.vehicle:getScript()
    local scriptName = self.vehicle:getScriptName()

    --figure out the size of the extends for the UI using a bit of math
    local extents = script:getExtents()
    local ratio = extents:x() / extents:z()
    local height = ((self.height) * 0.7)
    local width = (height * ratio)

    local aspect = ISVehicleSeatUI.SeatScale[scriptName] or 1

    --center of UI offset by the extends UI box
    local extendsX = (self.width-width)/2
    local extendsY = (self.height-height)/2

    local props = ISCarMechanicsOverlay.CarList[scriptName]
    local carOverlayTex = props and props.imgPrefix and getTexture("media/ui/vehicles/seatui/"..props.imgPrefix.."base_small.png")
    if carOverlayTex then

        local imageScale = ImageScale[props.imgPrefix] or 1.0
        local imageW, imageH = carOverlayTex:getWidthOrig() * imageScale, carOverlayTex:getHeightOrig() * imageScale

        self:drawTextureScaledUniform(carOverlayTex, (self.width - imageW)/2, (self.height - imageH)/2, imageScale, 1,1,1,1)

        --self:drawRectBorder(extendsX, extendsY, width, height, 0.3, 1.0, 1.0, 1.0)
        --self:drawTextureScaled(carOverlayTex, extendsX, extendsY, width, height, 1,1,1,1)

    else
        self:drawRect(extendsX, extendsY, width, height, 0.8, 0.0, 0.0, 0.0)
        self:drawRectBorder(extendsX, extendsY, width, height, 1.0, 1.0, 1.0, 1.0)
    end


    local playerSeat = self.vehicle:getSeat(self.character)
    local shiftKey = isKeyDown(Keyboard.KEY_LSHIFT) or isKeyDown(Keyboard.KEY_RSHIFT)

    local scaleX, scaleY = width/extents:x(), height/extents:z()

    local sizeX,sizeY = 40*aspect,60*aspect

    local adaptiveFont, adaptiveFontSize = ISVehicleSeatUI.getAdaptiveFontAndSize(sizeY)
    --local previousSeats = {}
    local mouseX, mouseY = self:getMouseX(), self:getMouseY()

    --all seats
    for seat=0,self.vehicle:getMaxPassengers()-1 do
        local pngr = script:getPassenger(seat)
        local posn = pngr:getPositionById("inside")
        --get seat passenger script + inside position

        if posn then

            local offset = posn:getOffset()
            local x = (self:getWidth()/2) - (offset:get(0) * scaleX) - (sizeX/2) + (SeatOffsetX[scriptName] or 0)
            local y = (self:getHeight()/2) - (offset:get(2) * scaleY) - (sizeY/2) + (SeatOffsetY[scriptName] or 0)

            --if seat is being interacted with
            local mouseOver = (mouseX >= x and mouseX < x + sizeX and mouseY >= y and mouseY < y + sizeY)
            local joyPadOver = (self.joyfocus and self.joypadSeat == seat)
            local mouseOrJoyPadOver = mouseOver or joyPadOver

            if mouseOrJoyPadOver then self.mouseOverSeat = seat end

            local fillR, fillG, fillB = 0.0, 0.0, 0.0
            local outlineR, outlineG, outlineB = 0.0, 1.0, 0.0
            local texName = "icon_vehicle_empty.png"
            local textRGB = 1.0
            local canSwitch = false

            if self.vehicle:isSeatOccupied(seat) then
                if self.vehicle:getCharacter(seat) then
                    texName = "icon_vehicle_person.png"
                    fillR, fillG, fillB = 0.5, 0.5, 0.5
                else
                    fillR, fillG, fillB = 1.0, 1.0, 1.0
                    textRGB = 0.0 -- black text on white background
                    texName = "icon_vehicle_stuff.png"
                    if ISVehicleMenu.moveItemsFromSeat(self.character, self.vehicle, seat, false, false) then
                        canSwitch = true
                    else

                    end
                end
                if mouseOrJoyPadOver then outlineR, outlineG, outlineB = 1.0, 0.0, 0.0 end

            elseif self.vehicle:getPartForSeatContainer(seat) and
                    not self.vehicle:getPartForSeatContainer(seat):getInventoryItem() then
                texName = "icon_vehicle_uninstalled.png"
                fillR, fillG, fillB = 0.5, 0.5, 0.5
                if mouseOrJoyPadOver then outlineR, outlineG, outlineB = 1.0, 0.0, 0.0 end
            else
                canSwitch = true
            end

            local seatRGB = 1.0
            if (playerSeat ~= -1) and (playerSeat ~= seat) and not self.vehicle:canSwitchSeat(playerSeat, seat) then
                seatRGB = 0.5
                textRGB = textRGB * 0.5
            end

            local seatUiTexture = getTexture("media/ui/vehicles/seatui/" .. texName)
            if seatUiTexture then
                self:drawTextureScaled(seatUiTexture, x, y, sizeX, sizeY, 1.0, seatRGB, seatRGB, seatRGB)
                if aspect <= 0.33 then self:drawRectBorder(x, y, sizeX, sizeY, 1.0, 1.0, 1.0, 1.0) end
            else
                self:drawRect(x, y, sizeX, sizeY, 1.0, fillR, fillG, fillB)
                self:drawRectBorder(x, y, sizeX, sizeY, 1.0, 1.0, 1.0, 1.0)
            end

            if not shiftKey and canSwitch and not self.joyfocus then
                self:drawTextCentre(tostring(seat+1), x + sizeX / 2, y + sizeY / 2 - adaptiveFontSize / 2, textRGB, textRGB, textRGB, 1, adaptiveFont)
            end

            if mouseOrJoyPadOver then self:drawRectBorder(x - 2, y - 2, sizeX + 4, sizeY + 4, 1.0, outlineR, outlineG, outlineB) end

            if canSwitch and self.joyfocus and self.joypadSeat == seat then
                local texBtn = Joypad.Texture.AButton
                local texWBtn,texHBtn = texBtn:getWidthOrig()*aspect,texBtn:getHeightOrig()*aspect
                local xBtn = x + (sizeX/2) - (texWBtn/2)
                local yBtn = y + (sizeY/2) - (texHBtn/2)
                self:drawTextureScaledUniform(texBtn, xBtn, yBtn, aspect, 1,1,1,1)
            end
        end

        -- Display available exits when inside.
        if playerSeat ~= -1 then
            local canSwitch = self.vehicle:canSwitchSeat(playerSeat, seat)
            if self.vehicle:isSeatOccupied(seat) then
                canSwitch = false
                -- if you can't switch because of item we check you can still move them
                if not self.vehicle:getCharacter(seat) then
                    canSwitch = ISVehicleMenu.moveItemsFromSeat(self.character, self.vehicle, seat, false, false)
                end
            end

            if playerSeat == seat then canSwitch = true end

            self.vehicle:updateHasExtendOffsetForExit(self.character)

            if self.vehicle:isExitBlocked(self.character, seat) then canSwitch = false end

            self.vehicle:updateHasExtendOffsetForExitEnd(self.character)

            posn = pngr:getPositionById("outside")

            if canSwitch and posn then
                local offset = posn:getOffset()

                local joyPadInUse = self.joyfocus and self.joypadSeat == seat

                local buttonTexture = joyPadInUse and Joypad.Texture.XButton or getTexture("media/ui/vehicles/vehicle_exit.png")
                local texW,texH = buttonTexture:getWidthOrig()*aspect,buttonTexture:getHeightOrig()*aspect
                local x = self:getWidth() / 2 - offset:get(0) * scaleX - texW / 2 + (SeatOffsetX[scriptName] or 0)
                local y = self:getHeight() / 2 - offset:get(2) * scaleY - texH / 2 + (SeatOffsetY[scriptName] or 0)

                local mouseOver = not joyPadInUse and (mouseX >= x and mouseX < x + texW and mouseY >= y and mouseY < y + texH) or joyPadInUse
                if mouseOver then self.mouseOverExit = seat end

                self:drawTextureScaledUniform(buttonTexture, x, y, aspect, 1,1,1,1)

                if not joyPadInUse and shiftKey then
                    self:drawRect(x + texW / 2 - 8, y + texH / 2 - adaptiveFontSize / 2, 16, adaptiveFontSize, 1, 0.1, 0.1, 0.1)
                    self:drawTextCentre(tostring(seat+1), x + texW / 2, y + texH / 2 - adaptiveFontSize / 2, 1, 1, 1, 1, adaptiveFont)
                end

            end
        end
    end
end