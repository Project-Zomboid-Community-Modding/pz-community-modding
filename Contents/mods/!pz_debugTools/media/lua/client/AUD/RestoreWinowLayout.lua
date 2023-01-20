require("AUD/Init")
AUD.RestoreLayout = {}

function AUD.RestoreLayout.restoreWindows()
    local readFile = getFileReader("AUD_DebugWindowsState.txt", true)

    if readFile:readLine() == "TRUE" then
        local x = tonumber(readFile:readLine())
        local y = tonumber(readFile:readLine())
        local width = tonumber(readFile:readLine())
        local height = tonumber(readFile:readLine())
        
        AUD.inspectorWindowTabPanel = AUDInspector:new(x, y, width, height)
        AUD.inspectorWindowTabPanel:initialise()
    end

    if readFile:readLine() == "TRUE" then
        local x = tonumber(readFile:readLine())
        local y = tonumber(readFile:readLine())
        local width = tonumber(readFile:readLine())
        local height = tonumber(readFile:readLine())
        
        AUD.luaFileExplorer = AUDLuaExplorer:new(x, y, width, height)
        AUD.luaFileExplorer:initialise();
    end

    if readFile:readLine() == "TRUE" then
        local x = tonumber(readFile:readLine())
        local y = tonumber(readFile:readLine())
        local width = tonumber(readFile:readLine())
        local height = tonumber(readFile:readLine())

        AUD.teleport = AUDTeleport:new(x, y, width, height)
        AUD.teleport:initialise();
    end

	readFile:close()
end

function AUD.RestoreLayout.saveWindowsLayout()
    local writeFile = getFileWriter("AUD_DebugWindowsState.txt", true, false)

    if AUD.inspectorWindow and not AUD.inspectorWindow:isRemoved() then
        writeFile:write("TRUE".."\r\n");
        writeFile:write(AUD.inspectorWindow.x .. "\r\n");
        writeFile:write(AUD.inspectorWindow.y .. "\r\n");
        writeFile:write(AUD.inspectorWindow.width .. "\r\n");
        writeFile:write(AUD.inspectorWindow.height - 24 .. "\r\n");
    else
        writeFile:write("FALSE".."\r\n");
    end

    if AUD.luaExplorerWindow and not AUD.luaExplorerWindow:isRemoved() then
        writeFile:write("TRUE".."\r\n");
        writeFile:write(AUD.luaExplorerWindow.x .. "\r\n");
        writeFile:write(AUD.luaExplorerWindow.y .. "\r\n");
        writeFile:write(AUD.luaExplorerWindow.width .. "\r\n");
        writeFile:write(AUD.luaExplorerWindow.height - 24 .. "\r\n");
    else
        writeFile:write("FALSE".."\r\n");
    end

    if AUD.teleportWindow and not AUD.teleportWindow:isRemoved() then
        writeFile:write("TRUE".."\r\n");
        writeFile:write(AUD.teleportWindow.x .. "\r\n");
        writeFile:write(AUD.teleportWindow.y .. "\r\n");
        writeFile:write(AUD.teleportWindow.width .. "\r\n");
        writeFile:write(AUD.teleportWindow.height - 24 .. "\r\n");
    else
        writeFile:write("FALSE".."\r\n");
    end
    
    writeFile:close()
    
    getPlayer():Say("Window layout saved")
end