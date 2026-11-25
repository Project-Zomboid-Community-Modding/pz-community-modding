local DebugScenarios_createChildren = DebugScenarios.createChildren
function DebugScenarios:createChildren()
	DebugScenarios_createChildren(self)

	self.listbox:clear()
	for k,v in pairs(debugScenarios) do
		if v.isCustom then
			self.listbox:addItem(v.name, k)
		end
	end

	self.traitsSelector = ISTickBox:new(20, self.height - 20, 100, 18, "", self, DebugScenarios.onChangeList)
	self.traitsSelector:initialise()
	self.traitsSelector:instantiate()
	self.traitsSelector:setAnchorLeft(true)
	self.traitsSelector:setAnchorRight(false)
	self.traitsSelector:setAnchorTop(true)
	self.traitsSelector:setAnchorBottom(false)
	self.traitsSelector.selected[1] = false
	self.traitsSelector:addOption("Default scenarios")
	self:addChild(self.traitsSelector)
end

function DebugScenarios:onChangeList()
	if self.traitsSelector.selected[1] then
		self.listbox:clear()
		for k,v in pairs(debugScenarios) do
			self.listbox:addItem(v.name, k)
		end
	else
		self.listbox:clear()
		for k,v in pairs(debugScenarios) do
			if v.isCustom then
				self.listbox:addItem(v.name, k)
			end
		end
	end
end
