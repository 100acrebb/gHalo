
-- Author: Vader
-- Created: August 27th

table.insert(Gamemodes,
{
	Name = "1 Flag CTF",
	Description = "Red team steals Blue team's flag and brings it back to base.",
	IsTeam = true,
	FriendlyFire = false,
	Teams = {
		[1] = {
			Name = "Red",
			Weapons = {
				"h3_ar_swep",
				"h3_magnum_swep"
			},
			Color = Colors.Red,
			Model = "models/halo2/spartan_red.mdl",
			Health = 100,
			Shield = 100,
			ShieldRechargeWait = 5,
			ShieldRechargeRate = 10,
			RespawnTime = 10,
			Gravity = 0.4
		},
		[2] = {
			Name = "Blue",
			Weapons = {
				"h3_ar_swep",
				"h3_magnum_swep"
			},
			Color = Colors.Blue,
			Model = "models/halo2/spartan_blue.mdl",
			Health = 100,
			Shield = 100,
			ShieldRechargeWait = 5,
			ShieldRechargeRate = 10,
			RespawnTime = 10,
			Gravity = 0.4
		}
	},
	HealthRegen = false,
	Radar = false,
	TimeLimit = 4,
	PointsToWin = 3,
	PointsOnWin = 1,
	PointsOnKill = 0,
	PointsOnDeath = 0,
	PointsOnTeamKill = 0,
	PointsOnSuicide = 0,
	SupportedMaps = {
		"halo_ascension_fix3",
		"gm_blood_gulch_v3"
	},
	GameType = "capturetheflag",
	SpawnType = "team",
	TeamWinsOnTimeout = 1,

	-- Metadata
	CurrentRound = 1,
	MaxRounds = 5,

	ents = {
		halo_ascension_fix3 = {
			{
				entity = "halo_flag",
				pos = Vector(81, 2349, 173), -- 169
				team = 1,
				model = "models/props_wasteland/prison_lamp001c.mdl",
				ang = Angle(0, 0, 0),
				name = "Target",
				noCollideButTrigger = true
			},
			{
				entity = "halo_flag",
				pos = Vector(194, -1911, -23),
				team = 2,
				model = "models/gmod_governmentflags.mdl",
				ang = Angle(0, 0, 0),
				name = "Blue Team's Flag",
				noCollideButTrigger = true
			}
		},
		gm_blood_gulch_v3 = {
			{
				entity = "halo_flag",
				pos = Vector(3445, -5499, 1363), 
				team = 1,
				model = "models/props_wasteland/prison_lamp001c.mdl",
				ang = Angle(0, 0, 0),
				name = "Target",
				noCollideButTrigger = true
			},
			{
				entity = "halo_flag",
				pos = Vector(-3987, 5272, 1367),
				team = 2,
				model = "models/gmod_governmentflags.mdl",
				ang = Angle(0, 0, 0),
				name = "Red Team's Flag",
				noCollideButTrigger = true
			}
		}
	},

	ShouldWin = function(winner, score, notTie)
		for k, v in pairs(player.GetAll()) do
			if v:Team() == 1 then
				v.NextTeam = 2
			elseif v:Team() == 2 then
				v.NextTeam = 1
			end
		end

		if CurGT.MaxRounds == CurGT.CurrentRound or score >= CurGT.PointsToWin then
			return true
		else
			CurGT.CurrentRound = CurGT.CurrentRound + 1
			if notTie then
				if winner == 1 then
					ChangeTeamData(1, "Score", -1, true)
					ChangeTeamData(2, "Score", 1, true)
				elseif winner == 2 then
					ChangeTeamData(1, "Score", 1, true)
					ChangeTeamData(2, "Score", -1, true)
				end
			else
				local red = GetTeamData(1, "Score")
				local blue = GetTeamData(2, "Score")
				SetTeamData(1, "Score", blue, true)
				SetTeamData(2, "Score", red, true)
			end
			return false
		end
	end,
	OnDeath = function(victim, attacker)
		if victim.hasEnt and IsValid(victim.hasEnt) then
			SendSound("ghalo/voiceover/flagdropped", victim)
			local pos = victim.hasEnt:GetPos()
			victim.hasEnt:SetPos(Vector(pos.x, pos.y, pos.z - 40))
			victim.hasEnt.owner = nil
			victim.hasEnt = nil
		end
	end,
	OnTouch = function(ent, player)
		if string.match(player:GetName(), "^Bot..") ~= nil then return false end

		if ent.team ~= player:Team() then
			if !ent.owner and player:Team() ~= 2 then
				SendSound("ghalo/voiceover/flagtaken", player)

				for k, v in pairs(team.GetPlayers(ent.team)) do
					SendSound("ghalo/voiceover/flagstolen", v)
				end
				ent.owner = player
				player.hasEnt = ent
			end
		else
			if ent.spawn ~= ent:GetPos() and !ent.owner then
				for k, v in pairs(team.GetPlayers(ent.team)) do
					SendSound("ghalo/voiceover/flagrecovered", v)
				end
				ent:SetPos(ent.spawn)
			else
				if player.hasEnt and IsValid(player.hasEnt) then
					if player.hasEnt.team ~= player:Team() then
						SendSound("ghalo/voiceover/flagcaptured", v)
						player.hasEnt:SetPos(player.hasEnt.spawn)
						player.hasEnt.owner = nil
						player.hasEnt = nil
						Win(player:Team())
						ChangePlayerData(player, "Score", 1)
					end
				end
			end
		end
	end
})

-- Author: Vader
-- Created: August 27th

table.insert(Gamemodes,
{
	Name = "360 No Scopes",
	Description = "No scope 360 your way to the top! The player with the most points win.",
	IsTeam = false,
	FriendlyFire = false,
	Teams = {
		[1] = {
			Name = "Red",
			Weapons = {
				"h3_sr_swep",
			},
			Color = Colors.Red,
			Model = "models/halo2/spartan_red.mdl",
			Health = 10,
			Shield = 0,
			ShieldRechargeWait = 5,
			ShieldRechargeRate = 10,
			RespawnTime = 3,
			Gravity = 0.5,
			BottomlessClip = true
		}
	},
	-- If !IsTeam, randomly pick one of these
	Models = AllPlayerModels,
	HealthRegen = false,
	Radar = false,
	TimeLimit = 15,
	PointsToWin = 100,
	PointsOnKill = 1,
	PointsOnDeath = 0,
	PointsOnTeamKill = 0,
	PointsOnSuicide = -1,
	SupportedMaps = nil,
	GameType = "slayer"
})

-- Author: Vader
-- Created: August 27th

table.insert(Gamemodes,
{
	Name = "Assault",
	Description = "Red team needs to plant the bomb in Blue team's base. Blue team must hold off Red team.",
	IsTeam = true,
	FriendlyFire = false,
	Teams = {
		[1] = {
			Name = "Red",
			Weapons = {
				"h3_ar_swep",
				"h3_magnum_swep"
			},
			Color = Colors.Red,
			Model = "models/halo2/spartan_red.mdl",
			Health = 100,
			Shield = 100,
			ShieldRechargeWait = 5,
			ShieldRechargeRate = 10,
			RespawnTime = 10,
			Gravity = 0.4
		},
		[2] = {
			Name = "Blue",
			Weapons = {
				"h3_ar_swep",
				"h3_magnum_swep"
			},
			Color = Colors.Blue,
			Model = "models/halo2/spartan_blue.mdl",
			Health = 100,
			Shield = 100,
			ShieldRechargeWait = 5,
			ShieldRechargeRate = 10,
			RespawnTime = 10,
			Gravity = 0.4
		}
	},
	HealthRegen = false,
	Radar = false,
	TimeLimit = 5,
	PointsToWin = 3,
	PointsOnWin = 1,
	PointsOnKill = 0,
	PointsOnDeath = 0,
	PointsOnTeamKill = 0,
	PointsOnSuicide = 0,
	SupportedMaps = {
		"halo_ascension_fix3",
		"gm_blood_gulch_v3"
	},
	GameType = "assault",
	SpawnType = "team",
	TeamWinsOnTimeout = 1,
	WeaponType = "Normal",
	WeaponRespawnRate = 120,

	-- Metadata
	CurrentRound = 1,
	MaxRounds = 5,

	ents = {
		halo_ascension_fix3 = {
			{
				entity = "halo_flag",
				pos = Vector(81, 2349, 173), -- 169
				team = 1,
				model = "models/props_lab/crematorcase.mdl",
				ang = Angle(0, 0, 0),
				name = "Bomb",
				noCollideButTrigger = true
			},
			{
				entity = "halo_flag",
				pos = Vector(194, -1911, -20),
				team = 2,
				model = "models/props_wasteland/prison_lamp001c.mdl",
				ang = Angle(0, 0, 0),
				name = "Target",
				noCollideButTrigger = true
			}
		},
		gm_blood_gulch_v3 = {
			{
				entity = "halo_flag",
				pos = Vector(3445, -5499, 1363), 
				team = 1,
				model = "models/props_lab/crematorcase.mdl",
				ang = Angle(0, 0, 0),
				name = "Bomb",
				noCollideButTrigger = true
			},
			{
				entity = "halo_flag",
				pos = Vector(-3987, 5272, 1367),
				team = 2,
				model = "models/props_wasteland/prison_lamp001c.mdl",
				ang = Angle(0, 0, 0),
				name = "Target",
				noCollideButTrigger = true
			}
		}
	},

	ShouldWin = function(winner, score)
		for k, v in pairs(player.GetAll()) do
			if v:Team() == 1 then
				v.NextTeam = 2
			elseif v:Team() == 2 then
				v.NextTeam = 1
			end
		end

		if CurGT.MaxRounds == CurGT.CurrentRound or score >= CurGT.PointsToWin then
			return true
		else
			CurGT.CurrentRound = CurGT.CurrentRound + 1
			if notTie then
				if winner == 1 then
					ChangeTeamData(1, "Score", -1, true)
					ChangeTeamData(2, "Score", 1, true)
				elseif winner == 2 then
					ChangeTeamData(1, "Score", 1, true)
					ChangeTeamData(2, "Score", -1, true)
				end
			else
				local red = GetTeamData(1, "Score")
				local blue = GetTeamData(2, "Score")
				SetTeamData(1, "Score", blue, true)
				SetTeamData(2, "Score", red, true)
			end
			return false
		end
	end,
	OnDeath = function(victim, attacker)
		if victim.hasEnt and IsValid(victim.hasEnt) then
			SendSound("ghalo/voiceover/bombdropped", victim)
			local pos = victim.hasEnt:GetPos()
			victim.hasEnt:SetPos(Vector(pos.x, pos.y, pos.z - 40))
			victim.hasEnt.owner = nil
			victim.hasEnt = nil
		end
	end,
	OnTouch = function(ent, player)
		if player:SteamID() == "BOT" then return false end

		if !ent.armed then
			if ent.team == player:Team() then
				if !ent.owner and player:Team() ~= 2 then
					ent.owner = player
					player.hasEnt = ent
					SendSound("ghalo/voiceover/bombtaken", player)
				end
			else
				if player:Team() == 2 and ent.spawn ~= ent:GetPos() and !ent.owner then
					SendSound("ghalo/voiceover/bombreset")
					ent:SetPos(ent.spawn)
				else
					if player.hasEnt and IsValid(player.hasEnt) then
						if player.hasEnt.team == player:Team() and ent.team ~= player:Team() then
							player.hasEnt:SetPos(ent:GetPos())
							player.hasEnt.owner = nil
							player.hasEnt:Remove()
							ent.armed = true

							ChangePlayerData(player, "Score", 1)

							SendSound("ghalo/voiceover/bombarmed")

							ent:Ignite(3, 0)
							
							timer.Simple(3, function()
								local explode = ents.Create( "env_explosion" )
								explode:SetPos( ent:GetPos() )
								explode:SetOwner( player )
								explode:Spawn()
								explode:SetKeyValue( "iMagnitude", "600" )
								explode:Fire( "Explode", 0, 0 )
								explode:EmitSound( "weapon_AWP.Single", 400, 400 )
							end)

							timer.Simple(4, function()
								Win(player:Team())
							end)
						end
					end
				end
			end
		end
	end
})

-- Author: Vader
-- Created: August 27th

table.insert(Gamemodes,
{
	Name = "Big Team Rockets",
	Description = "The team with the most kills win.",
	IsTeam = true,
	FriendlyFire = false,
	Teams = {
		[1] = {
			Name = "Red",
			Weapons = {
				"h3_rocket_launcher",
				"h3_shotgun"
			},
			Color = Colors.Red,
			Model = "models/halo2/spartan_red.mdl",
			Health = 100,
			Shield = 0,
			ShieldRechargeWait = 5,
			ShieldRechargeRate = 10,
			RespawnTime = 5,
			Gravity = 0.2,
			InfiniteAmmo = true
		},
		[2] = {
			Name = "Blue",
			Weapons = {
				"h3_rocket_launcher",
				"h3_shotgun"
			},
			Color = Colors.Blue,
			Model = "models/halo2/spartan_blue.mdl",
			Health = 100,
			Shield = 0,
			ShieldRechargeWait = 5,
			ShieldRechargeRate = 10,
			RespawnTime = 5,
			Gravity = 0.2,
			InfiniteAmmo = true
		}
	},
	HealthRegen = false,
	Radar = false,
	TimeLimit = 15,
	PointsToWin = 100,
	PointsOnKill = 1,
	PointsOnDeath = 0,
	PointsOnTeamKill = -1,
	PointsOnSuicide = 0,
	SupportedMaps = nil,
	GameType = "slayer"
})

-- Author: Vader
-- Created: August 27th

table.insert(Gamemodes,
{
	Name = "Big Team Slayer",
	Description = "The team with the most kills win.",
	IsTeam = true,
	FriendlyFire = false,
	Teams = {
		[1] = {
			Name = "Red",
			Weapons = {
				"h3_ar_swep",
				"h3_magnum_swep"
			},
			Color = Colors.Red,
			Model = "models/halo2/spartan_red.mdl",
			Health = 100,
			Shield = 100,
			ShieldRechargeWait = 5,
			ShieldRechargeRate = 10,
			RespawnTime = 5
		},
		[2] = {
			Name = "Blue",
			Weapons = {
				"h3_ar_swep",
				"h3_magnum_swep"
			},
			Color = Colors.Blue,
			Model = "models/halo2/spartan_blue.mdl",
			Health = 100,
			Shield = 100,
			ShieldRechargeWait = 5,
			ShieldRechargeRate = 10,
			RespawnTime = 5
		}
	},
	HealthRegen = false,
	WeaponType = "Normal",
	Radar = false,
	TimeLimit = 15,
	PointsToWin = 50,
	PointsOnKill = 1,
	PointsOnDeath = 0,
	PointsOnTeamKill = -1,
	PointsOnSuicide = 0,
	SupportedMaps = nil,
	GameType = "slayer"
})

-- Author: Vader
-- Created: August 27th

table.insert(Gamemodes,
{
	Name = "Capture The Flag",
	Description = "Aquire the other team's flag and bring it back to base. The team with most points win.",
	IsTeam = true,
	FriendlyFire = false,
	Teams = {
		[1] = {
			Name = "Red",
			Weapons = {
				"h3_ar_swep",
				"h3_magnum_swep"
			},
			Color = Colors.Red,
			Model = "models/halo2/spartan_red.mdl",
			Health = 100,
			Shield = 100,
			ShieldRechargeWait = 5,
			ShieldRechargeRate = 10,
			RespawnTime = 10,
			Gravity = 0.4
		},
		[2] = {
			Name = "Blue",
			Weapons = {
				"h3_ar_swep",
				"h3_magnum_swep"
			},
			Color = Colors.Blue,
			Model = "models/halo2/spartan_blue.mdl",
			Health = 100,
			Shield = 100,
			ShieldRechargeWait = 5,
			ShieldRechargeRate = 10,
			RespawnTime = 10,
			Gravity = 0.4
		}
	},
	HealthRegen = false,
	Radar = false,
	WeaponType = "Normal",
	TimeLimit = 5,
	PointsToWin = 3,
	PointsOnWin = 1,
	PointsOnKill = 0,
	PointsOnDeath = 0,
	PointsOnTeamKill = 0,
	PointsOnSuicide = 0,
	SupportedMaps = {
		"halo_ascension_fix3",
		"gm_blood_gulch_v3"
	},
	GameType = "capturetheflag",
	SpawnType = "team",
	NoWinOnTimeout = true,

	-- Metadata
	CurrentRound = 1,
	MaxRounds = 5,

	ents = {
		halo_ascension_fix3 = {
			{
				entity = "halo_flag",
				pos = Vector(81, 2349, 169), 
				team = 1,
				model = "models/gmod_governmentflags.mdl",
				ang = Angle(0, 0, 0),
				name = "Red Team's Flag",
				noCollideButTrigger = true
			},
			{
				entity = "halo_flag",
				pos = Vector(194, -1911, -23),
				team = 2,
				model = "models/gmod_governmentflags.mdl",
				ang = Angle(0, 0, 0),
				name = "Blue Team's Flag",
				noCollideButTrigger = true
			}
		},
		gm_blood_gulch_v3 = {
			{
				entity = "halo_flag",
				pos = Vector(3445, -5499, 1363), 
				team = 1,
				model = "models/gmod_governmentflags.mdl",
				ang = Angle(0, 0, 0),
				name = "Red Team's Flag",
				noCollideButTrigger = true
			},
			{
				entity = "halo_flag",
				pos = Vector(-3987, 5272, 1363),
				team = 2,
				model = "models/gmod_governmentflags.mdl",
				ang = Angle(0, 0, 0),
				name = "Blue Team's Flag",
				noCollideButTrigger = true
			}
		}
	},

	ShouldWin = function(winner, score)
		if CurGT.MaxRounds == CurGT.CurrentRound or score >= CurGT.PointsToWin then
			return true
		else
			CurGT.CurrentRound = CurGT.CurrentRound + 1
			return false
		end
	end,
	OnDeath = function(victim, attacker)
		if victim.hasEnt and IsValid(victim.hasEnt) then
			SendSound("ghalo/voiceover/flagdropped", victim)
			local pos = victim.hasEnt:GetPos()
			victim.hasEnt:SetPos(Vector(pos.x, pos.y, pos.z - 40))
			victim.hasEnt.owner = nil
			victim.hasEnt = nil
		end
	end,
	OnTouch = function(ent, player)
		if string.match(player:GetName(), "^Bot..") ~= nil then return false end

		if ent.team ~= player:Team() then
			if !ent.owner then
				ent.owner = player
				player.hasEnt = ent

				SendSound("ghalo/voiceover/flagtaken", player)

				for k, v in pairs(team.GetPlayers(ent.team)) do
					SendSound("ghalo/voiceover/flagstolen", v)
				end
			end
		else
			if ent.spawn ~= ent:GetPos() and !ent.owner then
				ent:SetPos(ent.spawn)
				for k, v in pairs(team.GetPlayers(ent.team)) do
					SendSound("ghalo/voiceover/flagrecovered", v)
				end
			else
				if player.hasEnt and IsValid(player.hasEnt) then
					if player.hasEnt.team ~= player:Team() then
						SendSound("ghalo/voiceover/flagcaptured", v)
						player.hasEnt:SetPos(player.hasEnt.spawn)
						player.hasEnt.owner = nil
						player.hasEnt = nil
						Win(player:Team())
						ChangePlayerData(player, "Score", 1)
					end
				end
			end
		end
	end
})

table.insert(Gamemodes,
{
	Name = "Infection",
	Description = "The humans need to stay alive as long as possible. If they die, they turn infected.",
	IsTeam = true,
	FriendlyFire = false,
	Teams = {
		[1] = {
			Name = "Humans",
			Weapons = {
				"h3_shotgun",
				"h3_magnum_swep"
			},
			Color = Colors.Red,
			Model = "models/halo2/spartan_red.mdl",
			Health = 100,
			Shield = 0,
			ShieldRechargeWait = 5,
			ShieldRechargeRate = 10,
			RespawnTime = 5
		},
		[2] = {
			Name = "Infected",
			Weapons = {
				"h3_energy_sword"
			},
			Color = Colors.Blue,
			Model = "models/player/lordvipes/h2_elite/eliteplayer.mdl",
			Health = 100,
			Shield = 300,
			ShieldRechargeWait = 5,
			ShieldRechargeRate = 10,
			RespawnTime = 5,
			Gravity = 0.2,
			BottomlessClip = true
		}
	},
	HealthRegen = false,
	Radar = false,
	TimeLimit = 4,
	PointsToWin = 3,
	PointsOnWin = 1,
	PointsOnKill = 0,
	PointsOnDeath = 0,
	PointsOnTeamKill = 0,
	PointsOnSuicide = 0,
	SupportedMaps = nil,
	TeamWinsOnTimeout = 1,
	MixTeams = true,

	ShouldWin = function(winner, score)
		if score >= CurGT.PointsToWin then
			return true
		else
			return false
		end
	end,
	OnDeath = function(victim, attacker)
		-- The human got killed by zombie
		if attacker:Team() == 2 and victim:Team() == 1 then
			-- Make victim infected
			MessageAllPlayers(
				victim:GetName() .. " has become infected!",
				Color(255, 200, 0)
			)
			SendSound("ghalo/voiceover/newzombie", victim)
			victim:PickTeam(2)
		end

		ChangePlayerData(attacker, "Score", 1)

		local humanTeam = team.GetPlayers(1)

		if #humanTeam <= 1 then
			if #humanTeam == 1 then
				MessageAllPlayers(
					humanTeam[1]:GetName() .. " is the last man standing!",
					Color(255, 200, 0)
				)
				SendSound("ghalo/voiceover/lastmanstanding", humanTeam[1])
			else
				Win(2)
			end
		end
	end,
	PickTeam = function(ply)
		local playerCount = #player.GetAll()
		local humanCount = #team.GetPlayers(1)
		local zombieCount = #team.GetPlayers(2)

		local minZombies = math.ceil(playerCount * .3)

		if playerCount <= 3 then
			if zombieCount <= 0 then
				SendSound("ghalo/voiceover/newzombie", ply)
				return 2
			else
				return 1
			end
		else
			if zombieCount < minZombies then
				SendSound("ghalo/voiceover/newzombie", ply)
				return 2
			else
				return 1
			end
		end
	end
})

-- Author: Vader
-- Created: August 27th

table.insert(Gamemodes,
{
	Name = "King of the Hill",
	Description = "Stand inside of the hill to gain points. The player with the most points win.",
	IsTeam = false,
	FriendlyFire = false,
	Teams = {
		[1] = {
			Name = "Red",
			Weapons = {
				"h3_ar_swep",
				"h3_magnum_swep"
			},
			Color = Colors.Red,
			Model = "models/halo2/spartan_red.mdl",
			Health = 100,
			Shield = 100,
			ShieldRechargeWait = 5,
			ShieldRechargeRate = 10,
			RespawnTime = 5,
			Gravity = 0.6
		}
	},
	HealthRegen = false,
	WeaponType = "Normal",
	Radar = false,
	TimeLimit = 15,
	PointsToWin = 50,
	PointsOnKill = 0,
	PointsOnDeath = 0,
	PointsOnTeamKill = 0,
	PointsOnSuicide = 0,
	SupportedMaps = {
		"halo_ascension_fix3",
	},
	GameType = "kingofthehill",

	-- Meta data
	MoveEveryPoint = 10,
	PointsOnTouch = 1,
	TouchWait = 2,

	-- If !IsTeam, randomly pick one of these
	Models = AllPlayerModels,

	ListOfPoints = {
		halo_ascension_fix3 = {
			{pos = Vector(-21, 154, 115 - 60), ang = Angle(0, 0, 0)},
			{pos = Vector(-505, -1436, 176 - 60), ang = Angle(0, 0, 0)},
			{pos = Vector(269, -1814, 40 - 60), ang = Angle(0, 0, 0)},
			{pos = Vector(1027, 304, -134 - 60), ang = Angle(0, 0, 0)},
			{pos = Vector(175, 2255, 344 - 60), ang = Angle(0, 0, 0)},
			{pos = Vector(-408, 1214, 132 - 60), ang = Angle(0, 0, 0)},
			{pos = Vector(716, -767, 82 - 60), ang = Angle(0, 0, 0)},
		},
	},

	-- Metadata
	totalPointsEarned = 0,

	ents = {
		halo_ascension_fix3 = {
			{
				entity = "halo_flag",
				pos = Vector(-21, 154, 115),
				team = 1,
				model = "models/hunter/blocks/cube6x6x2.mdl",
				ang = Angle(0, 0, 0),
				name = "Hill",
				noCollideButTrigger = true,
				mat = "models/effects/comball_sphere",
			}
		}
	},
	OnTouch = function(ent, player)
		if !player.lastPoint or CurTime() - CurGT.TouchWait > player.lastPoint then
			ChangePlayerData(player, "Score", CurGT.PointsOnTouch)
			CurGT.totalPointsEarned = CurGT.totalPointsEarned + 1

			if CurGT.totalPointsEarned >= CurGT.MoveEveryPoint then
				local points = CurGT.ListOfPoints[game.GetMap()]
				local newPoint = math.random(#points)
				ent:SetPos(points[newPoint].pos)
				ent:SetAngles(points[newPoint].ang)
				CurGT.totalPointsEarned = 0

				SendSound("ghalo/voiceover/hillmoved")
			end
			player.lastPoint = CurTime()
		end

	end
})

-- Author: Vader
-- Created: August 27th

table.insert(Gamemodes,
{
	Name = "MLG Slayer",
	Description = "The team with the most kills win.",
	IsTeam = true,
	FriendlyFire = false,
	Teams = {
		[1] = {
			Name = "Red",
			Weapons = {
				"h3_br_swep",
				"h3_magnum_swep"
			},
			Color = Colors.Red,
			Model = "models/halo2/spartan_red.mdl",
			Health = 100,
			Shield = 100,
			ShieldRechargeWait = 5,
			ShieldRechargeRate = 10,
			RespawnTime = 10,
			Gravity = 0.6
		},
		[2] = {
			Name = "Blue",
			Weapons = {
				"h3_br_swep",
				"h3_magnum_swep"
			},
			Color = Colors.Blue,
			Model = "models/halo2/spartan_blue.mdl",
			Health = 100,
			Shield = 100,
			ShieldRechargeWait = 5,
			ShieldRechargeRate = 10,
			RespawnTime = 10,
			Gravity = 0.6
		}
	},
	HealthRegen = false,
	Radar = false,
	TimeLimit = 15,
	PointsToWin = 40,
	PointsOnKill = 1,
	PointsOnDeath = 0,
	PointsOnTeamKill = 0,
	PointsOnSuicide = 0,
	SupportedMaps = nil,
	GameType = "slayer"
})

-- Author: Vader
-- Created: August 27th

table.insert(Gamemodes,
{
	Name = "Rocket Slayer",
	Description = "The player with the most kills win.",
	IsTeam = false,
	FriendlyFire = false,
	Teams = {
		[1] = {
			Name = "Red",
			Weapons = {
				"h3_rocket_launcher",
				"h3_shotgun"
			},
			Color = Colors.Red,
			Model = "models/halo2/spartan_red.mdl",
			Health = 100,
			Shield = 0,
			ShieldRechargeWait = 5,
			ShieldRechargeRate = 10,
			RespawnTime = 5,
			Gravity = 0.2,
			InfiniteAmmo = true
		}
	},
	-- If !IsTeam, randomly pick one of these
	Models = AllPlayerModels,
	HealthRegen = false,
	Radar = false,
	TimeLimit = 15,
	PointsToWin = 100,
	PointsOnKill = 1,
	PointsOnDeath = 0,
	PointsOnTeamKill = 0,
	PointsOnSuicide = -1,
	SupportedMaps = nil,
	GameType = "slayer"
})

-- Author: Vader
-- Created: August 27th

table.insert(Gamemodes,
{
	Name = "Slayer",
	Description = "The player with the most kills win.",
	IsTeam = false,
	FriendlyFire = false,
	Teams = {
		[1] = {
			Name = "Red",
			Weapons = {
				"h3_ar_swep",
				"h3_magnum_swep"
			},
			Color = Colors.Red,
			Model = "models/halo2/spartan_red.mdl",
			Health = 100,
			Shield = 100,
			ShieldRechargeWait = 5,
			ShieldRechargeRate = 10,
			RespawnTime = 5
		}
	},
	-- If !IsTeam, randomly pick one of these
	Models = AllPlayerModels,
	HealthRegen = false,
	WeaponType = "Normal",
	Radar = false,
	TimeLimit = 15,
	PointsToWin = 30,
	PointsOnKill = 1,
	PointsOnDeath = 0,
	PointsOnTeamKill = 0,
	PointsOnSuicide = -1,
	SupportedMaps = nil,
	GameType = "slayer"
})

-- Author: Vader
-- Created: August 27th

table.insert(Gamemodes,
{
	Name = "SWAT",
	Description = "The team with the most kills win.",
	IsTeam = true,
	FriendlyFire = false,
	Teams = {
		[1] = {
			Name = "Red",
			Weapons = {
				"h3_smg_swep_odst",
				"h3_odst_socom"
			},
			Color = Colors.Red,
			Model = "models/halo2/spartan_red.mdl",
			Health = 100,
			Shield = 0,
			ShieldRechargeWait = 5,
			ShieldRechargeRate = 10,
			RespawnTime = 10,
			Gravity = 0.6
		},
		[2] = {
			Name = "Blue",
			Weapons = {
				"h3_smg_swep_odst",
				"h3_odst_socom"
			},
			Color = Colors.Blue,
			Model = "models/halo2/spartan_blue.mdl",
			Health = 100,
			Shield = 0,
			ShieldRechargeWait = 5,
			ShieldRechargeRate = 10,
			RespawnTime = 10,
			Gravity = 0.6
		}
	},
	HealthRegen = false,
	Radar = false,
	TimeLimit = 15,
	PointsToWin = 40,
	PointsOnKill = 1,
	PointsOnDeath = 0,
	PointsOnTeamKill = 0,
	PointsOnSuicide = 0,
	SupportedMaps = nil,
	GameType = "slayer"
})

-- Author: Vader
-- Created: August 27th

table.insert(Gamemodes,
{
	Name = "Team KotH",
	Description = "Stand inside of the hill to gain points. The player with the most points win.",
	IsTeam = true,
	FriendlyFire = false,
	Teams = {
		[1] = {
			Name = "Red",
			Weapons = {
				"h3_ar_swep",
				"h3_magnum_swep"
			},
			Color = Colors.Red,
			Model = "models/halo2/spartan_red.mdl",
			Health = 100,
			Shield = 100,
			ShieldRechargeWait = 5,
			ShieldRechargeRate = 10,
			RespawnTime = 5,
			Gravity = 0.6
		},
		[2] = {
			Name = "Blue",
			Weapons = {
				"h3_ar_swep",
				"h3_magnum_swep"
			},
			Color = Colors.Blue,
			Model = "models/halo2/spartan_blue.mdl",
			Health = 100,
			Shield = 100,
			ShieldRechargeWait = 5,
			ShieldRechargeRate = 10,
			RespawnTime = 5,
			Gravity = 0.6
		}
	},
	HealthRegen = false,
	WeaponType = "Normal",
	Radar = false,
	TimeLimit = 15,
	PointsToWin = 100,
	PointsOnKill = 0,
	PointsOnDeath = 0,
	PointsOnTeamKill = 0,
	PointsOnSuicide = 0,
	SupportedMaps = {
		"halo_ascension_fix3",
	},
	GameType = "kingofthehill",

	-- Meta data
	MoveEveryPoint = 10,
	PointsOnTouch = 1,
	TouchWait = 2,

	ListOfPoints = {
		halo_ascension_fix3 = {
			{pos = Vector(-21, 154, 115 - 60), ang = Angle(0, 0, 0)},
			{pos = Vector(-505, -1436, 176 - 60), ang = Angle(0, 0, 0)},
			{pos = Vector(269, -1814, 40 - 60), ang = Angle(0, 0, 0)},
			{pos = Vector(1027, 304, -134 - 60), ang = Angle(0, 0, 0)},
			{pos = Vector(175, 2255, 344 - 60), ang = Angle(0, 0, 0)},
			{pos = Vector(-408, 1214, 132 - 60), ang = Angle(0, 0, 0)},
			{pos = Vector(716, -767, 82 - 60), ang = Angle(0, 0, 0)},
		},
	},

	-- Metadata
	totalPointsEarned = 0,

	ents = {
		halo_ascension_fix3 = {
			{
				entity = "halo_flag",
				pos = Vector(-21, 154, 115),
				team = 1,
				model = "models/hunter/blocks/cube6x6x2.mdl",
				ang = Angle(0, 0, 0),
				name = "Hill",
				noCollideButTrigger = true,
				mat = "models/effects/comball_sphere",
			}
		},
	},
	OnTouch = function(ent, player)
		if !player.lastPoint or CurTime() - CurGT.TouchWait > player.lastPoint then
			ChangeTeamData(player:Team(), "Score", CurGT.PointsOnTouch)
			ChangePlayerData(player, "Score", CurGT.PointsOnTouch)
			CurGT.totalPointsEarned = CurGT.totalPointsEarned + 1

			if CurGT.totalPointsEarned >= CurGT.MoveEveryPoint then
				local points = CurGT.ListOfPoints[game.GetMap()]
				local newPoint = math.random(#points)
				ent:SetPos(points[newPoint].pos)
				ent:SetAngles(points[newPoint].ang)
				CurGT.totalPointsEarned = 0

				SendSound("ghalo/voiceover/hillmoved")
			end
			player.lastPoint = CurTime()
		end

	end
})
table.insert(Gamemodes,
{
	Name = "Team Slayer",
	Description = "The team with the most kills win.",
	IsTeam = true,
	FriendlyFire = true,
	Teams = {
		[1] = {
			Name = "Red",
			Weapons = {
				"h3_ar_swep",
				"h3_magnum_swep"
			},
			Color = Colors.Red,
			Model = "models/halo2/spartan_red.mdl",
			Health = 100,
			Shield = 100,
			ShieldRechargeWait = 5,
			ShieldRechargeRate = 10,
			RespawnTime = 5
		},
		[2] = {
			Name = "Blue",
			Weapons = {
				"h3_ar_swep",
				"h3_magnum_swep"
			},
			Color = Colors.Blue,
			Model = "models/halo2/spartan_blue.mdl",
			Health = 100,
			Shield = 100,
			ShieldRechargeWait = 5,
			ShieldRechargeRate = 10,
			RespawnTime = 5
		},
		[3] = {
			Name = "Green",
			Weapons = {
				"h3_ar_swep",
				"h3_magnum_swep"
			},
			Color = Colors.Green,
			Model = "models/halo2/spartan_olive.mdl",
			Health = 100,
			Shield = 100,
			ShieldRechargeWait = 5,
			ShieldRechargeRate = 10,
			RespawnTime = 5
		},
		[4] = {
			Name = "Orange",
			Weapons = {
				"h3_ar_swep",
				"h3_magnum_swep"
			},
			Color = Colors.Orange,
			Model = "models/halo2/spartan_orange.mdl",
			Health = 100,
			Shield = 100,
			ShieldRechargeWait = 5,
			ShieldRechargeRate = 10,
			RespawnTime = 5
		},
	},
	HealthRegen = false,
	WeaponType = "Normal",
	Radar = false,
	TimeLimit = 15,
	PointsToWin = 30,
	PointsOnKill = 1,
	PointsOnDeath = 0,
	PointsOnTeamKill = -1,
	PointsOnSuicide = 0,
	SupportedMaps = nil,
	GameType = "slayer"
})

-- Author: Vader
-- Created: August 27th

table.insert(Gamemodes,
{
	Name = "Team Snipers",
	Description = "The team with the most kills win.",
	IsTeam = true,
	FriendlyFire = false,
	Teams = {
		[1] = {
			Name = "Red",
			Weapons = {
				"h3_sr_swep",
			},
			Color = Colors.Red,
			Model = "models/halo2/spartan_red.mdl",
			Health = 10,
			Shield = 0,
			ShieldRechargeWait = 5,
			ShieldRechargeRate = 10,
			RespawnTime = 3,
			Gravity = 0.6,
			InfiniteAmmo = true
		},
		[2] = {
			Name = "Blue",
			Weapons = {
				"h3_sr_swep",
			},
			Color = Colors.Blue,
			Model = "models/halo2/spartan_blue.mdl",
			Health = 10,
			Shield = 0,
			ShieldRechargeWait = 5,
			ShieldRechargeRate = 10,
			RespawnTime = 3,
			Gravity = 0.6,
			InfiniteAmmo = true
		}
	},
	HealthRegen = false,
	Radar = false,
	TimeLimit = 15,
	PointsToWin = 100,
	PointsOnKill = 1,
	PointsOnDeath = 0,
	PointsOnTeamKill = 0,
	PointsOnSuicide = 0,
	SupportedMaps = nil,
	GameType = "slayer"
})
