![banner](poster.png)
### Features included here should be tools meant for debugging coding problems only.
### Quality of life changes to vanilla tools or debugging features are also included.


- Integrates much of Aiteron's AUD debug tools. (Some were removed/streamlined.)
    - Teleport Panel: Allows one to save points across the map to easily teleport to.
    - Lua Explorer/Reloader: Allows once to create a list of files, which can be reloaded individually. This is very unstable depending on what is getting reloaded.
    - Spawn Vehicle UI was removed in favor of improving the vanilla's.


- Adds an object inspect panel.
    - Right-clicking objects allows one to view their modData and java fields. Note: due to a limitation in the vanilla code only the casted to class can be read for java fields. This limitation does not apply to modData.


- Improves the Spawn Vehicle UI:
  - Allows the car the player is in to be selected for actions.
  - Adds toggle hotwire action. (Reimplemented from AUD)
  

- Creates an API to add more buttons to the Debug UI menu.


- All DEBUG related windows now save their layouts accordingly.


- Cheats UI have been converted into a toggle button panel (instead of a checkbox list that requires saving.)


- Micro-Map: A 2x2 map provided by Dane, reimplementing a concept by Reifel. This allows for faster loading for cases where reloading a save is necessary.


- Fixes issue with Fitness being set to level 10 due to the Moodles & Body page having  Fitness slider. (The slider is disabled and removed.)


- Add utility function to mark all stash locations on the map.


- Modifies the Debug Context Menu to restructure/add features.
  - Adds new options related to bodies, and zombies - as well as separates the two by category.