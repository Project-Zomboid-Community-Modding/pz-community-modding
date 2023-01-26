require "ISUI/ISPanel"
require "AUD/Init"

isoObjectInspect = ISPanel:derive("isoObjectInspect")
isoObjectInspect.instance = nil
isoObjectInspect.modDataList = {}
isoObjectInspect.modDataListName = {}

function isoObjectInspect.OnOpenPanel(obj, name)

    if not isoObjectInspect.modDataListName[obj] then
        table.insert(isoObjectInspect.modDataList, obj)
        isoObjectInspect.modDataListName[obj] = name
    end

    if isoObjectInspect.instance==nil then
        isoObjectInspect.instance = isoObjectInspect:new (100, 100, 840, 600, "Inspecting:")
        isoObjectInspect.instance:initialise()
        isoObjectInspect.instance:instantiate()
    end

    isoObjectInspect.instance:addToUIManager()
    isoObjectInspect.instance:setVisible(true)
    isoObjectInspect.instance:onClickRefresh()

    return isoObjectInspect.instance
end


function isoObjectInspect:initialise()
    ISPanel.initialise(self)
    self.firstTableData = false
end


function isoObjectInspect:createChildren()
    ISPanel.createChildren(self)

    ISDebugUtils.addLabel(self, {}, 20, 20, "Inspecting:", UIFont.Large, true)

    self.tableNamesList = ISScrollingListBox:new(10, 50, 200, self.height - 100)
    self.tableNamesList:initialise()
    self.tableNamesList:instantiate()
    self.tableNamesList.itemheight = 22
    self.tableNamesList.selected = 0
    self.tableNamesList.joypadParent = self
    self.tableNamesList.font = UIFont.NewSmall
    self.tableNamesList.doDrawItem = self.drawTableNameList
    self.tableNamesList.drawBorder = true
    self.tableNamesList.onmousedown = isoObjectInspect.OnTableNamesListMouseDown
    self.tableNamesList.target = self
    self:addChild(self.tableNamesList)

    self.modDataList = ISScrollingListBox:new(220, 50, 200, self.height - 100)
    self.modDataList:initialise()
    self.modDataList:instantiate()
    self.modDataList.itemheight = 22
    self.modDataList.selected = 0
    self.modDataList.joypadParent = self
    self.modDataList.font = UIFont.NewSmall
    self.modDataList.doDrawItem = self.drawInfoList
    self.modDataList.drawBorder = true
    self:addChild(self.modDataList)
    self.junk, self.modDataListHeader = ISDebugUtils.addLabel(self, {}, self.modDataList:getX()+5, 20, "ModData", UIFont.Medium, true)

    self.javaFieldsList = ISScrollingListBox:new(425, 50, 200, self.height - 100)
    self.javaFieldsList:initialise()
    self.javaFieldsList:instantiate()
    self.javaFieldsList:setOnMouseDownFunction(self, self.onFieldSelected)
    self.javaFieldsList.itemheight = 22
    self.javaFieldsList.selected = 0
    self.javaFieldsList.joypadParent = self
    self.javaFieldsList.font = UIFont.NewSmall
    self.javaFieldsList.doDrawItem = self.drawInfoList
    self.javaFieldsList.drawBorder = true
    self:addChild(self.javaFieldsList)
    self.junk, self.javaFieldsHeader = ISDebugUtils.addLabel(self, {}, self.javaFieldsList:getX()+5, 20, "Java Fields", UIFont.Medium, true)

    local w = (self.tableNamesList:getWidth()/2)-5

    local y, button = ISDebugUtils.addButton(self,"refresh",self.tableNamesList:getX(),self.height-40, w,20,"Refresh", isoObjectInspect.onClickRefresh)
    self.refreshButton = button

    y, button = ISDebugUtils.addButton(self,"close",self.tableNamesList:getX()+w+10,self.height-40, w,20, "Close", isoObjectInspect.onClickClose)
    self.closeButton = button

    self:populateNameList()
end


function isoObjectInspect:onClickClose() self:close() end
function isoObjectInspect:onClickRefresh() self:populateNameList() end
function isoObjectInspect:OnTableNamesListMouseDown(item) self:populateInfoLists(self.tableNamesList.items[self.tableNamesList.selected].item) end


function isoObjectInspect:populateNameList()
    self.tableNamesList:clear()

    if #isoObjectInspect.modDataList == 0 then
        self:populateInfoLists(nil) return
    end

    local stringWidth = 200
    local panelWidth = 240

    local tM = getTextManager()

    for i, obj in pairs(isoObjectInspect.modDataList) do
        local tsObj = isoObjectInspect.modDataListName[obj]
        self.tableNamesList:addItem(tsObj, obj)

        stringWidth = math.max(stringWidth, tM:MeasureStringX(self.tableNamesList.font, tsObj)+35)
    end

    self.tableNamesList:setWidth(stringWidth)
    self:setWidth(panelWidth+stringWidth)

    self.firstTableData=isoObjectInspect.modDataList[1]
    self:populateInfoLists(self.firstTableData)

    if self.modDataList.vscroll and self.modDataList:isVScrollBarVisible() then
        self.modDataList.vscroll:setX(self.modDataList:getWidth()-self.modDataList.vscroll:getWidth())
    end

    if self.javaFieldsList.vscroll and self.javaFieldsList:isVScrollBarVisible() then
        self.javaFieldsList.vscroll:setX(self.javaFieldsList:getWidth()-self.javaFieldsList.vscroll:getWidth())
    end

    self.modDataListHeader:setX(self.modDataList:getX()+5)
    self.javaFieldsHeader:setX(self.javaFieldsList:getX()+5)

    local w = (self.tableNamesList:getWidth()/2)-5

    self.refreshButton:setWidth(w)
    self.refreshButton:setX(self.tableNamesList:getX())

    self.closeButton:setWidth(w)
    self.closeButton:setX(self.tableNamesList:getX()+w+10)
end


function isoObjectInspect:drawTableNameList(y, item, alt)
    local a = 0.9

    self:drawRectBorder(0, (y), self:getWidth(), self.itemheight - 1, a, self.borderColor.r, self.borderColor.g, self.borderColor.b)

    if self.selected == item.index then
        self:drawRect(0, (y), self:getWidth(), self.itemheight - 1, 0.3, 0.7, 0.35, 0.15)
    end

    self:drawText( item.text, 10, y + 2, 1, 1, 1, a, self.font)

    return y + self.itemheight
end


function isoObjectInspect:formatVal(_value, _func, _func2)
    return _func2 and (_func2(_func(_value))) or (_func(_value))
end


function isoObjectInspect:parseTable(_t, _ident)
    if not _ident then _ident = "" end
    local tM = getTextManager()
    local stringWidth = 200
    local s
    for k,v in pairs(_t) do
        if type(v)=="table" then
            s = tostring(_ident).."["..tostring(k).."]  =  "
            self.modDataList:addItem(s, nil)
            self:parseTable(v, _ident.."    ")
        else
            s = tostring(_ident).."["..tostring(k).."]  =  "..tostring(v)
            self.modDataList:addItem(s, nil)
        end
        if s then stringWidth = math.max(stringWidth, tM:MeasureStringX(self.modDataList.font, s)+30) end
    end
    return stringWidth
end

--[[
function isoObjectInspect:onFieldSelected(target, onmousedown)
    local selected = self.javaFieldsList.items[self.javaFieldsList.selected].item
    --isoObjectInspect.OnOpenPanel(selected)
    --print("selected: "..tostring(selected.text).." = "..tostring(selected.item))
end
--]]


function isoObjectInspect:parseFields(obj)
    local tM = getTextManager()
    local stringWidth = 200
    for i = 0, getNumClassFields(obj) - 1 do
        ---@type Field
        local javaField = getClassField(obj, i)
        if javaField then
            local value = javaField:get(obj)
            local valueAsText = tostring(value)
            local valueType = valueAsText~="nil" and type(value)

            if valueAsText and valueType == "userdata" then
                local reAddListBracket = (string.sub(valueAsText, 1, 1)=="[" and "[") or ""
                local simpleClass = valueAsText:match('[^.]+$')
                valueAsText = simpleClass~=valueAsText and reAddListBracket..simpleClass or valueAsText
            end

            local fieldInfo = javaField:getName().."  =  "..valueAsText..(valueType and " ("..valueType..")" or "")
            stringWidth = math.max(stringWidth, tM:MeasureStringX(self.javaFieldsList.font, fieldInfo)+30)
            self.javaFieldsList:addItem(fieldInfo, value)
        end
    end
    return stringWidth
end


function isoObjectInspect:populateInfoLists(obj)
    self.modDataList:clear()
    self.javaFieldsList:clear()

    local modDataWidth = 200

    local modData = obj:hasModData() and obj:getModData()
    if modData then
        modDataWidth = self:parseTable(modData, "")
    else
        self.modDataList:addItem("No modData found.", nil)
    end

    self.modDataList:setWidth(modDataWidth)
    self.modDataList:setX(self.tableNamesList:getX()+self.tableNamesList:getWidth()+5)

    local fieldWidth = self:parseFields(obj)
    self.javaFieldsList:setWidth(fieldWidth)
    self.javaFieldsList:setX(self.modDataList:getX()+self.modDataList:getWidth()+5)

    self:setWidth(self.tableNamesList:getWidth()+30+modDataWidth+fieldWidth)
end


function isoObjectInspect:drawInfoList(y, item, alt)
    local a = 0.9

    self:drawRectBorder(0, (y), self:getWidth(), self.itemheight - 1, a, self.borderColor.r, self.borderColor.g, self.borderColor.b)

    if self.selected == item.index then
        self:drawRect(0, (y), self:getWidth(), self.itemheight - 1, 0.3, 0.7, 0.35, 0.15)
    end

    self:drawText( item.text, 10, y + 2, 1, 1, 1, a, self.font)

    return y + self.itemheight
end

function isoObjectInspect:prerender() ISPanel.prerender(self) end
function isoObjectInspect:update() ISPanel.update(self) end

function isoObjectInspect:close()
    self:setVisible(false)
    self:removeFromUIManager()
    isoObjectInspect.instance = nil
end

function isoObjectInspect:new(x, y, width, height, title)
    local o = {}
    o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.variableColor={r=0.9, g=0.55, b=0.1, a=1}
    o.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
    o.backgroundColor = {r=0, g=0, b=0, a=0.8}
    o.buttonBorderColor = {r=0.7, g=0.7, b=0.7, a=0.5}
    o.zOffsetSmallFont = 25
    o.moveWithMouse = true
    o.panelTitle = title
    ISDebugMenu.RegisterClass(self)
    return o
end
