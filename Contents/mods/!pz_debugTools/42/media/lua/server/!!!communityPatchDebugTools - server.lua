local debug = require "!!!communityPatchDebugTools - shared"


if isClient() then

else
    function debug.OnClientCommand(module, command, player, args)
        if module == "ceDebug" then
            local f = debug.serverCommands[command]
            if type(f) == "function" then
                return f(player,args)
            else
                print("Debug: received invalid command ",command)
            end
        end
    end
    Events.OnClientCommand.Add(debug.OnClientCommand)
end
