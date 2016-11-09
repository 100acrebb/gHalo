
local items = {}

function getItems(name)
	if items[name] then
		return items[name]
	end
	return false
end

items["soda1"] = {
	name = "Blueberry Soda",
	description = "The Blueberry finest soda ever.",
	ent = "item_basic",
	prices = {
		buy = 18,
		sell = 9
	},
	model = "models/props_junk/PopCan01a.mdl",
	skin = 0,
	buttonDist = 32,

	use = (function (player, ent)
		if player:isValid() then
			player:AddHealth(2)
			if ent then
				ent:Remove()
			end
		end
	end),

	spawn = (function (player, ent)
		ent:SetItemName("Soda")
	end)
}

items["soda2"] = {
	name = "Strawberry Soda",
	description = "The Strawberry finest soda ever.",
	ent = "item_basic",
	prices = {
		buy = 18,
		sell = 9
	},
	model = "models/props_junk/PopCan01a.mdl",
	skin = 1,
	buttonDist = 32,

	use = (function (player, ent)
		if player:isValid() then
			player:AddHealth(2)
			if ent then
				ent:Remove()
			end
		end
	end),

	spawn = (function (player, ent)
		ent:SetItemName("Soda")
	end)
}

items["soda3"] = {
	name = "Orange Soda",
	description = "The Orange finest soda ever.",
	ent = "item_basic",
	prices = {
		buy = 18,
		sell = 9
	},
	model = "models/props_junk/PopCan01a.mdl",
	skin = 2,
	buttonDist = 32,

	use = (function (player, ent)
		if player:isValid() then
			player:AddHealth(2)
			if ent then
				ent:Remove()
			end
		end
	end),

	spawn = (function (player, ent)
		ent:SetItemName("Soda")
	end)
}
