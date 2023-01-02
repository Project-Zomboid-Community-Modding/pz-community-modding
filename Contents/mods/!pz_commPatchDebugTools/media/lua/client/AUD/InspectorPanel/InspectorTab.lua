require("AUD/Init")

AUDInspectorTab = ISPanelJoypad:derive("AUDInspectorTab")

function AUDInspectorTab:initialise()
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
end

function AUDInspectorTab:render()
    if AUD.Inspector.paramsMode == "NORMAL" then
        local step = 1
        for _, values in pairs(self.values) do
            local text = ""
            text = text .. values[1] .. "  "
            
            for i=2, #values do
                if i == #values then
                    text = text .. values[i]
                else
                    text = text .. values[i] .. " | "            
                end
            end
    
            self:drawText(text, 3, step, 1, 1, 1, 1, UIFont.Small);
            step = step + 15
        end    
    elseif AUD.Inspector.paramsMode == "TABLE_STATIC" then
        local xSteps = {}
        xSteps[0] = 0
        for i=1, 9 do
            xSteps[i] = xSteps[i-1] + 6
            xSteps[i] = xSteps[i] + 8
        end
    
        local yStep = 1
        for _, values in pairs(self.values) do
            local text = ""
    
            for i=1, #values do
                self:drawText(tostring(values[i]), xSteps[i-1]*8 + 3, yStep, 1, 1, 1, 1, UIFont.Small);    
            end
    
            yStep = yStep + 15
        end
    elseif AUD.Inspector.paramsMode == "TABLE_DYNAMIC" then
        local columnSize = {}

        for _, values in pairs(self.values) do
            for i=1, #values do
                local str = tostring(values[i])
                if columnSize[i] == nil then
                    columnSize[i] = string.len(str)
                else
                    if string.len(str) > columnSize[i] then
                        columnSize[i] = string.len(str)
                    end
                end
            end
        end
    
        local xSteps = {}
        xSteps[0] = 0
        for i=1, 9 do
            if columnSize[i] ~= nil then
                xSteps[i] = xSteps[i-1] + columnSize[i]
            end
        end
    
        local yStep = 1
        for _, values in pairs(self.values) do
            local text = ""
    
            for i=1, #values do
                self:drawText(tostring(values[i]), xSteps[i-1]*8 + 3, yStep, 1, 1, 1, 1, UIFont.Small);    
            end
    
            yStep = yStep + 15
        end
    end
end


