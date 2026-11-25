require "DebugUIs/AttachmentEditorUI"
require "ISUI/ISTextBox"

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)

local attachmentEditor = {}

attachmentEditor.bodyScripts = { "FemaleBody", "MaleBody" }
attachmentEditor.propBones = { "Bip01_Prop1", "Bip01_Prop2" }
attachmentEditor.added = {}
attachmentEditor.clipboard = nil
attachmentEditor.autoAttach = true
attachmentEditor.autoParented = {}
attachmentEditor.worldDetached = {}

attachmentEditor.cameraFile = "AttachmentEditorCamera.txt"
attachmentEditor.gridPlanes = {
	{ "XZ", "Floor" },
	{ "XY", "Front" },
	{ "YZ", "Side" },
}
attachmentEditor.gridPlane = 1
attachmentEditor.defaultCamera = { 30, 45, 0 }
attachmentEditor.camera = { 30, 45, 0 }
attachmentEditor.defaultZoom = 10
attachmentEditor.presetAngles = {
	Front = { 0, 0, 0 },
	Back = { 0, 180, 0 },
	Left = { 0, 270, 0 },
	Right = { 0, 90, 0 },
	Top = { 90, 0, 0 },
	Bottom = { -90, 0, 0 },
}
attachmentEditor.quarterViews = {
	{ "3/4 FL", 30, 315 },
	{ "3/4 FR", 30, 45 },
	{ "3/4 BL", 30, 225 },
	{ "3/4 BR", 30, 135 },
}

attachmentEditor.nudgeKeys = {
	[Keyboard.KEY_LEFT] = { 1, -1 },
	[Keyboard.KEY_RIGHT] = { 1, 1 },
	[Keyboard.KEY_DOWN] = { 2, -1 },
	[Keyboard.KEY_UP] = { 2, 1 },
	[Keyboard.KEY_NEXT] = { 3, -1 },
	[Keyboard.KEY_PRIOR] = { 3, 1 },
}

function attachmentEditor.addPropAttachments()
	for _, scriptName in ipairs(attachmentEditor.bodyScripts) do
		local script = getScriptManager():getModelScript(scriptName)
		if script then
			for _, bone in ipairs(attachmentEditor.propBones) do
				if not script:getAttachmentById(bone) then
					local attachment = ModelAttachment.new(bone)
					attachment:setBone(bone)
					script:addAttachment(attachment)
					table.insert(attachmentEditor.added, { script = script, attachment = attachment })
				end
			end
		end
	end
end

function attachmentEditor.detachPropAttachments()
	for _, entry in ipairs(attachmentEditor.added) do
		entry.script:removeAttachment(entry.attachment)
	end
end

function attachmentEditor.reattachPropAttachments()
	for _, entry in ipairs(attachmentEditor.added) do
		if not entry.script:getAttachmentById(entry.attachment:getId()) then
			entry.script:addAttachment(entry.attachment)
		end
	end
end

function attachmentEditor.removePropAttachments()
	attachmentEditor.detachPropAttachments()
	attachmentEditor.added = {}
end

function attachmentEditor.isPropAttachment(attach)
	for _, entry in ipairs(attachmentEditor.added) do
		if entry.attachment == attach then return true end
	end
	return false
end

function attachmentEditor.showStatus(editor, text)
	editor.wroteScriptTime = getTimestampMs() - 2000
	editor.wroteScriptLabel:setName(text)
end

function attachmentEditor.getEditable(editUI)
	local attachments = {}
	for _, attach in ipairs(editUI:getSelectedAttachments()) do
		if attach:getId() ~= "world" then
			table.insert(attachments, attach)
		end
	end
	return attachments
end

function attachmentEditor.copyTransform(editUI)
	local attach = attachmentEditor.getEditable(editUI)[1]
	if not attach then return end
	local offset, rotate = attach:getOffset(), attach:getRotate()
	attachmentEditor.clipboard = {
		id = attach:getId(),
		offset = { offset:x(), offset:y(), offset:z() },
		rotate = { rotate:x(), rotate:y(), rotate:z() },
		scale = attach:getScale(),
	}
	attachmentEditor.showStatus(editUI.parent, "Copied transform of " .. attach:getId())
end

function attachmentEditor.pasteTransform(editUI, offset, rotate, scale)
	local clip = attachmentEditor.clipboard
	if not clip then
		attachmentEditor.showStatus(editUI.parent, "Nothing copied")
		return
	end
	local attachments = attachmentEditor.getEditable(editUI)
	for _, attach in ipairs(attachments) do
		if offset then attach:getOffset():set(clip.offset[1], clip.offset[2], clip.offset[3]) end
		if rotate then attach:getRotate():set(clip.rotate[1], clip.rotate[2], clip.rotate[3]) end
		if scale then attach:setScale(clip.scale) end
	end
	attachmentEditor.showStatus(editUI.parent, "Pasted " .. clip.id .. " onto " .. #attachments .. " attachment(s)")
end

function attachmentEditor.resetTransform(editUI)
	for _, attach in ipairs(attachmentEditor.getEditable(editUI)) do
		attach:getOffset():set(0.0)
		attach:getRotate():set(0.0)
		attach:setScale(1.0)
	end
end

function attachmentEditor.toScript(attach)
	local offset, rotate = attach:getOffset(), attach:getRotate()
	local lines = {
		"attachment " .. attach:getId(),
		"{",
		string.format("    offset = %.4f %.4f %.4f,", offset:x(), offset:y(), offset:z()),
		string.format("    rotate = %.4f %.4f %.4f,", rotate:x(), rotate:y(), rotate:z()),
	}
	if attach:getScale() ~= 1 then table.insert(lines, string.format("    scale = %.4f,", attach:getScale())) end
	if attach:getBone() then table.insert(lines, "    bone = " .. attach:getBone() .. ",") end
	table.insert(lines, "}")
	return table.concat(lines, "\n")
end

function attachmentEditor.copyAsScript(editUI)
	local blocks = {}
	for _, attach in ipairs(editUI:getSelectedAttachments()) do
		table.insert(blocks, attachmentEditor.toScript(attach))
	end
	if #blocks == 0 then return end
	Clipboard.setClipboard(table.concat(blocks, "\n\n"))
	attachmentEditor.showStatus(editUI.parent, "Copied " .. #blocks .. " attachment(s) as script")
end

function attachmentEditor.promptValues(editUI, kind)
	local attach = attachmentEditor.getEditable(editUI)[1]
	if not attach then return end
	local default, label
	if kind == "scale" then
		default = string.format("%.4f", attach:getScale())
		label = "Scale:"
	else
		local v = kind == "rotate" and attach:getRotate() or attach:getOffset()
		default = string.format("%.4f %.4f %.4f", v:x(), v:y(), v:z())
		label = kind == "rotate" and "Rotation (X Y Z):" or "Offset (X Y Z):"
	end
	local modal = ISTextBox:new(getCore():getScreenWidth() / 2 - 140, getCore():getScreenHeight() / 2 - 90, 280, 180, label, default, editUI, attachmentEditor.onPromptValues, nil, kind)
	modal:initialise()
	modal:addToUIManager()
end

function attachmentEditor.onPromptValues(editUI, button, kind)
	if button.internal ~= "OK" then return end
	local values = {}
	for token in string.gmatch(button.parent.entry:getText(), "[^%s,]+") do
		local value = tonumber(token)
		if not value then
			attachmentEditor.showStatus(editUI.parent, "Invalid number: " .. token)
			return
		end
		table.insert(values, value)
	end
	local needed = kind == "scale" and 1 or 3
	if #values < needed then
		attachmentEditor.showStatus(editUI.parent, "Expected " .. needed .. " value(s)")
		return
	end
	for _, attach in ipairs(attachmentEditor.getEditable(editUI)) do
		if kind == "scale" then
			attach:setScale(values[1])
		else
			local v = kind == "rotate" and attach:getRotate() or attach:getOffset()
			v:set(values[1], values[2], values[3])
		end
	end
end

function attachmentEditor.nudge(editUI, key)
	local nudge = attachmentEditor.nudgeKeys[key]
	if not nudge then return false end
	local attachments = attachmentEditor.getEditable(editUI)
	if #attachments == 0 then return false end

	local axis, direction = nudge[1], nudge[2]
	local multiplier = isShiftKeyDown() and 10 or 1
	for _, attach in ipairs(attachments) do
		if editUI.gizmo == "scale" then
			attach:setScale(math.max(0.001, attach:getScale() + 0.01 * direction * multiplier))
		else
			local isRotate = editUI.gizmo == "rotate"
			local v = isRotate and attach:getRotate() or attach:getOffset()
			local step = isRotate and 1 or (0.01 / editUI:java0("getGridMult"))
			local delta = step * direction * multiplier
			v:set(v:x() + (axis == 1 and delta or 0), v:y() + (axis == 2 and delta or 0), v:z() + (axis == 3 and delta or 0))
		end
	end
	return true
end

function attachmentEditor.autoAttachToMatch(editUI, attach)
	if not attachmentEditor.autoAttach or not attach then return end
	local child = editUI.selectedModelScript
	if not child or editUI:isCharacterScript(child) or editUI:isVehicleScript(child) then return end
	local childName = editUI:getSceneObjectId(child)
	local id = attach:getId()
	if id ~= "world" then
		for _, item in ipairs(editUI.list.items) do
			local parent = item.item
			if parent ~= child and not editUI:isVehicleScript(parent) and parent:getAttachmentById(id) then
				attachmentEditor.worldDetached[childName] = nil
				editUI:onSetObjectParent(childName, id, editUI:getSceneObjectId(parent), id)
				attachmentEditor.autoParented[childName] = true
				attachmentEditor.showStatus(editUI.parent, "Attached " .. child:getName() .. " to " .. item.text .. " at " .. id)
				return
			end
		end
	end
	if attachmentEditor.autoParented[childName] then
		attachmentEditor.autoParented[childName] = nil
		attachmentEditor.worldDetached[childName] = nil
		if editUI:java1("getObjectParent", childName) then
			editUI:onSetObjectParent(childName, nil, nil, nil)
		end
		editUI.selectedAttachment = nil
		attachmentEditor.showStatus(editUI.parent, "Detached " .. child:getName())
	end
end

function attachmentEditor.toggleAutoAttach()
	attachmentEditor.autoAttach = not attachmentEditor.autoAttach
end

function attachmentEditor.onRightMouseDownList2(editUI, x, y)
	local list = editUI.list2
	local row = list:rowAt(x, y)
	local item = list.items[row]
	if not item then return end
	if not item.selected then list:setSelectedRow(row) end
	if #editUI:getSelectedAttachments() == 0 then return end

	local context = ISContextMenu.get(0, list:getAbsoluteX() + x, list:getAbsoluteY() + y)
	context:removeFromUIManager()
	context:addToUIManager()

	local editable = #attachmentEditor.getEditable(editUI) > 0
	if editable then
		context:addOption("Copy Transform (Ctrl+C)", editUI, attachmentEditor.copyTransform)
		if attachmentEditor.clipboard then
			context:addOption("Paste Transform (Ctrl+V)", editUI, attachmentEditor.pasteTransform, true, true, true)
			local pasteMenu = context:getNew(context)
			pasteMenu:addOption("Offset", editUI, attachmentEditor.pasteTransform, true, false, false)
			pasteMenu:addOption("Rotation", editUI, attachmentEditor.pasteTransform, false, true, false)
			pasteMenu:addOption("Scale", editUI, attachmentEditor.pasteTransform, false, false, true)
			context:addSubMenu(context:addOption("Paste Only"), pasteMenu)
		end
		context:addOption("Set Offset...", editUI, attachmentEditor.promptValues, "offset")
		context:addOption("Set Rotation...", editUI, attachmentEditor.promptValues, "rotate")
		context:addOption("Set Scale...", editUI, attachmentEditor.promptValues, "scale")
		context:addOption("Reset Transform", editUI, attachmentEditor.resetTransform)
	end
	context:addOption("Copy As Script", editUI, attachmentEditor.copyAsScript)
	local autoOption = context:addOption("Auto-Attach On Select", nil, attachmentEditor.toggleAutoAttach)
	context:setOptionChecked(autoOption, attachmentEditor.autoAttach)
end

function attachmentEditor.loadCamera()
	local reader = getFileReader(attachmentEditor.cameraFile, false)
	if not reader then return end
	local line = reader:readLine()
	reader:close()
	local values = {}
	for token in string.gmatch(line or "", "[^%s]+") do
		table.insert(values, tonumber(token))
	end
	if values[1] and values[2] and values[3] then
		attachmentEditor.camera = { values[1], values[2], values[3] }
	end
	if values[4] and attachmentEditor.gridPlanes[values[4]] then
		attachmentEditor.gridPlane = values[4]
	end
end

function attachmentEditor.saveCamera()
	local camera = attachmentEditor.camera
	local writer = getFileWriter(attachmentEditor.cameraFile, true, false)
	writer:write(camera[1] .. " " .. camera[2] .. " " .. camera[3] .. " " .. attachmentEditor.gridPlane)
	writer:close()
end

function attachmentEditor.storeCamera(x, y, z)
	attachmentEditor.camera = { x, y, z }
	if attachmentEditor.freeCamView then
		attachmentEditor.freeCamView.javaObject:fromLua3("setViewRotation", x, y, z)
		attachmentEditor.frameFreeCamView(attachmentEditor.freeCamView)
	end
	attachmentEditor.saveCamera()
end

function attachmentEditor.getSceneAngles(scene)
	local view = scene:getView()
	if view == "UserDefined" then
		local rotation = scene.javaObject:fromLua0("getViewRotation")
		return rotation:x(), rotation:y(), rotation:z()
	end
	local preset = attachmentEditor.presetAngles[view] or attachmentEditor.defaultCamera
	return preset[1], preset[2], preset[3]
end

function attachmentEditor.setSceneAngles(scene, x, y, z)
	x = math.max(-90, math.min(90, x))
	scene:setView("UserDefined")
	scene.javaObject:fromLua3("setViewRotation", x, y, z)
	scene.javaObject:fromLua1("setGridPlane", attachmentEditor.gridPlanes[attachmentEditor.gridPlane][1])
end

function attachmentEditor.cycleGridPlane(editor, button)
	attachmentEditor.gridPlane = attachmentEditor.gridPlane % #attachmentEditor.gridPlanes + 1
	local plane = attachmentEditor.gridPlanes[attachmentEditor.gridPlane]
	editor.scene.javaObject:fromLua1("setGridPlane", plane[1])
	button:setTitle("Grid: " .. plane[2])
	attachmentEditor.saveCamera()
end

local FreeCamView = AttachmentEditorUI_SwitchView:derive("AttachmentEditorUI_FreeCamView")

function FreeCamView:getView()
	return "UserDefined"
end

function FreeCamView:applyCamera()
	local camera = attachmentEditor.camera
	attachmentEditor.setSceneAngles(self.editor.scene, camera[1], camera[2], camera[3])
end

function FreeCamView:onMouseDown(x, y)
	self.previous = nil
	self:applyCamera()
end

function FreeCamView:onMouseMove(dx, dy)
	local editor = self.editor
	if editor.mouseOverView == self then return end
	if editor.mouseOverView then editor.mouseOverView:onMouseMoveOutside(-1, -1) end
	editor.mouseOverView = self
	self.previous = { view = editor.scene:getView(), angles = { attachmentEditor.getSceneAngles(editor.scene) } }
	self:applyCamera()
end

function FreeCamView:onMouseMoveOutside(dx, dy)
	local editor = self.editor
	if editor.mouseOverView ~= self then return end
	editor.mouseOverView = nil
	local previous = self.previous
	self.previous = nil
	if not previous then return end
	if previous.view == "UserDefined" then
		attachmentEditor.setSceneAngles(editor.scene, previous.angles[1], previous.angles[2], previous.angles[3])
	else
		editor.scene:setView(previous.view)
	end
end

function FreeCamView:render()
	self:drawText("Saved camera", 4, 2, 1, 1, 1, 0.8, UIFont.Small)
end

attachmentEditor.freeCamViewHeight = 2.4
attachmentEditor.characterMidHeight = 0.9

function attachmentEditor.getZoomMult(zoom)
	return math.exp(zoom * 0.2) * 160 / 1.82
end

function attachmentEditor.getFitZoom(width, height)
	local zoomMult = height * (1366 / width) / attachmentEditor.freeCamViewHeight
	return math.max(1, math.floor(5 * math.log(zoomMult * 1.82 / 160)))
end

function attachmentEditor.frameFreeCamView(view)
	local zoomMult = attachmentEditor.getZoomMult(view.fitZoom)
	local scale = 1366 / view.width
	local target = -(attachmentEditor.characterMidHeight * math.cos(math.rad(attachmentEditor.camera[1]))) * zoomMult / scale
	local current = attachmentEditor.getJavaField(view.javaObject, "viewY") or 0
	view.javaObject:fromLua2("dragView", 0, current - target)
end

function attachmentEditor.createFreeCamView(editor, x, y, width, height)
	local view = FreeCamView:new(editor, x, y, width, height)
	view:initialise()
	view:instantiate()
	view:setAnchorTop(false)
	view:setAnchorRight(false)
	view.fitZoom = attachmentEditor.getFitZoom(width, height)
	view.javaObject:fromLua1("setMaxZoom", 14)
	view.javaObject:fromLua1("setZoom", view.fitZoom)
	view.javaObject:fromLua1("setDrawGrid", false)
	view.javaObject:fromLua1("createCharacter", "character1")
	view.javaObject:fromLua2("setCharacterAnimSet", "character1", "player-editor")
	view.javaObject:fromLua2("setCharacterAlpha", "character1", 1.0)
	view.javaObject:fromLua1("setView", "UserDefined")
	local camera = attachmentEditor.camera
	view.javaObject:fromLua3("setViewRotation", camera[1], camera[2], camera[3])
	attachmentEditor.frameFreeCamView(view)
	attachmentEditor.freeCamView = view
	return view
end

function attachmentEditor.getJavaField(obj, name)
	for i = 0, getNumClassFields(obj) - 1 do
		local field = getClassField(obj, i)
		if field and field:getName() == name then return field:get(obj) end
	end
end

function attachmentEditor.resetCamera(editor)
	local scene = editor.scene
	local camera = attachmentEditor.defaultCamera
	scene.javaObject:fromLua1("setZoom", attachmentEditor.defaultZoom)
	local viewX = attachmentEditor.getJavaField(scene.javaObject, "viewX") or 0
	local viewY = attachmentEditor.getJavaField(scene.javaObject, "viewY") or 0
	scene.javaObject:fromLua2("dragView", viewX, viewY)
	attachmentEditor.setSceneAngles(scene, camera[1], camera[2], camera[3])
	attachmentEditor.storeCamera(camera[1], camera[2], camera[3])
end

function attachmentEditor.applyCameraEntries(editor)
	local entries = editor.cameraEntries
	local x, y, z = tonumber(entries[1]:getText()), tonumber(entries[2]:getText()), tonumber(entries[3]:getText())
	if not (x and y and z) then
		attachmentEditor.showStatus(editor, "Camera angles must be numbers")
		return
	end
	attachmentEditor.setSceneAngles(editor.scene, x, y, z)
	attachmentEditor.storeCamera(x, y, z)
	for _, entry in ipairs(entries) do entry:unfocus() end
end

function attachmentEditor.isTyping(editor)
	if editor.editUI and editor.editUI.attachments and editor.editUI.attachments.nameEntry:isFocused() then return true end
	for _, entry in ipairs(editor.cameraEntries or {}) do
		if entry:isFocused() then return true end
	end
	return false
end

function attachmentEditor.createCameraPanel(editor)
	local pad = 6
	local btnW, btnH = 60, FONT_HGT_SMALL + 6
	local panelW = btnW * 4 + pad * 5
	local panel = ISPanel:new(editor.width - panelW - 11, 11, panelW, 10)
	panel:setAnchorLeft(false)
	panel:setAnchorRight(true)
	panel.backgroundColor = { r = 0, g = 0, b = 0, a = 0.6 }
	panel.render = function(self)
		ISPanel.render(self)
		self:drawText("Camera (right-drag to orbit)", pad, pad, 1, 1, 1, 1, UIFont.Small)
		self:drawText("X / Y / Z", pad, self.entryLabelY, 0.7, 0.7, 0.7, 1, UIFont.Small)
	end
	editor:addChild(panel)

	local y = pad * 2 + FONT_HGT_SMALL
	for i, view in ipairs(attachmentEditor.quarterViews) do
		local button = ISButton:new(pad + (i - 1) * (btnW + pad), y, btnW, btnH, view[1], nil, function() attachmentEditor.setSceneAngles(editor.scene, view[2], view[3], 0) end)
		button:initialise()
		panel:addChild(button)
	end
	y = y + btnH + pad

	panel.entryLabelY = y
	y = y + FONT_HGT_SMALL + 2
	local entryW = (panelW - pad * 4) / 3
	editor.cameraEntries = {}
	for i = 1, 3 do
		local entry = ISTextEntryBox:new("", pad + (i - 1) * (entryW + pad), y, entryW, btnH)
		entry:initialise()
		entry:instantiate()
		entry.onCommandEntered = function() attachmentEditor.applyCameraEntries(editor) end
		panel:addChild(entry)
		table.insert(editor.cameraEntries, entry)
	end
	y = y + btnH + pad

	local viewH = 100
	panel:addChild(attachmentEditor.createFreeCamView(editor, pad, y, panelW - pad * 2, viewH))
	y = y + viewH + pad

	local halfW = (panelW - pad * 3) / 2
	local gridButton = ISButton:new(pad, y, halfW, btnH, "Grid: " .. attachmentEditor.gridPlanes[attachmentEditor.gridPlane][2], nil, nil)
	gridButton:setOnClick(function() attachmentEditor.cycleGridPlane(editor, gridButton) end)
	gridButton:initialise()
	panel:addChild(gridButton)

	local resetButton = ISButton:new(pad * 2 + halfW, y, halfW, btnH, "Reset", nil, function() attachmentEditor.resetCamera(editor) end)
	resetButton:initialise()
	panel:addChild(resetButton)

	panel:setHeight(y + btnH + pad)
	panel:setY(editor.bottomPanel:getY() - panel:getHeight() - 10)
	panel:setAnchorTop(false)
	panel:setAnchorBottom(true)
	editor.cameraPanel = panel
end

function attachmentEditor.updateCameraEntries(editor)
	if not editor.cameraEntries or attachmentEditor.isTyping(editor) then return end
	local angles = { attachmentEditor.getSceneAngles(editor.scene) }
	for i, entry in ipairs(editor.cameraEntries) do
		local text = string.format("%.1f", angles[i])
		if entry:getText() ~= text then entry:setText(text) end
	end
end

local editorCreateChildren = AttachmentEditorUI.createChildren
function AttachmentEditorUI:createChildren()
	editorCreateChildren(self)
	attachmentEditor.loadCamera()
	attachmentEditor.createCameraPanel(self)
	local camera = attachmentEditor.camera
	attachmentEditor.setSceneAngles(self.scene, camera[1], camera[2], camera[3])
end

local editorPrerender = AttachmentEditorUI.prerender
function AttachmentEditorUI:prerender()
	editorPrerender(self)
	attachmentEditor.updateCameraEntries(self)
end

local editorOnKeyPress = AttachmentEditorUI.onKeyPress
function AttachmentEditorUI:onKeyPress(key)
	for _, entry in ipairs(self.cameraEntries or {}) do
		if entry:isFocused() then return end
	end
	return editorOnKeyPress(self, key)
end

local Scene = AttachmentEditorUI_Scene

local sceneOnRightMouseDown = Scene.onRightMouseDown
function Scene:onRightMouseDown(x, y)
	if self.gizmoAxis ~= "None" then return sceneOnRightMouseDown(self, x, y) end
	local ax, ay, az = attachmentEditor.getSceneAngles(self)
	attachmentEditor.setSceneAngles(self, ax, ay, az)
	self.orbiting = true
end

function Scene:orbit(dx, dy)
	local ax, ay, az = attachmentEditor.getSceneAngles(self)
	attachmentEditor.setSceneAngles(self, ax + dy * 0.5, ay + dx * 0.5, az)
end

function Scene:stopOrbit()
	if not self.orbiting then return end
	self.orbiting = false
	attachmentEditor.storeCamera(attachmentEditor.getSceneAngles(self))
end

function Scene:onRightMouseUp(x, y) self:stopOrbit() end
function Scene:onRightMouseUpOutside(x, y) self:stopOrbit() end

local sceneOnMouseMove = Scene.onMouseMove
function Scene:onMouseMove(dx, dy)
	if self.orbiting then
		self:orbit(dx, dy)
		return
	end
	sceneOnMouseMove(self, dx, dy)
end

function Scene:onMouseMoveOutside(dx, dy)
	if self.orbiting then self:orbit(dx, dy) end
end

local initUI = AttachmentEditorState_InitUI
function AttachmentEditorState_InitUI()
	attachmentEditor.addPropAttachments()
	return initUI()
end

local showUI = AttachmentEditorUI.showUI
function AttachmentEditorUI:showUI()
	attachmentEditor.addPropAttachments()
	return showUI(self)
end

local onExit = AttachmentEditorUI.onExit
function AttachmentEditorUI:onExit(button, x, y)
	attachmentEditor.removePropAttachments()
	return onExit(self, button, x, y)
end

local onSave = AttachmentEditorUI.onSave
function AttachmentEditorUI:onSave(button, x, y)
	attachmentEditor.detachPropAttachments()
	onSave(self, button, x, y)
	attachmentEditor.reattachPropAttachments()
end

local EditAttachment = AttachmentEditorUI_EditAttachment

local function rotationMatrix(x, y, z)
	local ca, sa = math.cos(math.rad(x)), math.sin(math.rad(x))
	local cb, sb = math.cos(math.rad(y)), math.sin(math.rad(y))
	local cc, sc = math.cos(math.rad(z)), math.sin(math.rad(z))
	return {
		{ cb * cc, -cb * sc, sb },
		{ ca * sc + sa * sb * cc, ca * cc - sa * sb * sc, -sa * cb },
		{ sa * sc - ca * sb * cc, sa * cc + ca * sb * sc, ca * cb },
	}
end

function attachmentEditor.getInverseAttachPoint(attach)
	local offset, rotate = attach:getOffset(), attach:getRotate()
	local r = rotationMatrix(rotate:x(), rotate:y(), rotate:z())
	local m = {
		{ r[1][1], r[2][1], r[3][1] },
		{ r[1][2], r[2][2], r[3][2] },
		{ r[1][3], r[2][3], r[3][3] },
	}
	local px, py, pz = offset:x(), offset:y(), offset:z()
	local ix = -(m[1][1] * px + m[1][2] * py + m[1][3] * pz)
	local iy = -(m[2][1] * px + m[2][2] * py + m[2][3] * pz)
	local iz = -(m[3][1] * px + m[3][2] * py + m[3][3] * pz)
	local rx, ry, rz
	local s = math.max(-1, math.min(1, m[1][3]))
	ry = math.asin(s)
	if math.abs(s) < 0.9999 then
		rx = math.atan2(-m[2][3], m[3][3])
		rz = math.atan2(-m[1][2], m[1][1])
	else
		rx = math.atan2(m[3][2], m[2][2])
		rz = 0
	end
	return ix, iy, iz, math.deg(rx), math.deg(ry), math.deg(rz)
end

function attachmentEditor.restoreWorldDetached(editUI, keepName)
	local restored = {}
	for objectName, parentInfo in pairs(attachmentEditor.worldDetached) do
		if objectName ~= keepName then
			editUI:onSetObjectParent(objectName, parentInfo.attachment, parentInfo.parent, parentInfo.attachment)
			table.insert(restored, objectName)
		end
	end
	for _, objectName in ipairs(restored) do
		attachmentEditor.worldDetached[objectName] = nil
	end
end

local setSelectedAttachment = EditAttachment.setSelectedAttachment
function EditAttachment:setSelectedAttachment(attach)
	if self.selectedAttachment == attach then return end
	local modelScript = self.selectedModelScript
	local isItem = modelScript and not self:isCharacterScript(modelScript) and not self:isVehicleScript(modelScript)
	local objectName = isItem and self:getSceneObjectId(modelScript) or nil
	local isWorld = isItem and attach ~= nil and attach:getId() == "world"
	if isWorld and not attachmentEditor.worldDetached[objectName] then
		local parent = self:java1("getObjectParent", objectName)
		if parent then
			attachmentEditor.worldDetached[objectName] = { parent = parent, attachment = self:java1("getObjectParentAttachment", objectName) }
			self:onSetObjectParent(objectName, nil, nil, nil)
		end
	end
	attachmentEditor.restoreWorldDetached(self, isWorld and objectName or nil)
	setSelectedAttachment(self, attach)
end

local prerenderEditor = EditAttachment.prerenderEditor
function EditAttachment:prerenderEditor()
	prerenderEditor(self)
	local modelScript, attach = self.selectedModelScript, self.selectedAttachment
	if not modelScript or not attach or attach:getId() == "world" then return end
	if self:isCharacterScript(modelScript) or self:isVehicleScript(modelScript) then return end
	local objectName = self:getSceneObjectId(modelScript)
	if self:java1("getObjectParentVehiclePart", objectName) then return end
	self:java0("clearAxes")
	if self:java1("getObjectParentAttachment", objectName) == attach:getId() then
		self:java6("addAxis", 0, 0, 0, 0, 0, 0)
	else
		self:java6("addAxis", attachmentEditor.getInverseAttachPoint(attach))
	end
end

local createChildren = EditAttachment.createChildren
function EditAttachment:createChildren()
	createChildren(self)
	self.list2.onRightMouseDown = function(list, x, y) return attachmentEditor.onRightMouseDownList2(self, x, y) end
	local list2OnMouseDown = self.list2.onMouseDown
	self.list2.onMouseDown = function(list, x, y)
		list2OnMouseDown(list, x, y)
		local item = list.items[list:rowAt(x, y)]
		if item and item.selected then attachmentEditor.autoAttachToMatch(self, item.item) end
	end
end

local doDrawItem2 = EditAttachment.doDrawItem2
function EditAttachment:doDrawItem2(y, item, alt)
	local bottom = doDrawItem2(self, y, item, alt)
	if attachmentEditor.isPropAttachment(item.item) then
		self:drawTextRight("prop point (not saved)", self:getWidth() - 8, y, 0.5, 0.8, 1, 1, UIFont.Small)
	end
	return bottom
end

local onKeyPress = EditAttachment.onKeyPress
function EditAttachment:onKeyPress(key)
	if attachmentEditor.isTyping(self.parent) then return onKeyPress(self, key) end
	if isCtrlKeyDown() and key == Keyboard.KEY_C then
		attachmentEditor.copyTransform(self)
		return
	end
	if isCtrlKeyDown() and key == Keyboard.KEY_V then
		attachmentEditor.pasteTransform(self, true, true, true)
		return
	end
	onKeyPress(self, key)
	attachmentEditor.nudge(self, key)
end

return attachmentEditor
