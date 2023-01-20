local function fastMove(key)
    local pl = getPlayer()
    if pl ~= nil then
        if pl:getModData()["AUD_FASTMOVE"] then
            local x = pl:getX()
            local y = pl:getY()
            local isKeyPressed = false
            local vec = pl:getForwardDirection()

            if not isCtrlKeyDown() then
                if key == Keyboard.KEY_UP then 
                    x = x - 1
                    y = y - 1
                    vec:set(-1, -1)
                    isKeyPressed = true
                elseif key == Keyboard.KEY_DOWN then 
                    x = x + 1
                    y = y + 1
                    vec:set(1, 1)
                    isKeyPressed = true
                elseif key == Keyboard.KEY_LEFT then 
                    x = x - 1
                    y = y + 1
                    vec:set(-1, 1)
                    isKeyPressed = true
                elseif key == Keyboard.KEY_RIGHT then 
                    x = x + 1
                    y = y - 1
                    vec:set(1, -1)
                    isKeyPressed = true
                end

                if isKeyPressed then
                    pl:setX(x)
                    pl:setY(y)
                    pl:setLx(x)
                    pl:setLy(y)
                end   
            end
        end
    end
end

Events.OnKeyKeepPressed.Add(fastMove)


local function upDown(key)
    local pl = getPlayer()
    if pl ~= nil then
        if pl:getModData()["AUD_FASTMOVE"] then
            local z = pl:getZ()
            local isKeyPressed = false

            if isCtrlKeyDown() then
                if key == Keyboard.KEY_UP then 
                    z = z + 1
                    isKeyPressed = true
                elseif key == Keyboard.KEY_DOWN then 
                    z = z - 1
                    if z < 0 then z = 0 end
                    isKeyPressed = true
                end

                if isKeyPressed then
                    pl:setZ(z)
                    pl:setLz(z)
                end
            end
        end
    end
end

Events.OnKeyStartPressed.Add(upDown)