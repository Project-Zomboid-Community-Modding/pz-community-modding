
debugScenarios.AUDExampleDebugScenario = {
	name = "AUD Example Debug Scenario",
	--forceLaunch = true, -- use this to force the launch of THIS scenario right after main menu was loaded, save more clicks! Don't do multiple scenarii with this options
	startLoc = {x=3685, y=5790, z=0 },  -- Spawn coords
	
	setSandbox = function()
		SandboxVars.MaxFogIntensity = 3;	-- low fog
		SandboxVars.Helicopter = 1;	-- never helicopter
		SandboxVars.Zombies = 2; 
		SandboxVars.StarterKit = false;
        SandboxVars.StartTime = 12;
        SandboxVars.Speed = 3;
		SandboxVars.Zombies = 2; -- 5 = no zombies, 1 = insane (then 2 = low, 3 normal, 4 high..)
		SandboxVars.Distribution = 1;
		SandboxVars.Survivors = 1;
		SandboxVars.DayLength = 3;
		SandboxVars.StartYear = 1;
		SandboxVars.StartMonth = 7;
		SandboxVars.StartDay = 9;
		SandboxVars.StartTime = 12;
		SandboxVars.VehicleEasyUse = true;
		SandboxVars.WaterShutModifier = 30;
		SandboxVars.ElecShutModifier = 30;
		SandboxVars.WaterShut = 2;
		SandboxVars.ElecShut = 2;
		SandboxVars.FoodLoot = 2;
		SandboxVars.WeaponLoot = 2;
		SandboxVars.OtherLoot = 2;
		SandboxVars.Temperature = 3;
		SandboxVars.Rain = 3;
		SandboxVars.ErosionSpeed = 3;
		SandboxVars.XpMultiplier = 1.0;
		SandboxVars.StatsDecrease = 3;
		SandboxVars.NatureAbundance = 3;
		SandboxVars.Alarm = 1;
		SandboxVars.LockedHouses = 6;
		SandboxVars.FoodRotSpeed = 3;
		SandboxVars.FridgeFactor = 3;
		SandboxVars.Farming = 3;
		SandboxVars.LootRespawn = 1;
		SandboxVars.StarterKit = false;
		SandboxVars.Nutrition = true;
		SandboxVars.TimeSinceApo = 1;
		SandboxVars.PlantResilience = 3;
		SandboxVars.PlantAbundance = 3;
		SandboxVars.EndRegen = 3;
		SandboxVars.CarSpawnRate = 3;
		SandboxVars.LockedCar = 3;
		SandboxVars.CarAlarm = 2;
		SandboxVars.ChanceHasGas = 1;
		SandboxVars.InitialGas = 2;
		SandboxVars.CarGeneralCondition = 1;
		SandboxVars.RecentlySurvivorVehicles = 1;
		SandboxVars.SurvivorHouseChance = 1;
		SandboxVars.VehicleStoryChance = 1;
		
		SandboxVars.ZombieLore = {
			Speed = 2,
			Strength = 2,
			Toughness = 2,
			Transmission = 1,
			Mortality = 5,
			Reanimate = 3,
			Cognition = 3,
			Memory = 2,
			Decomp = 1,
			Sight = 3,
			Hearing = 3,
			Smell = 2,
			ThumpNoChasing = 0,
        }
        
        -- Other params check in other scenarios!
	end,

	onStart = function()
		-- climate
		local clim = getClimateManager();
		local w = clim:getWeatherPeriod();
		if w:isRunning() then
			clim:stopWeatherAndThunder();
		end
		-- remove fog
		local var = clim:getClimateFloat(5);
		var:setEnableOverride(true);
		var:setOverride(0, 1);
		--------------------------------

		-- Player
		local playerObj = getPlayer();
		local inv = playerObj:getInventory();
		local visual = playerObj:getHumanVisual();

		playerObj:setGhostMode(true);
		playerObj:setGodMod(true)
		
		playerObj:clearWornItems();
		playerObj:getInventory():clear();

		-- Visual
		playerObj:setFemale(false);
		playerObj:getDescriptor():setFemale(false);
		playerObj:getDescriptor():setForename("Aiteron")
		playerObj:getDescriptor():setSurname("")
		visual:setBeardModel("Full");
		visual:setHairModel("Messy");
		local immutableColor = ImmutableColor.new(0.105, 0.09, 0.086, 1)
		visual:setHairColor(immutableColor)
		visual:setBeardColor(immutableColor)
		visual:setSkinTextureIndex(2);
		playerObj:resetModel();

		local clothes = inv:AddItem("Base.Tshirt_DefaultTEXTURE_TINT");
		local color = ImmutableColor.new(0.25, 0.36, 0.36, 1)
		clothes:getVisual():setTint(color);
		playerObj:setWornItem(clothes:getBodyLocation(), clothes);
		clothes = inv:AddItem("Base.Trousers_Denim");
		clothes:getVisual():setTextureChoice(1);
		playerObj:setWornItem(clothes:getBodyLocation(), clothes);
		clothes = inv:AddItem("Base.Socks_Ankle");
		playerObj:setWornItem(clothes:getBodyLocation(), clothes);
		clothes = inv:AddItem("Base.Shoes_Black");
		playerObj:setWornItem(clothes:getBodyLocation(), clothes);
		--------------------------------------

		-- Skills
        playerObj:LevelPerk(Perks.Mechanics);
		-- all the perks are: Agility, Cooking, Melee, Crafting, Fitness, Strength, Blunt, Axe, Sprinting, Lightfoot, 
		--Nimble, Sneak, Woodwork, Aiming, Reloading, Farming, Survivalist, Fishing, Trapping, Passiv, Firearm, PlantScavenging, 
		--Doctor, Electricity, Blacksmith, MetalWelding, Melting, Mechanics, Spear, Maintenance, SmallBlade, LongBlade, SmallBlunt, Combat,

		getPlayer():getKnownRecipes():add("Basic Mechanics");
		getPlayer():getKnownRecipes():add("Intermediate Mechanics");
		getPlayer():getKnownRecipes():add("Advanced Mechanics");

		-- Items
		playerObj:getInventory():AddItem("TowingCar.Wrench");
		playerObj:getInventory():AddItems("TowingCar.LugWrench", 10);

		-- Vehicles
		local car = addVehicleDebug("Base.PickUpTruckMccoy", IsoDirections.W, nil, getCell():getGridSquare(3685.5, 5789, 0));
		car:repair();
		inv:AddItem(car:createVehicleKey());
	end
}
