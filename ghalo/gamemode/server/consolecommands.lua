
concommand.Add("cteam", function(ply, cmd, args)
	ply:PickTeam(tonumber(args[1]))
end)

concommand.Add("cgm", function(ply, cmd, args)
	if IsValid(ply) and ply:IsPlayer() and (ply:IsAdmin() or ply:IsSuperAdmin()) then
		ResetGamemode(args[1])
	end
end)

spawnPoints = {}

concommand.Add("s", function(ply, cmd, args)
	if IsValid(ply) and ply:IsPlayer() and (ply:IsAdmin() or ply:IsSuperAdmin()) then
		table.insert(spawnPoints, {
			pos = ply:GetPos(),
			cam = ply:GetAngles().yaw
		})

		local pos = ply:GetPos()
		local cam = ply:GetAngles()

		local ent = ents.Create("prop_physics")

		if ent and IsValid(ent) then
			ent:SetModel("models/hunter/blocks/cube025x025x025.mdl")
			ent:SetPos(Vector(pos.x, pos.y, pos.z + 80))
			ent:SetAngles(cam)
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
		end
	end
end)

weaponPoints = {}

concommand.Add("w", function(ply, cmd, args)
	if IsValid(ply) and ply:IsPlayer() and (ply:IsAdmin() or ply:IsSuperAdmin()) then
		table.insert(weaponPoints, {
			pos = ply:GetPos(),
			cam = ply:GetAngles(),
			wep = args[1]
		})

		local pos = ply:GetPos()
		local cam = ply:GetAngles()

		local ent = ents.Create("prop_physics")

		if ent and IsValid(ent) then
			ent:SetModel("models/hunter/blocks/cube025x025x025.mdl")
			ent:SetPos(Vector(pos.x, pos.y, pos.z + 80))
			ent:SetAngles(cam)
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
		end
	end
end)

concommand.Add("psp", function(ply, cmd, args)
	if IsValid(ply) and ply:IsPlayer() and (ply:IsAdmin() or ply:IsSuperAdmin()) then
		print("")
		for k, v in pairs(spawnPoints) do
			print("            {pos = Vector(" .. math.floor(v.pos.x) .. ", " .. math.floor(v.pos.y) .. ", " .. math.floor(v.pos.z + 61) .. "), cam = " .. math.floor(v.cam) .. "},")
		end
		print("")
	end
end)

concommand.Add("pwp", function(ply, cmd, args)
	if IsValid(ply) and ply:IsPlayer() and (ply:IsAdmin() or ply:IsSuperAdmin()) then
		print("")
		for k, v in pairs(weaponPoints) do
			print("        {pos = Vector(" .. math.floor(v.pos.x) .. ", " .. math.floor(v.pos.y) .. ", " .. math.floor(v.pos.z + 61) .. "), ang = Angle(" .. math.floor(v.cam.pitch) .. ", " .. math.floor(v.cam.yaw) .. ", " .. math.floor(v.cam.roll) .. "), name = \"" .. v.wep .. "\"},")
		end
		print("")
	end
end)

concommand.Add("cgm", function(ply, cmd, args)
	if IsValid(ply) and ply:IsPlayer() and (ply:IsAdmin() or ply:IsSuperAdmin()) then
		ResetGametype(tonumber(args[1]))
	end
end)

concommand.Add("cend", function(ply, cmd, args)
	if IsValid(ply) and ply:IsPlayer() and (ply:IsAdmin() or ply:IsSuperAdmin()) then
		Win(tonumber(args[1]))
	end
end)

-- Custom Chat commands
hook.Add("PlayerSay", "textCommands", function(ply, text, public)
	if (text == "!stuck") then
		ply:KillSilent()
	end
end)

concommand.Add("vote", function(ply, cmd, args)
	if IsValid(ply) and ply:IsPlayer() then 
		local optionPicked = tonumber(args[1])

		if choices and choices[optionPicked] then
			local oldID = nil

			if whoseVoted[ply:SteamID()] then
				oldID = whoseVoted[ply:SteamID()]
				choices[oldID].Votes = choices[oldID].Votes - 1
			end

			choices[optionPicked].Votes = choices[optionPicked].Votes + 1

			whoseVoted[ply:SteamID()] = optionPicked

			for playerID, ply in pairs(player.GetAll()) do
				if oldID then
					ply:SetNWInt("choice" .. oldID .. "Votes", choices[oldID].Votes)
				end
				ply:SetNWInt("choice" .. optionPicked .. "Votes", choices[optionPicked].Votes)
			end
		end
	end
end)

