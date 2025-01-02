-- Only for MP, server side
if not isServer() then return end
-- Animation Framework for Project Zomboid
---- Server Relay

-- some globals, cached
local getOnlineID = __classmetatables[IsoPlayer.class].__index.getOnlineID
local _getOnlinePlayers = getOnlinePlayers
local _sendServerCommand = sendServerCommand

-- our structure
local Commands = {
    AnimAPI = {
        Sync = function(source, args)
            local myId = getOnlineID(source)
            -- sync it to all other clients
            local players = _getOnlinePlayers()
            local player
            for i=0, players:size()-1 do
                player = players:get(i)
                -- send to all other players
                if player and (args and args.cmd) and getOnlineID(player) ~= myId then
                    _sendServerCommand(player, "AnimAPI", args.cmd, {
                        id = myId,
                        data = args.data -- this is nil except for when doing a manual sync
                    })
                end
            end
        end
    }
}
-- Add our Event
Events.OnClientCommand.Add(function(module, command, source, args)
    if Commands[module] and Commands[module][command] then
        Commands[module][command](source, args)
    end
end)
