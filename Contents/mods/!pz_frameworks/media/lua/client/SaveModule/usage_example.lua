require "SaveModule"

local modID = "YOUR_MOD_ID" --maybe there is a way to automatic grab the current file Mod ID

local save = function()
    --OWN LOGIC
    local mod_data = {
        --persistentVarName1= GlobalVar.Name1
    }
    return mod_data
end

local load = function(mod_data)
    --OWN LOGIC
    for k,v in pairs(mod_data.persistentVarName1) do
        print(k)
        print(v)
    end
    --GlobalVar.Name1 = mod_data.persistentVarName1
end

GlobalVar_load = function()
    GlobalVar.save_instance = SaveModule:new(modID, save, load)
    GlobalVar.save_instance:load()
end

GlobalVar_save = function()
    GlobalVar.save_instance:save()
end
Events.OnGameStart.Add(GlobalVar_load)
Events.OnSave.Add(GlobalVar_save)

--you can use inside a code at any point too, not only events


--if dont want to use module, and without usage of embed MP compatibility (future), do like this 
    --local mysave = ModData.getOrCreate(modID)
    --if mysave.keep then
    --    load(mysave.keep)
    --    print(mysave)
    --end

    --local mysave = ModData.getOrCreate(modID)
    --mysave.keep = save()
    --print(mysave)