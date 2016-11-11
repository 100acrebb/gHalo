
local database = {}

local function databaseReceive(tab)
	database = tab
end

net.Receive("database", function(len)
	print("Got something")
	local tab = net.ReadTable()
	databaseReceive(tab)
end)

function databaseTable()
	return database
end

function databaseGetValue(name)
	local d = databaseTable()
	if not d[name] then
		return -1
	end
	return d[name]
end

function inventoryTable()
	return databaseGetValue("inventory") or {}
end

function inventoryHasItem(name, amount)
	if not amount then amount = 1 end

	local i = inventoryDict()

	if i then
		if i[name] then
			if i[name].amount >= amount then
				return true
			else
				return false
			end
		else
			return false
		end
	else
		return false
	end
end

-- concommand.Add("inventory", inventoryMenu)
