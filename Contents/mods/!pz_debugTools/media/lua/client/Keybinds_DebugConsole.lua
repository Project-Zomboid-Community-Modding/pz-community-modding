--- Toggle lua console on Main Screen (not in-game)
--- GameWindow changes visibility early on key press
--- Create the console, add it to ui and bring to top

if not getDebug() then return end

local Patch = {}

function Patch.OnMainMenuEnter()
    local console = UIManager.getDebugConsole()
    if console == nil then
        console = UIDebugConsole.new(20, getCore():getScreenHeight() - 265)
        UIManager.setDebugConsole(console)
    end
    if not UIManager.getUI():contains(console) then
        UIManager.getUI():add(console)
    end
    console:bringToTop()
    console:setVisible(false)
end

function Patch.OnKeyStartPressed(key)
    if getPlayer() == nil and key == getCore():getKey("ToggleLuaConsole") then
        local console = UIManager.getDebugConsole()
        if not UIManager.getUI():contains(console) then
            UIManager.getUI():add(console)
        end
        console:bringToTop()
    end
end

Events.OnMainMenuEnter.Add(Patch.OnMainMenuEnter)
-- Events.OnKeyStartPressed.Add(Patch.OnKeyStartPressed)

return Patch
