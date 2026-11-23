require "DebugUIs/AttachmentEditorUI"

local attachmentEditor = {}

attachmentEditor.bodyScripts = { "FemaleBody", "MaleBody" }
attachmentEditor.propBones = { "Bip01_Prop1", "Bip01_Prop2" }
attachmentEditor.added = {}

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

function attachmentEditor.removePropAttachments()
    for _, entry in ipairs(attachmentEditor.added) do
        entry.script:removeAttachment(entry.attachment)
    end
    attachmentEditor.added = {}
end

local initUI = AttachmentEditorState_InitUI
function AttachmentEditorState_InitUI()
    attachmentEditor.addPropAttachments()
    return initUI()
end

local onExit = AttachmentEditorUI.onExit
function AttachmentEditorUI:onExit(button, x, y)
    attachmentEditor.removePropAttachments()
    return onExit(self, button, x, y)
end

return attachmentEditor