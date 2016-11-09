
local player = FindMetaTable("Player")

function SetUpSpawns()
	-- Set up initial custom spawns
	if ShowSpawnPoints and spawns then
		if CurGT.SpawnType then
			print("Spawn Type: " .. CurGT.SpawnType)
			for teamID, spawnList in pairs(spawns) do
				print("TeamID: " .. teamID)
				for k, v in pairs(spawnList) do
					local ent = CreateEntBlock(v.pos.x, v.pos.y, v.pos.z, v.cam)

					if spawns[teamID][k].ent then
						spawns[teamID][k].ent:Destroy()
						spawns[teamID][k].ent = nil
					end

					spawns[teamID][k].ent = ent
				end
			end
		else
			for k, v in pairs(spawns) do
				local ent = CreateEntBlock(v.pos.x, v.pos.y, v.pos.z, v.cam)

				if spawns[k].ent then
					spawns[k].ent:Destroy()
					spawns[k].ent = nil
				end

				spawns[k].ent = ent
			end
		end
	end
end

function CreateEntBlock(x, y, z, cam)
	local ent = ents.Create("prop_physics")

	ent:SetModel("models/hunter/blocks/cube025x025x025.mdl")
	ent:SetPos(Vector(x, y, z))
	ent:SetAngles(Angle(5, cam, 0))
	ent:Spawn()

	local phy = ent:GetPhysicsObject()

	if phy and IsValid(phy) then
		phy:EnableCollisions(false)
		phy:EnableMotion(false)
		ent:SetNoDraw(false)
		print("physics good!")
	else
		print("Phy didn't work.")
	end

	return ent
end

function player:SetSpectate()
	self:SetTeam(TEAM_SPECTATOR)
	self:StripWeapons()
	self:SetNoDraw(true)
	self:KillSilent()

	pang = self:GetAngles()
	self:SetAngles(Angle(0, pang.y, 0))
end

function player:PickTeam(teamID)
	-- This picks which team the player should
	-- be on and sets the player's color.

	if !teamID then
		if CurGT.PickTeam then
			teamID = CurGT.PickTeam(self)
		else
			if !CurGT.IsTeam then
				teamID = 1
			else
				teamID = team.BestAutoJoinTeam()
			end
		end
	end
	
	local curTeam = CurGT.Teams[teamID]

	if !curTeam then
		print("Something went super wrong here... " .. teamID)

		if CurGT.PickTeam then
			teamID = CurGT.PickTeam(self)
		else
			teamID = team.BestAutoJoinTeam()
		end
	end

	local color = curTeam.Color

	print("Set team to: " .. teamID)

	self:SetTeam(teamID)

	if !CurGT.IsTeam then
		local mods = CurGT.Models
		local mod = math.random(#mods)

		self:SetModel(mods[mod][1])
		color = mods[mod][2]

		self.mod = mods[mod]

		self:SetNWInt("Color", mod)
	end

	self:SetPlayerColor(Vector(color.r / 255, color.g / 255, color.b / 255))
	self:KillSilent()
end

function player:SetSpawnPoints()
	if spawns then
		local random_entry = nil
		local pos = nil
		local cam = nil

		if CurGT and CurGT.SpawnType then
			if spawns[self:Team()] and spawns[self:Team()][1] and spawns[self:Team()][1].pos then
				random_entry = math.random(#spawns[self:Team()])
				pos = spawns[self:Team()][random_entry].pos
				cam = spawns[self:Team()][random_entry].cam
			end
		else
			random_entry = math.random(#spawns)
			pos = spawns[random_entry].pos
			cam = spawns[random_entry].cam
		end

		if pos and cam then
			self:SetPos(Vector(pos.x, pos.y, pos.z - 61))
			self:SetAngles(Angle(1, cam, 0))
		end
	end
end

function player:Spawned()
	-- This gives the current player their
	-- weapons.

	self:SetSpawnPoints()

	if !CurGT then return false end

	local curTeam = CurGT["Teams"][self:Team()]

	-- Check to make sure valid team.
	if !curTeam then
		print("Team not found!")
		return false
	end

	if CurGT.IsTeam then
		self:SetModel(curTeam.Model)
		-- self:SetPlayerColor(curTeam.Color.r / 255, self.Color.g / 255, self.Color.b / 255)
	else
		self:SetModel(self.mod[1])
		-- self:SetPlayerColor(self.mod[2].r / 255, self.mod[2].g / 255, self.mod[2].b / 255)
	end

	if curTeam.Gravity then
		self:SetGravity(curTeam.Gravity)
	else
		self:SetGravity(0.4)
	end

	self:GiveWeapons(curTeam.Weapons)
	self:SetShield(curTeam.Shield)
	self:SetHealth(curTeam.Health)
end

function player:GiveWeapons(weapons)
	self:StripWeapons()

	-- Check to make sure weapons isn't nil.
	if !weapons then return false end

	for k, weapon in pairs(weapons) do
		self:Give(weapon)
	end
end

function player:SetShield(amount)
	self.shield = amount
	print("Set shields to: " .. amount)
	self:SetNWInt("Shield", self.shield)
end

function player:Shield()
	return self.shield
end
