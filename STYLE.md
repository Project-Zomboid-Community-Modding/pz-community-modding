# Style Guide

This isn't meant to be rigid, it's just so the mods read like one project. If breaking a rule makes something clearer, break it.


## Files and folders

- Files should be named to describe themselves, `spawnVehicleTweaks.lua` over `ISSpawnVehicleUI_patch.lua`.
- If a change needs more than one file, put them in an aptly named folder, like `Teleport/` or `LuaExplorer/`.
- Don't nest files to match vanilla's folders when patching, requires handle loading:
  ```lua
  require "DebugUIs/ISSpawnVehicleUI"
  ```
- Keep files inside the mod's own folder (`CommunityDebugTools/`, `CommunityModdingPatch/`), Lua paths are shared between every mod so a loose `utils.lua` can get stomped by someone else's.
- Vanilla always loads before mods, then each mod loads in load order with its files sorted by path, so requires are only needed for files from your own mod (or other mods) that have to load first.
- Framework files other mods require keep their paths, moving them breaks those mods.
- `!!!` prefixed files are only for stuff that has to load first.


## Patching vanilla

- Wrap, don't overwrite. Grab the original, call it, then add your bit:
  ```lua
  local ISSpawnVehicleUI_render = ISSpawnVehicleUI.render
  function ISSpawnVehicleUI:render()
  	ISSpawnVehicleUI_render(self)
  	...
  end
  ```
- Hard overwrites should be rare, if one is needed mention it in the readme entry.


## Code

- Tabs for indentation, no trailing semicolons.
- Leave commented out code alone, it's usually there for a reason.
- Modules are local tables that get returned (`local Thing = {} ... return Thing`), only make globals when vanilla needs them.
- Keep comments light, EmmyLua annotations (`---@param`) are fine, and so are usage notes at the top of framework APIs.
- Kahlua isn't regular Lua:
  - No `pcall`, `next` or `os.time`, use `getTimestampMs()` for timing.
  - `pairs` order isn't guaranteed, use an array with `ipairs` if order matters.
  - `string.split` takes a Java regex (`"\\|"` to split on `|`), `string.trim` and `string.contains` exist.
- Debug only stuff should bail early with `if not getDebug() then return end` where it makes sense.


## Multiplayer

- Debug tools talk to the server through the `ceDebug` module in `!!!communityPatchDebugTools - shared.lua`:
  - `debug.serverCommands["Thing.action"] = function(player, args) ... end`
  - `debug.serverCommandCapabilities["Thing.action"] = "ManipulateZombie"` if it needs more than `UseDebugContextMenu`.
  - Replies come back through `debug.clientCommands`.
- If the server owns the data, check `isClient()` and send a command instead of doing it locally.


## Readme entries

One sentence, tagged with the kind of change (and the build if it's only for one), with a link only if there's actually more to read (an API, an example to copy, a function to call):

```
- (Fix, B42) Craft Recipes debug window no longer errors on open.
- (New) API for adding more buttons to the Debug menu. See [debugToolbar.lua](42/media/lua/client/CommunityDebugTools/debugToolbar.lua).
```

- **New** is something vanilla doesn't have.
- **Tweak** changes how something vanilla behaves.
- **Fix** fixes something vanilla gets wrong.
- Only add the build (`B41` or `B42`) if the entry doesn't apply to every build the mod supports.
