require "DebugUIs/DebugMenu/GlobalModData/GlobalModData"
local GlobalModData = require "CommunityDebugTools/Commands/GlobalModData"

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local UI_BORDER_SPACING = 10
local BUTTON_HGT = FONT_HGT_SMALL + 6

local GlobalModDataDebug_createChildren = GlobalModDataDebug.createChildren
function GlobalModDataDebug:createChildren()
	GlobalModDataDebug_createChildren(self)
	if not isClient() then return end
	local y, obj = ISDebugUtils.addButton(self,"server",UI_BORDER_SPACING+1,self.height-BUTTON_HGT-UI_BORDER_SPACING-1, 180, BUTTON_HGT, "View: Client", GlobalModDataDebug.onClickServer)
	self.serverButton = obj
end

function GlobalModDataDebug:onClickServer()
	self.viewServer = not self.viewServer
	self.serverButton:setTitle(self.viewServer and "View: Server" or "View: Client")
	self:populateList()
end

local GlobalModDataDebug_populateList = GlobalModDataDebug.populateList
function GlobalModDataDebug:populateList()
	if not self.viewServer then return GlobalModDataDebug_populateList(self) end
	self.tableNamesList:clear()
	self.infoList:clear()
	self.infoList:addItem("Requesting server table names...", nil)
	GlobalModData.requestNames()
end

local GlobalModDataDebug_populateInfoList = GlobalModDataDebug.populateInfoList
function GlobalModDataDebug:populateInfoList(_name)
	if not self.viewServer then return GlobalModDataDebug_populateInfoList(self, _name) end
	self.infoList:clear()
	if not _name then
		self.infoList:addItem("No data.", nil)
		return
	end
	self.serverTableName = _name
	self.infoList:addItem("Requesting server table...", nil)
	GlobalModData.requestTable(_name)
end

GlobalModData.onNames = function(args)
	local self = GlobalModDataDebug.instance
	if not (self and self.viewServer) then return end
	self.tableNamesList:clear()
	local names = args.names or {}
	if #names == 0 then
		self.infoList:clear()
		self.infoList:addItem("No data.", nil)
		return
	end
	for _,name in ipairs(names) do
		self.tableNamesList:addItem(name, name)
	end
	self.tableNamesList.selected = 1
	self:populateInfoList(names[1])
end

GlobalModData.onTable = function(args)
	local self = GlobalModDataDebug.instance
	if not (self and self.viewServer) or args.name ~= self.serverTableName then return end
	self.infoList:clear()
	if not args.found then
		self.infoList:addItem("Table not found.", nil)
		return
	end
	if not args.lines or #args.lines == 0 then
		self.infoList:addItem("Table is empty.", nil)
		return
	end
	for _,line in ipairs(args.lines) do
		self.infoList:addItem(line, nil)
	end
end
