require("AUD/Init")
AUD.MainTabTable = {}

AUDMainTab = ISPanelJoypad:derive("AUDMainTab")

function AUDMainTab:initialise()
    ISPanelJoypad.initialise(self);

    self:instantiate()
    self:setAnchorRight(true)
    self:setAnchorLeft(true)
    self:setAnchorTop(true)
    self:setAnchorBottom(true)
    self:noBackground()
    self:setScrollChildren(true)
    self:addScrollBars()

    self.borderColor = {r=0, g=0, b=0, a=0};

    local x = AUD.Config.Buttons.LeftIndent
    local y =  AUD.Config.Buttons.TopIndent
    local yStep = AUD.Config.Buttons.VerticalStep

    AUD.MainTabTable.addGodMode(self, x, y, AUD.Config.Buttons.Width, AUD.Config.Buttons.Height)
    AUD.MainTabTable.addGhostMode(self, x, y + yStep, AUD.Config.Buttons.Width, AUD.Config.Buttons.Height)
    AUD.MainTabTable.addNoClip(self, x, y + yStep*2, AUD.Config.Buttons.Width, AUD.Config.Buttons.Height)
    AUD.MainTabTable.addDebugScenarioRestart(self, x, y + yStep*3, AUD.Config.Buttons.Width, AUD.Config.Buttons.Height)
    AUD.MainTabTable.addFastMoving(self, x, y + yStep*4, AUD.Config.Buttons.Width, AUD.Config.Buttons.Height)
end


function AUD.MainTabTable.addGodMode(UIElement, x, y, width, height)
    local func = function(target, self)
        local pl = getPlayer()
        if pl:isGodMod() then
            pl:setGodMod(false)
            self.backgroundColor = AUD.Config.Buttons.RED
        else
            pl:setGodMod(true)
            self.backgroundColor = AUD.Config.Buttons.GREEN
        end
        self:update()
    end

    local btn = ISButton:new(x, y, width, height, "God Mode", nil, func);
    if getPlayer():isGodMod() then
        btn.backgroundColor = AUD.Config.Buttons.GREEN
    else
        btn.backgroundColor = AUD.Config.Buttons.RED
    end

    UIElement:addChild(btn);
end

function AUD.MainTabTable.addGhostMode(UIElement, x, y, width, height)
    local func = function(target, self)
        local pl = getPlayer()
        if pl:isGhostMode() then
            pl:setGhostMode(false)
            self.backgroundColor = AUD.Config.Buttons.RED
        else
            pl:setGhostMode(true)
            self.backgroundColor = AUD.Config.Buttons.GREEN
        end
        self:update()
    end

    local btn = ISButton:new(x, y, width, height, "Ghost Mode", nil, func);
    if getPlayer():isGhostMode() then
        btn.backgroundColor = AUD.Config.Buttons.GREEN
    else
        btn.backgroundColor = AUD.Config.Buttons.RED
    end

    UIElement:addChild(btn);
end

function AUD.MainTabTable.addNoClip(UIElement, x, y, width, height)
    local func = function(target, self)
        local pl = getPlayer()
        if pl:isNoClip() then
            pl:setNoClip(false)
            self.backgroundColor = AUD.Config.Buttons.RED
        else
            pl:setNoClip(true)
            self.backgroundColor = AUD.Config.Buttons.GREEN
        end
        self:update()
    end

    local btn = ISButton:new(x, y, width, height, "NoClip", nil, func);
    if getPlayer():isNoClip() then
        btn.backgroundColor = AUD.Config.Buttons.GREEN
    else
        btn.backgroundColor = AUD.Config.Buttons.RED
    end

    UIElement:addChild(btn);
end

function AUD.MainTabTable.addDebugScenarioRestart(UIElement, x, y, width, height)
    local func = function(target, self)
        if getDebugOptions():getBoolean("DebugScenario.ForceLaunch") then
            getDebugOptions():setBoolean("DebugScenario.ForceLaunch", false)
            self.backgroundColor = AUD.Config.Buttons.RED
        else
            getDebugOptions():setBoolean("DebugScenario.ForceLaunch", true)
            self.backgroundColor = AUD.Config.Buttons.GREEN
        end
        self:update()
    end

    local btn = ISButton:new(x, y, width, height, "Debug Scen.Restart", nil, func);
    if getDebugOptions():getBoolean("DebugScenario.ForceLaunch") then
        btn.backgroundColor = AUD.Config.Buttons.GREEN
    else
        btn.backgroundColor = AUD.Config.Buttons.RED
    end

    UIElement:addChild(btn);
end

function AUD.MainTabTable.addFastMoving(UIElement, x, y, width, height)
    local func = function(target, self)
        local pl = getPlayer()
        if pl:getModData()["AUD_FASTMOVE"] then
            pl:getModData()["AUD_FASTMOVE"] = false
            self.backgroundColor = AUD.Config.Buttons.RED
        else
            pl:getModData()["AUD_FASTMOVE"] = true
            self.backgroundColor = AUD.Config.Buttons.GREEN
        end
        self:update()
    end

    local btn = ISButton:new(x, y, width, height, "Fast Move", nil, func);
    if getPlayer():getModData()["AUD_FASTMOVE"] then
        btn.backgroundColor = AUD.Config.Buttons.GREEN
    else
        btn.backgroundColor = AUD.Config.Buttons.RED
    end

    UIElement:addChild(btn);
end