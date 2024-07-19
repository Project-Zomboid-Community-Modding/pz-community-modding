require "ISUI/ISPanel"
require "InitToolBar"



isoObjectInspect = ISPanel:derive("isoObjectInspect")
isoObjectInspect.instance = nil
isoObjectInspect.dataListObj = {}
isoObjectInspect.dataListName = {}

function isoObjectInspect.OnOpenPanel(obj, name)

    local toSelect = 1
    if not isoObjectInspect.dataListName[obj] then
        table.insert(isoObjectInspect.dataListObj, obj)
        toSelect = #isoObjectInspect.dataListObj
        isoObjectInspect.dataListName[obj] = name
    else
        for index,storedObj in pairs(isoObjectInspect.dataListObj) do if storedObj == obj then toSelect = index end end
    end

    if isoObjectInspect.instance==nil then
        isoObjectInspect.instance = isoObjectInspect:new(100, 100, 840, 640, "Inspect")
        isoObjectInspect.instance:initialise()
        isoObjectInspect.instance:instantiate()
    end

    isoObjectInspect.instance.tableNamesList.selected = toSelect
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

    self.junk, self.inspectingTitleHeader = ISDebugUtils.addLabel(self, {}, 15, 8, "Inspecting:", UIFont.Large, true)
    self.inspectingTitleHeader:setColor(0.9,0.9,0.9)

    self.junk, self.inspectingObjectHeader = ISDebugUtils.addLabel(self, {}, self.inspectingTitleHeader:getX()+self.inspectingTitleHeader:getWidth()+10, 10, "", UIFont.Medium, true)
    self.inspectingObjectHeader:setColor(0.8,0.8,0.8)

    self.tableNamesList = ISScrollingListBox:new(10, 65, 150, self.height - 100)
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
    self.junk, self.tableNamesListHeader = ISDebugUtils.addLabel(self, {}, self.tableNamesList:getX()+5, 40, "Objects", UIFont.Medium, true)
    self.tableNamesListHeader:setColor(0.7,0.7,0.7)

    self.modDataList = ISScrollingListBox:new(220, 65, 150, self.height - 100)
    self.modDataList:initialise()
    self.modDataList:instantiate()
    self.modDataList.itemheight = 22
    self.modDataList.selected = 0
    self.modDataList.joypadParent = self
    self.modDataList.font = UIFont.NewSmall
    self.modDataList.doDrawItem = self.drawInfoList
    self.modDataList.drawBorder = true
    self:addChild(self.modDataList)
    self.junk, self.modDataListHeader = ISDebugUtils.addLabel(self, {}, self.modDataList:getX()+5, 40, "ModData", UIFont.Medium, true)
    self.modDataListHeader:setColor(0.7,0.7,0.7)

    self.javaFieldsList = ISScrollingListBox:new(425, 65, 150, self.height - 100)
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
    self.junk, self.javaFieldsHeader = ISDebugUtils.addLabel(self, {}, self.javaFieldsList:getX()+5, 40, "Java Fields", UIFont.Medium, true)
    self.javaFieldsHeader:setColor(0.7,0.7,0.7)

    local w = (self.tableNamesList:getWidth()/2)-5

    local y, button = ISDebugUtils.addButton(self,"refresh",self.tableNamesList:getX(),self.height-30, w,20,"Refresh", isoObjectInspect.onClickRefresh)
    self.refreshButton = button

    y, button = ISDebugUtils.addButton(self,"close",self.tableNamesList:getX()+w+10,self.height-30, w,20, "Close", isoObjectInspect.onClickClose)
    self.closeButton = button

    self:populateNameList()
end


function isoObjectInspect:onClickClose() self:close() end
function isoObjectInspect:onClickRefresh() self:populateNameList() end
function isoObjectInspect:OnTableNamesListMouseDown(item) self:populateNameList() end


function isoObjectInspect:populateNameList()
    local selectedBefore = self.tableNamesList.selected
    self.tableNamesList:clear()
    self.tableNamesList.selected = selectedBefore

    local namesWidth = 150
    local panelsWidth = 300

    local tM = getTextManager()
    for i, obj in pairs(isoObjectInspect.dataListObj) do
        local tsObj = isoObjectInspect.dataListName[obj]
        self.tableNamesList:addItem(tsObj, obj)
        namesWidth = math.max(namesWidth, tM:MeasureStringX(self.tableNamesList.font, tsObj)+35)
    end
    namesWidth = math.min(400, namesWidth)
    self.tableNamesList:setWidth(namesWidth)

    if #isoObjectInspect.dataListObj <= 0 then
        self:populateInfoLists(nil)
    else
        panelsWidth = self:populateInfoLists(isoObjectInspect.dataListObj[self.tableNamesList.selected])
    end

    self:setWidth(panelsWidth+namesWidth+30)

    self.tableNamesListHeader:setX(self.tableNamesList:getX()+5)
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


function isoObjectInspect:parseModData(obj)
    local modDataWidth = 150
    local modData = obj and obj.getModData and obj:getModData()
    if modData then
        modDataWidth = self:recursiveTableParse(modData)
    else
        self.modDataList:addItem("No modData found.", nil)
    end
    return modDataWidth
end


function isoObjectInspect:recursiveTableParse(_t, _ident)
    _ident = _ident or ""
    local tM = getTextManager()
    local stringWidth = 150
    local s
    for k,v in pairs(_t) do
        if type(v)=="table" then
            s = tostring(_ident).."["..tostring(k).."]  =  "
            self.modDataList:addItem(s, nil)
            self:recursiveTableParse(v, _ident.."    ")
        else
            s = tostring(_ident).."["..tostring(k).."]  =  "..tostring(v)
            self.modDataList:addItem(s, nil)
        end
        if s then stringWidth = math.max(stringWidth, tM:MeasureStringX(self.modDataList.font, s)+30) end
    end
    return stringWidth
end


--setOnMouseDownFunction
function isoObjectInspect:onFieldSelected(target, onmousedown)
    local selected = self.javaFieldsList.items[self.javaFieldsList.selected]
    if not selected or not selected.referenceLink then return end
    isoObjectInspect.OnOpenPanel(selected.item, selected.refName)
    --print("selected: "..tostring(selected.text).." = "..tostring(selected.item))
end


function isoObjectInspect:parseFields(obj)
    local tM = getTextManager()
    local stringWidth = 150

    if not obj then return stringWidth end
    local numClassFields = getNumClassFields(obj)

    if numClassFields <= 0 then
        self.javaFieldsList:addItem("No java fields found.", nil)
        return stringWidth
    end

    for i = 0, numClassFields - 1 do
        ---@type Field
        local javaField = getClassField(obj, i)
        if javaField then
            local value = javaField:get(obj)
            local valueAsText = tostring(value)
            local valueType = valueAsText~="nil" and type(value)

            if valueAsText and valueType == "userdata" then
                local reAddListBracket = (string.sub(valueAsText, 1, 1)=="[" and "[") or ""
                local simpleClass = valueAsText:match('[^.]+$')
                valueAsText = simpleClass and simpleClass~=valueAsText and reAddListBracket..simpleClass or valueAsText
                if string.sub(valueAsText, 1, 1)=="[" or string.find(valueAsText,"%$") then valueType = "?" end
            end

            local fieldInfo = javaField:getName().."  =  "..valueAsText..(valueType and " ("..valueType..")" or "")
            stringWidth = math.max(stringWidth, tM:MeasureStringX(self.javaFieldsList.font, fieldInfo)+30)
            local addedItem = self.javaFieldsList:addItem(fieldInfo, value)
            addedItem.referenceLink = valueType=="userdata"
            addedItem.refName = valueAsText
        end
    end
    return stringWidth
end


function isoObjectInspect:populateInfoLists(obj)
    self.modDataList:clear()
    self.javaFieldsList:clear()

    local objectName = obj and isoObjectInspect.dataListName[obj] or ""
    self.inspectingObjectHeader:setName(objectName)

    local modDataWidth = self:parseModData(obj)
    modDataWidth = math.min(400, modDataWidth)
    self.modDataList:setWidth(modDataWidth)
    self.modDataList:setX(self.tableNamesList:getX()+self.tableNamesList:getWidth()+5)

    local fieldWidth = self:parseFields(obj)
    fieldWidth = math.min(400, fieldWidth)
    self.javaFieldsList:setWidth(fieldWidth)
    self.javaFieldsList:setX(self.modDataList:getX()+self.modDataList:getWidth()+5)

    return modDataWidth+fieldWidth
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

function isoObjectInspect:prerender()
    ISPanel.prerender(self)
    if self.modDataList.vscroll and self.modDataList:isVScrollBarVisible() then
        self.modDataList.vscroll:setX(self.modDataList:getWidth()-self.modDataList.vscroll:getWidth())
    end

    if self.javaFieldsList.vscroll and self.javaFieldsList:isVScrollBarVisible() then
        self.javaFieldsList.vscroll:setX(self.javaFieldsList:getWidth()-self.javaFieldsList.vscroll:getWidth())
    end
end

function isoObjectInspect:update()
    ISPanel.update(self)
end

function isoObjectInspect:close()
    self:setVisible(false)
    self:removeFromUIManager()
    --isoObjectInspect.instance = nil
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
