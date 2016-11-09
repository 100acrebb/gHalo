
local player = FindMetaTable("Player")

util.AddNetworkString("database")

function player:ShortSteamID()
	local id = self:SteamID()
	local id = tostring(id)
	local id = string.Replace(id, "STEAM_0:0:", "")
	local id = string.Replace(id, "STEAM_0:1:", "")
	return id
end

local oldPrint = print
local function print(s)
	oldPrint("database.lua: " .. s)
end

function player:databaseDefault()
	self:databaseSetValue("money", 100)
	self:databaseSetValue("xp", 0)
	self:databaseSetValue("hunger", 0)
	local i = {}
	i["soda1"] = {amount = 10}
	i["soda2"] = {amount = 10}
	self:databaseSetValue("inventory", i)
end

function player:databaaseNetworkedData()
	local money = self:databaseGetValue("money")
	local xp = self:databaseGetValue("xp")
	local hunger = self:databaseGetValue("hunger")

	self:SetNWInt("money", money)
	self:SetNWInt("xp", xp)
	self:SetNWInt("hunger", hunger)

	self:KillSilent()
	self:Spawn()
end

function player:databaseFolders()
	return "gHalo/players/" .. self:ShortSteamID() .. "/"
end

function player:databasePath()
	return self:databaseFolders() .. "database.txt"
end

function player:databaseSet(dict)
	self.database = dict
end

function player:databaseGet()
	return self.database
end

function player:databaseCheck()
	self.database = {}
	local f = self:databaseExists()
	if f then
		self:databaseRead()
	else
		self:databaseCreate()
	end

	self:databaseSend()
	self:databaaseNetworkedData()
end

function player:databaseSend()
	net.Start("database")
	net.WriteTable(self:databaseGet())
	net.Send(self)
	print("Sent database")
end

function player:databaseExists()
	local f = file.Exists(self:databasePath(), "DATA")
	return f
end

function player:databaseRead()
	local str = file.Read(self:databasePath(), "DATA")
	self:databaseSet(util.KeyValuesToTable(str))
end

function player:databaseSave()
	local str = util.TableToKeyValues(self.database)
	local f = file.Write(self:databasePath(), str)
	self:databaseSend()
end

function player:databaseCreate()
	self:databaseDefault()
	local b = file.CreateDir(self:databaseFolders())
	print("Creating database.")
	self:databaseSave()
end

function player:databaseDisconnect()
	self:databaseSave()
end

function player:databaseSetValue(name, v)
	if not v then return end

	if type(v) == "table" then
		if name == "inventory" then
			for k, b in pairs(v) do
				if b.amount <= 0 then
					v[k] = nil
				end
			end
		end
	end

	local d = self:databaseGet()
	d[name] = v

	self:databaseSave()
end

function player:databaseGetValue(name)
	local d = self:databaseGet()
	return d[name]
end

-- function GM:ShowHelp(player)
-- 	player:ConCommand("inventory")
-- end
