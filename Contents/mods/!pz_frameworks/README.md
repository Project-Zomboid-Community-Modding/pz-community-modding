![banner](poster.png)
### Frameworks should include new utility functions and quality of life changes to vanilla features as to assist other modders.

- `VehicleSeatUIOverride` creates a dynamic UI for the SeatUI to:
  - Support 4k or larger resolutions.
  - Adapt the UI to vehicles with less conventional seating.


- Provides an alternative functions for the localized `addExistingItemType` function which also has performance concerns. See: `recipeCodePatches`.


- Adds a `debounce` utility. See `utils/debounce.lua`