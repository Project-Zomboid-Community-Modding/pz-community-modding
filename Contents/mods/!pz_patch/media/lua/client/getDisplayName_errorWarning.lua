local patchClassMethod = {}

patchClassMethod.parsedNames = {}

function patchClassMethod.create(original_function)
    return function(self)

        local results = original_function(self)

        if not results then
            if not patchClassMethod.parsedNames[tostring(self)] then
                patchClassMethod.parsedNames[tostring(self)] = true
                print("ERROR: script `getDisplayName` failed: ", self)
            end
            return "ERROR"
        end

        return results
    end
end

function patchClassMethod.apply()
    print("CommunityModdingPatch: accessing class:`zombie.scripting.objects.Item.class` method:`getDisplayName`")
    local class, methodName = Item.class, "getDisplayName"
    local metatable = __classmetatables[class]
    local metatable__index = metatable.__index
    local originalMethod = metatable__index[methodName]
    metatable__index[methodName] = patchClassMethod.create(originalMethod)
end
patchClassMethod.apply()