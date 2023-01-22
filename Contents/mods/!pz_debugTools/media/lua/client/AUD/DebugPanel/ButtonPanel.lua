require "AUD/Init"
require "DebugUIs/DebugMenu/ISDebugUtils"
require "DebugUIs/DebugMenu/ISDebugMenu"

ButtonPanelUI = ISPanel:derive("ButtonPanelUI")

function ButtonPanelUI:handleAddButtons(x, y)

    local rows = 1
    local w = AUD.Config.Buttons.Width
    local h = AUD.Config.Buttons.Height
    local yStep = AUD.Config.Buttons.VerticalStep

    self:addButton(function() self:close() end, "Close", nil, x, y+(yStep*(rows+0.75)), w, h)
    self:setHeight((y*2)+(yStep*(rows+1.5)))
end


function ButtonPanelUI:addButton(setFunction, title, specialFuncAndArgs, x, y, width, height)
    local btn = ISButton:new(x, y, width, height, title, nil, setFunction)

    local specialFunc = specialFuncAndArgs and specialFuncAndArgs[1]
    if specialFunc and type(specialFunc) == "function" then
        local args = {btn}
        for i=2, #specialFuncAndArgs do table.insert(args,specialFuncAndArgs[i]) end
        specialFunc(unpack(args))
    end

    self:addChild(btn)
end

function ButtonPanelUI.OnPlayerDeath(playerObj) self:close() end
Events.OnPlayerDeath.Add(ButtonPanelUI.OnPlayerDeath)


function ButtonPanelUI.OnOpenPanel(ui, x, y)

    x = x or ISDebugMenu.instance:getX()+ISDebugMenu.instance:getWidth()+(AUD.Config.Buttons.LeftIndent/2)
    y = y or ISDebugMenu.instance:getY()

    if not ui.instance then

        ui.instance = ui:new(x, y, AUD.Config.Buttons.Width+(AUD.Config.Buttons.LeftIndent*2), 200)
        ui.instance:initialise()
        ui.instance:addToUIManager()
        ui.instance:setVisible(true)

        local titleFont, title = UIFont.Medium, (ui.instance.title or "")
        local titleOffset = getTextManager():MeasureStringX(titleFont, title)
        ISDebugUtils.addLabel(ui.instance, {}, (ui.instance.width+titleOffset)/2, AUD.Config.Buttons.VerticalInterval*1.5, title, titleFont, false)
        ui.instance:handleAddButtons(AUD.Config.Buttons.LeftIndent, AUD.Config.Buttons.TopIndent)
        return
    end

    if ui.instance:getIsVisible() then
        ui.instance:setVisible(false)
        ui.instance:removeFromUIManager()
    else
        ui.instance:setVisible(true)
        ui.instance:addToUIManager()
        ui.instance:setX(x)
        ui.instance:setY(y)
    end
end


function ButtonPanelUI:new(x, y, width, height)
    local o = {}
    o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.x = x
    o.y = y
    o.background = true
    o.backgroundColor = {r=0, g=0, b=0, a=0.5}
    o.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
    o.width = width
    o.height = height
    o.anchorLeft = true
    o.anchorRight = false
    o.anchorTop = true
    o.anchorBottom = false
    o.moveWithMouse = true
    return o
end