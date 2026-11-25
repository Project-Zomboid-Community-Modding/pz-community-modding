if not FireBrushUI then return end

local FireBrushUI_addFire = FireBrushUI.addFire
function FireBrushUI:addFire(square)
	if isClient() then return FireBrushUI_addFire(self, square) end
	IsoFireManager.StartFire(getCell(), square, true, 100, 500)
end

local FireBrushUI_addSmoke = FireBrushUI.addSmoke
function FireBrushUI:addSmoke(square)
	if isClient() then return FireBrushUI_addSmoke(self, square) end
	IsoFireManager.StartSmoke(getCell(), square, true, 100, 500)
end

local FireBrushUI_addExplosion = FireBrushUI.addExplosion
function FireBrushUI:addExplosion(square)
	if isClient() then return FireBrushUI_addExplosion(self, square) end
	IsoFireManager.explode(getCell(), square, 100)
end
