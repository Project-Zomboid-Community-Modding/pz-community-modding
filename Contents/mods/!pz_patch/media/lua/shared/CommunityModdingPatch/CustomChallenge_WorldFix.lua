---v41.78 continuing a challenge from a mod that is not loaded on MainScreen is bugged
---MainScreen.continueLatestSave does the checks and calls the doChallenge function
---this is done before reloading the Lua
---checks needs to happen after reload and before MainScreen.continueLatestSaveAux

local function WorldFix(challenge)
    local world = getWorld()
    local worldWorld = world:getWorld()

    LastStandData.chosenChallenge = challenge
    doChallenge(challenge)

    world:setWorld(worldWorld)
end

local function onResetLua(reason)
    if reason == "continueSave" and not getCore():isChallenge() then
        local gameMode = getCore():getGameMode()
        for i,challenge in ipairs(LastStandChallenge) do
            if challenge.gameMode == gameMode then
                WorldFix(challenge)
                break
            end
        end
    end
end
Events.OnResetLua.Add(onResetLua)
