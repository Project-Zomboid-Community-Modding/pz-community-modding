-- A small API to make working with the new B42 ModOptions easier.
local ModOptionsAPI = {
    opts = {}
}

-- Sync Sandbox options with our ModOptions, if enabled
local syncOptions = function(self)
    if self._sandbox and SandboxVars[self._sandbox] then
        local vars = SandboxVars[self._sandbox]
        for k,v in pairs(vars) do
            self[k] = v
        end
    end
end

-- Generic function to add all of our options to our object
--- An "Apply()" function is available while in game.
local applyOptions = function(self, initLoad)
    for k,v in pairs(self.dict) do
        if v.type == "multipletickbox" then
            for i=1, #v.values do
                k = (k.."_"..tostring(i))
                self[k] = v:getValue(i)
            end
        elseif v.type ~= "button" then
            self[k] = v:getValue()
        end
    end
    if MainScreen.instance.inGame then
        self:sync()
        self:Apply()
    elseif initLoad then
        self:sync()
    end
end

-- Local build function
local build = function()
    for i=1, #ModOptionsAPI.opts do
        local opt = ModOptionsAPI.opts[i]
        opt:Build()
        if opt.sync then
            if not opt._sync then
                opt._sync = function()
                    opt:apply(true)
                end
            end
            if Events.OnSandboxOptionsChanged then
                Events.OnSandboxOptionsChanged.Add(opt._sync)
            end
            Events.OnInitGlobalModData.Add(opt._sync)
        end
    end
    -- We don't need to hold on to these anymore, so let's clean up
    for i=#ModOptionsAPI.opts, 1, -1 do
        ModOptionsAPI.opts[i] = nil
    end
    ModOptionsAPI.opts = nil
end

-- Set our build function to run OnGameBoot, ensure "reloads" are handled.
Events.OnGameBoot.Remove(build)
Events.OnGameBoot.Add(build)

-- Create a new ModOptionsAPI object
---- `ID` - Should be a UNIQUE ModOptions ID
---- `name` - The name for your options, will be displayed.
---- `sandbox` - An optional parameter to sync your Sandbox namespace.
--- @param ID string
--- @param name string
--- @param sandbox string?
--- @return table
function ModOptionsAPI:new(ID, name, sandbox)
    local options = PZAPI.ModOptions:create(ID, name)
    options.apply = applyOptions
    options.sync = function(self) end
    
    options._sandbox = sandbox
    if options._sandbox then
        options.sync = syncOptions
    end
    options.Build = function(self) end
    options.Apply = function(self) end
    self.opts[#self.opts+1] = options
    return options
end

return ModOptionsAPI

---------------------
---- Example:
--- For a full example, see: "B42 Native ModOptions Example" on the Workshop
---- https://steamcommunity.com/sharedfiles/filedetails/?id=3386860561
---------------------
--- In a new file, add the following:
---- local options = require("ModOptionsAPI"):new("UNIQUEID", "OPTIONSNAME", "SANDBOX")
---
---- function options:Build()
---- ---- Build your ModOptions here using the standard ModOptions functions
---- end
---
---- function options:Apply()
---- ---- Perform any additional actions in game based on changed settings. Only run in game.
---- end

---- return options
---------------------
--- In your mod, include your module:
---- local options = require("MyConfig")
---
--- Now you can call your options as such:
---- options.ID
--- Where "ID" is the ID you set when creating each option.
---------------------