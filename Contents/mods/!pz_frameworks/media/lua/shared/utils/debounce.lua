-- @author Marat Azizov <etomarat+lua@gmail.com>
-- https://github.com/etomarat


---@class debounceEntry
---@field func function @ Callback function. Will be executed after timeout
---@field ticks integer @ Ticks after last call
---@field acc any[] @ List of all passed args
---@field onTick function @ Internal clocking


---@type table<string, debounceEntry> @ Dict of debounced tasks
local debounceDict = {}


---Useful for implementing behavior that should only happen after a repeated action has completed.
---
---Basic example:
---```lua
-- for i=1, 3 do
--     print('bounce') -- print 3 times
--     debounceFn('basicTask', 10, function ()
--         print('deboounce') -- print 1 time after 10 ticks after the last call
--     end)
-- end
---```
---
---Advanced example:
---```lua
-- for i=1, 3 do
--     print('bounce')
--     debounceFn('advancedTask', 10, function (args, acc) -- args == 3, acc == {1,2,3}
--         print('deboounce: ', #acc) -- print `deboounce: 3`
--     end, i)
-- end
---```
---@param name string @ Unique name for debounce task
---@param delay integer @ Timeout in ticks
---@param func function @ Callback function. Will be executed after timeout
---@param args any | nil @ Arguments for callback
local debounceFn = function (name, delay, func, args)
    if debounceDict[name] then
        debounceDict[name].func = func
        debounceDict[name].ticks = 0
        table.insert(debounceDict[name].acc, args)
        Events.OnTick.Remove(debounceDict[name].onTick);
    else
        debounceDict[name] = {
            func = func,
            ticks = 0,
            acc = {args},
        }
    end

    debounceDict[name].onTick = function ()
        if not debounceDict[name] then
            return
        end
        local ticks = debounceDict[name].ticks

        if ticks < delay then
            ticks = ticks + 1;
            debounceDict[name].ticks = ticks
        else
            debounceDict[name].func(args, debounceDict[name].acc)
            Events.OnTick.Remove(debounceDict[name].onTick);
            debounceDict[name] = nil
        end
    end

    Events.OnTick.Add(debounceDict[name].onTick);
end

return {
    debounceFn = debounceFn,
    debounceDict = debounceDict
}