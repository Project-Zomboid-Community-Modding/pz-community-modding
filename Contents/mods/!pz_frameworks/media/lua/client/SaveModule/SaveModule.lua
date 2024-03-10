--contributors: Reifel
SaveModule = SaveModule or {}

function SaveModule:new(modID, save, load)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    o.modID = modID
    o.save = self.save
    o.load = self.load
    o.clear = self.clear
    o.custom_save = save
    o.custom_load = load
    o.modDataTable = ModData.getOrCreate(modID)
    return o
end

function SaveModule:load()
    if self.modDataTable.keep == nil then return end
    self.custom_load(self.modDataTable.keep)
end

function SaveModule:save()
    self.modDataTable.keep = self.custom_save()    
end

function SaveModule:clear()
    self.modDataTable = {}
end

--possible future improvements, not implemented yet MP compatibility 
--FOR MP CAN USE ModData https://discord.com/channels/136501320340209664/232196827577974784/995661819408551947
--Monkey lib can be useful too for MP Monkey_ModData at MonkeysLibrary
