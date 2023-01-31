require "InitToolBar"

AUDSpawnVehiclePanel = ISPanel:derive("AUDSpawnVehiclePanel")

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)

--************************************************************************--
--** ISPanel:initialise
--**
--************************************************************************--

function AUDSpawnVehiclePanel:initialise()
    ISPanel.initialise(self)
    self:create()
end


function AUDSpawnVehiclePanel:render()
    self:drawText("Spawn vehicle", self.width/2 - (getTextManager():MeasureStringX(UIFont.Medium, "Spawn vehicle") / 2), 20, 1,1,1,1, UIFont.Medium)
    self:drawText("Select and click on tile", self.width/2 - (getTextManager():MeasureStringX(UIFont.Small, "Select and click on tile") / 2), self.categoryOptions:getBottom() + 10, 1,1,1,1, UIFont.Small)
end


function AUDSpawnVehiclePanel:create()
    local scripts = getScriptManager():getAllVehicleScripts()
	local sorted = {}
	for i=1, scripts:size() do
		local script = scripts:get(i-1)
		table.insert(sorted, script)
	end
    table.sort(sorted, function(a,b) return not string.sort(a:getName(), b:getName()) end)

    self.burntVehs = {}
    self.normalVehs = {}
    self.ModuleVehs = {}

	for _,script in ipairs(sorted) do
        if script:getPartCount() == 0 then
            table.insert(self.burntVehs, script)
		else
			table.insert(self.normalVehs, script)
        end
        
        if self.ModuleVehs[script:getModule():getName()] == nil then
            self.ModuleVehs[script:getModule():getName()] = {}
        end

        table.insert(self.ModuleVehs[script:getModule():getName()], script)
    end
    
    self.ModuleVehsList = {}
    for _, val in pairs(self.ModuleVehs) do table.insert(self.ModuleVehsList, val) end

    self.combo = ISComboBox:new(10, 70, 100, FONT_HGT_SMALL + 3 * 2, nil,nil)
    self.combo:initialise()
    self:addChild(self.combo)

    self.categoryOptions = ISRadioButtons:new(10, 120, 200, 200, self, AUDSpawnVehiclePanel.populateComboList)
    self.categoryOptions:initialise()
    self.categoryOptions.autoWidth = true
    self:addChild(self.categoryOptions)
    
    self.categoryOptions:addOption("Burnt")
    self.categoryOptions:addOption("Normal")

    for i=1, #self.ModuleVehsList do self.categoryOptions:addOption(self.ModuleVehsList[i][1]:getModule():getName()) end

    self.categoryOptions:setSelected(2)

    self:populateComboList()

    local btnWid = 100
    local btnHgt = math.max(25, FONT_HGT_SMALL + 3 * 2)
    local padBottom = 30

    self.ok = ISButton:new((self:getWidth() / 2) - 100 - 5, self.categoryOptions:getBottom() + padBottom, btnWid, btnHgt, "Select", self, AUDSpawnVehiclePanel.onOptionMouseDown)
    self.ok.internal = "SELECT"
    self.ok:initialise()
    self.ok:instantiate()
    self.ok.borderColor = {r=1, g=1, b=1, a=0.1}
    self:addChild(self.ok)

    self.cancel = ISButton:new((self:getWidth() / 2) + 5, self.ok:getY(), btnWid, btnHgt, getText("UI_Cancel"), self, AUDSpawnVehiclePanel.onOptionMouseDown)
    self.cancel.internal = "CANCEL"
    self.cancel:initialise()
    self.cancel:instantiate()
    self.cancel.borderColor = {r=1, g=1, b=1, a=0.1}
    self:addChild(self.cancel)

    self:setHeight(self.cancel:getBottom() + padBottom)
end

function AUDSpawnVehiclePanel:populateComboList()
    self.combo:clear()
    local list = {}

    if self.categoryOptions:isSelected(1) then
        list = self.burntVehs
    elseif self.categoryOptions:isSelected(2) then
        list = self.normalVehs
    end

    for i=1, #self.ModuleVehsList do
        if self.categoryOptions:isSelected(2 + i) then
            list = self.ModuleVehsList[i]
        end
    end
    self.selectedVehList = list
    
    local tooltipMap = {}
    for _,v in ipairs(list) do
        self.combo:addOption(v:getName())
        tooltipMap[v:getName()] = getText("IGUI_VehicleName" .. v:getName())
    end
    self.combo:setToolTipMap(tooltipMap)
    self.combo:setWidthToOptions()
end

function AUDSpawnVehiclePanel:onOptionMouseDown(button, x, y)
    if button.internal == "SELECT" then
        if self.onclick ~= nil then
            AUD.Config.isSpawnVehicle = true
            AUD.Config.spawnVehicleScript = self.selectedVehList[self.combo.selected]
        end
    end
    if button.internal == "CANCEL" then
        AUD.Config.isSpawnVehicle = false
        self:setVisible(false)
        self:removeFromUIManager()
    end
end

function AUDSpawnVehiclePanel:new(x, y, width, height, target, onclick)
    local o = {}
    o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.variableColor={r=0.9, g=0.55, b=0.1, a=1}
    o.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
    o.backgroundColor = {r=0, g=0, b=0, a=0.8}
    o.target = target
    o.onclick = onclick
    o.character = getPlayer()
    o.comboList = {}
    o.zOffsetSmallFont = 25
    o.moveWithMouse = true
    return o
end
