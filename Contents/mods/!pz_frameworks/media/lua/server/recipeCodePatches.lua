require "recipecode"

---local function addExistingItemType(scriptItems, type)
--	local all = getScriptManager():getItemsByType(type)
--	for i=1,all:size() do
--		local scriptItem = all:get(i-1)
--		if not scriptItems:contains(scriptItem) then
--			scriptItems:add(scriptItem)
--		end
--	end
--end

--The function below is localized in the `recipecode` file.
--Which means if someone wants to make use of it they'd need to copy it over.

--+ On top of that the internal call for `getItemsByType` builds an array.
--+ If you use module.type (for modded items) it will for loop through available modules.
--+ Which then finally needs to be for-looped in the function.


---Recipe.chuckInTheseTypes(scriptItems, {"type","type","type"})
function Recipe.chuckInTheseTypes(scriptItems, types)
    local SM =  getScriptManager()
    for _,iType in pairs(types) do
        local script = SM:getItem(iType)
        if script and not scriptItems:contains(script) then
            scriptItems:add(script)
        end
    end
end

---Recipe.chuckInThisType(scriptItems, "type")
function Recipe.chuckInThisType(scriptItems, iType)
    local script = getScriptManager():getItem(iType)
    if script and not scriptItems:contains(script) then
        scriptItems:add(script)
    end
end