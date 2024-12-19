
local EmoteMenuAPI = {}

local sliceTable = {}


function EmoteMenuAPI.registerSlice(sliceName, sliceFunction)
    sliceTable[sliceName] = sliceFunction
end

function EmoteMenuAPI.unregisterSlice(sliceName)
    sliceTable[sliceName] = nil
end

local function fillSubMenu(menu, args)
    local icon = nil;
    for i, v in pairs(ISEmoteRadialMenu.menu[args.subMenu].subMenu) do
        icon = nil;
        if ISEmoteRadialMenu.icons[i] then
            icon = ISEmoteRadialMenu.icons[i];
        end
        menu:addSlice(v, icon, args.selfObject.emote, args.selfObject, i)
    end
end

function ISEmoteRadialMenu:fillMenu(submenu)
    local menu = getPlayerRadialMenu(self.playerNum)
    menu:clear()

    --do vanilla slices accounting for table inserts for compatibility with mods not using the API
    local icon = nil;
    for i, v in pairs(ISEmoteRadialMenu.menu) do
        icon = nil;
        if ISEmoteRadialMenu.icons[i] then
            icon = ISEmoteRadialMenu.icons[i];
        end
        if v.subMenu then -- stuff with submenu
            menu:addSlice(v.name, icon, ISRadialMenu.createSubMenu, menu, fillSubMenu, { subMenu = i, selfObject = self })
        else              -- stuff for rapid access
            menu:addSlice(v.name, icon, self.emote, self, i)
        end
    end

    --do EmoteMenuAPI slices
    for _, f in pairs(sliceTable) do
        f(menu, self.character)
    end

    self:display()
end

--local function onExample(player)
--	player:Say("This is a custom slice!")
--end
--
--local function exampleFunction(menu, player)
--	menu:addSlice("What's This?", getTexture("media/ui/emotes/shrug.png"), onExample, player)
--end
--
--EmoteMenuAPI.registerSlice("example", exampleFunction)

return EmoteMenuAPI
