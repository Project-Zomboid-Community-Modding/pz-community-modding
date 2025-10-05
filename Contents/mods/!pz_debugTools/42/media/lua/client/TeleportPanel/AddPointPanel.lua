local AUD = require "InitToolBar"

AddPointPanel = ISPanel:derive("AddPointPanel");

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)


function AddPointPanel:initialise()
    ISPanel.initialise(self);
    self:create();
end


function AddPointPanel:setVisible(visible)
    self.javaObject:setVisible(visible);
end

function AddPointPanel:render()
    self:drawText("Add spawn point", self.width/2 - (getTextManager():MeasureStringX(UIFont.Medium, "Add spawn point") / 2), 20, 1,1,1,1, UIFont.Medium);

    self:drawText("X: ", 55, 55, 1,1,1,1, UIFont.Small);
    self:drawText("Y: ", 55, 85, 1,1,1,1, UIFont.Small);
    self:drawText("Z: ", 55, 115, 1,1,1,1, UIFont.Small);
    self:drawText("Name: ", 30, 145, 1,1,1,1, UIFont.Small);
    self:drawText("Category: ", 15, 175, 1,1,1,1, UIFont.Small);
end

function AddPointPanel:create()
    local btnWid = 100
    local btnHgt = 20
    local padBottom = 30

    self.textEntryX = ISTextEntryBox:new("", self.width/2 - 50, 50, 100, 25);
    self.textEntryX:initialise();
    self.textEntryX:instantiate();
    self.textEntryX:setClearButton(true)
    self:addChild(self.textEntryX);

    self.textEntryY = ISTextEntryBox:new("", self.width/2 - 50, 80, 100, 25);
    self.textEntryY:initialise();
    self.textEntryY:instantiate();
    self.textEntryY:setClearButton(true)
    self:addChild(self.textEntryY);

    self.textEntryZ = ISTextEntryBox:new("", self.width/2 - 50, 110, 100, 25);
    self.textEntryZ:initialise();
    self.textEntryZ:instantiate();
    self.textEntryZ:setClearButton(true)
    self:addChild(self.textEntryZ);

    self.textEntryName = ISTextEntryBox:new("", self.width/2 - 50, 140, 100, 25);
    self.textEntryName:initialise();
    self.textEntryName:instantiate();
    self.textEntryName:setClearButton(true)
    self:addChild(self.textEntryName);

    self.textEntryCategory = ISTextEntryBox:new("", self.width/2 - 50, 170, 100, 25);
    self.textEntryCategory:initialise();
    self.textEntryCategory:instantiate();
    self.textEntryCategory:setClearButton(true)
    self:addChild(self.textEntryCategory);

    self.select = ISButton:new((self:getWidth() / 2) - 150/2, 125 + padBottom + 60, 150, btnHgt, "Select current pos.", self, AddPointPanel.onOptionMouseDown);
    self.select.internal = "SELECT";
    self.select:initialise();
    self.select:instantiate();
    self.select.borderColor = {r=1, g=1, b=1, a=0.1};
    self:addChild(self.select);

    self.add = ISButton:new((self:getWidth() / 2) - 100 - 5, 150 + padBottom + 60, btnWid, btnHgt, "Add", self, AddPointPanel.onOptionMouseDown);
    self.add.internal = "ADD";
    self.add:initialise();
    self.add:instantiate();
    self.add.borderColor = {r=1, g=1, b=1, a=0.1};
    self:addChild(self.add);

    self.cancel = ISButton:new((self:getWidth() / 2) + 5, self.add:getY(), btnWid, btnHgt, getText("UI_Cancel"), self, AddPointPanel.onOptionMouseDown);
    self.cancel.internal = "CANCEL";
    self.cancel:initialise();
    self.cancel:instantiate();
    self.cancel.borderColor = {r=1, g=1, b=1, a=0.1};
    self:addChild(self.cancel);

    self:setHeight(self.cancel:getBottom() + padBottom)
end

function round(num, numDecimalPlaces)
    local mult = 10^(numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
  end

function AddPointPanel:onOptionMouseDown(button, x, y)
    if button.internal == "ADD" then
        local x = tonumber(self.textEntryX:getText())
        local y = tonumber(self.textEntryY:getText())
        local z = tonumber(self.textEntryZ:getText())
        local name = self.textEntryName:getText()
        if x == nil or y == nil or z == nil or name == "" then 
            getPlayer():Say("Incorrect Input")
            return 
        end

        AUD.TeleportTable.All.fileList:addItem(name, {x, y, z})

        local category = self.textEntryCategory:getText()
        if category ~= "" then
            if AUD.TeleportTable[category] == nil then
                AUD.TeleportTable[category] = AUDTeleportTab:new(0, 48, AUD.teleportWindow:getWidth(), AUD.teleportWindow:getHeight() - AUD.teleportWindow.nested.tabHeight)
                AUD.TeleportTable[category]:initialise(category)
                AUD.teleportWindow.nested:addView(category, AUD.TeleportTable[category])    
            end
            AUD.TeleportTable[category].fileList:addItem(name, {x, y, z})
        end

        AUD.teleport:savePoints()

        self.textEntryX:setText("")
        self.textEntryY:setText("")
        self.textEntryZ:setText("")
        self.textEntryName:setText("")
    end
    if button.internal == "SELECT" then
        local pl = getPlayer()
        local x = pl:getX()        
        local y = pl:getY()
        local z = pl:getZ()
        self.textEntryX:setText(tostring(round(x, 2)))
        self.textEntryY:setText(tostring(round(y, 2)))
        self.textEntryZ:setText(tostring(round(z, 2)))
    end
    if button.internal == "CANCEL" then
        self:setVisible(false);
        self:removeFromUIManager();
    end
end

function AddPointPanel:new(x, y, width, height, target, onclick)
    local o = {};
    o = ISPanel:new(x, y, width, height);
    setmetatable(o, self);
    self.__index = self;
    o.variableColor={r=0.9, g=0.55, b=0.1, a=1};
    o.borderColor = {r=0.4, g=0.4, b=0.4, a=1};
    o.backgroundColor = {r=0, g=0, b=0, a=0.8};
    o.target = target;
    o.onclick = onclick;
    o.character = getPlayer();
    o.zOffsetSmallFont = 25;
    o.moveWithMouse = true;
    return o;
end
