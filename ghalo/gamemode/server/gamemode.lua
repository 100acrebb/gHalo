
GMData = {
	--[[
	timeRemaining = secondsLeft,
	roundActive = false
	]]--
}

TeamData = {
	--[[ 
	[0 | TeamID] = {
		Score = 0		-- How much score the team hasW
	}
	]]--
}

PlayerData = {
	--[[
	[0 | PlayerID] = {
		Score = 0
	}
	]]--
}

choices = nil
whoseVoted = {}

function SpectateAll()
	for k, v in pairs(player.GetAll()) do
		v:SetSpectate(v)
		v.NextSpawnTime = CurTime() + ServerOptions.InactiveRoundTime
	end
end

function MessageAllPlayers(message, color)
	for k, v in pairs(player.GetAll()) do
		if color then
			umsg.Start( "chatmsg", v )
				umsg.Short( color.r )
				umsg.Short( color.g )
				umsg.Short( color.b )
				print("Sending: " .. message)
				umsg.String( message )
			umsg.End()
		else
			v:ChatPrint(message)
		end
	end
end

lastGametype = CurrentGametype
MapID = nil

local function CheckDir(dir, filename)
	if !file.Exists(filename, "DATA") then
		file.CreateDir(dir)
	end
end

local function SaveToFile(filename, string)
	file.Write(filename, string)
end

local function ReadFromFile(filename)
	return file.Read(filename, "DATA")
end

local function DoesFileExist(filename)
	return file.Exists(filename, "DATA")
end

local function ChangeMap(mapname)
	RunConsoleCommand("changelevel", mapname)
end

local function GetMapVoteWinner()
	local winner = nil
	local winnerCount = 0

	for k, v in pairs(choices) do
		if !winner or v.Votes > winnerCount then
			print("Found a new winner: " .. k)
			winner = k
			winnerCount = v.Votes
		end
	end

	return winner
end

local function ResetMapVotes()
	choices = nil
end

local function SetupNewGametypeID(gametypeID)
	local folderpath = "gHalo/server/"
	local gametypeFile = folderpath .. "gamemode.txt"

	CurrentGametype = nil

	-- If we have been given a pre-defined gametypeID, use that.
	if gametypeID then
		CurrentGametype = gametypeID

	-- Check to see if we just finished voting.
	elseif choices then
		-- Get winning map of vote
		local winner = GetMapVoteWinner()

		if winner then
			local gtID = choices[winner].Gm
			-- mapRawName IE: halo_ascension_fix3
			local mapRawName = choices[winner].Map.Map

			CurrentGametype = gtID
			
			-- If we are not on the right map, change.
			if game.GetMap() ~= mapRawName then
				print("Going to different map! Saving our new gamemode " .. CurrentGametype)
				-- Make sure our the directory where our gamemode file is exists
				CheckDir(folderpath, gametypeFile)
				-- Save our gamemode ID to a file
				---- We will lose our state on map change so we have to save
				---- our new gametypeID.
				SaveToFile(gametypeFile, tostring(CurrentGametype))
				-- Change the map
				ChangeMap(choices[winner].Map.Map)
			end

			-- Reset our mapvotes.
			ResetMapVotes()
		end

	-- Load in our gametype from file.
	else
		-- Check to see if we saved our gametype state
		if DoesFileExist(gametypeFile) then
			CurrentGametype = tonumber(ReadFromFile(gametypeFile))
		end
	end

	-- If something went wrong, just set the gametype to 1.
	if !CurrentGametype then
		CurrentGametype = ServerOptions.DefaultGT
	end

	-- Get the gametype data
	CurGT = Gamemodes[CurrentGametype]
	CurGM = Gamemodes[CurrentGametype]
end

local function GetMapID()
	for k, v in pairs(MapData) do
		if v.Map == game.GetMap() then
			MapID = k
			break
		end
	end
end

local function SetupSpawns()
	-- Default spawntype
	local spawnType = "ffa"
	local spawnList = Spawns[game.GetMap()]

	-- If the gametype exists and wants us to
	-- use a specific spawnType, such as "teams"
	if CurGT and CurGT.SpawnType then
		spawnType = CurGT.SpawnType
	end

	-- If our list of Spawns has this map then
	-- use those spawns.
	if spawnList then
		if spawnList[spawnType] then
			spawns = spawnList[spawnType]
		else
			-- The map did not have the spawn types
			-- we were looking for.

			-- Our Spawns may not even have ffa
			-- filled out. If they don't, just use
			-- map spawns.
			if spawnList["ffa"] then
				spawns = spawnList["ffa"]
			end
		end
	end
end

local function ResetGMData()
	local time = CurGT.TimeLimit * ServerOptions.Seconds + ServerOptions.InactiveRoundTime
	GMData = {
		timeRemaining = math.floor(CurTime() + time),
		time = time,
		roundActive = Rounds.Active,
		inactiveTimer = CurTime() + ServerOptions.InactiveRoundTime
	}

	-- Check to see if we have a timeremaining time.
	if timer.Exists("timeRemainingTimer") then
		timer.Adjust("timeRemainingTimer", time, 1, function()
			Win(-1)
		end)
	else
		timer.Create("timeRemainingTimer", time, 1, function()
			Win(-1)
		end)
	end
end

local function SetupTeams()
	-- Init teams settings
	for teamID, teamTable in pairs(Gamemodes[CurrentGametype]["Teams"]) do
		team.SetUp(teamID, teamTable.Name, teamTable.Color)

		-- If it's a teambased game.
		if CurGT.IsTeam then
			-- Set the initial 
			TeamData[teamID] = {
				Score = 0
			}
		end
	end
end

local function ResetPlayerData()
	-- Init player settings
	for playerID, ply in pairs(player.GetAll()) do
		ResetPlayerData(ply)
	end
end

local function PreparePlayersForRound()
	-- Make everyone spectate
	if !CurGT.MixTeams then
		for k, v in pairs(player.GetAll()) do
			v:KillSilent()
			v.NextSpawnTime = CurTime() + ServerOptions.InactiveRoundTime
		end
	else
		SpectateAll()
	end
end

function ResetGametype(gametypeID, dontReset)
	local folderpath = "gHalo/server/"
	local gamemodeFile = folderpath .. "gamemode.txt"
	lastGametype = CurrentGametype

	SetupNewGametypeID(gametypeID)
	if !MapID then GetMapID() end

	SetupSpawns()

	-- Init GM settings
	ResetGMData()

	-- If it is just a new round and not
	-- an entirely new gametype, don't reset
	-- scores.
	if !dontReset then
		-- Make our round inactive
		GMData.roundActive = Rounds.InActive
		GMData.inactiveTimer = ServerOptions.InactiveRoundTime + CurTime()
		SetupTeams()
		ResetPlayerData()
	end

	NetworkTeamData(player.GetAll())
	PreparePlayersForRound()

	timer.Simple(ServerOptions.InactiveRoundTime, StartRound)
end

local function CleanupEnts()
	if lastGametype then
		local lastCurGT = Gamemodes[lastGametype]
		if lastCurGT.ents and lastCurGT.ents[game.GetMap()] then
			for k, v in pairs(lastCurGT.ents[game.GetMap()]) do
				if v.ent then
					if IsValid(v.ent) then
						v.ent:Remove()
					end
					v.ent = nil
				end
			end
		end
	end
end

local function SpawnGametypeEnts()
	if CurGT.ents and CurGT.ents[game.GetMap()] then
		for k, v in pairs(CurGT.ents[game.GetMap()]) do
			local entClass = "prop_physics"
			local entTable = nil

			if v.entity then
				local SpawnableEntities = list.Get( "SpawnableEntities" )
				entTable = SpawnableEntities[v.entity]
				entClass = entTable.ClassName
			end

			local ent = ents.Create(entClass)

			if entTable then
				if (entTable.KeyValues) then
					for k, v in pairs(entTable.KeyValues) do
						ent:SetKeyValue(k, v)
					end
				end

				ent:AltModel(v.model, v.noCollideButTrigger, v.noCollide)
			else
				ent:SetModel(v.model)
			end

			if v.mat then
				ent:SetMaterial(v.mat)
			end

			if ent and IsValid(ent) then
				ent:SetPos(v.pos)
				ent:SetAngles(v.ang)
				ent:Spawn()
				ent:Activate()

				ent.team = v.team
				ent.spawn = v.pos
				ent.uid = v.uid

				if entClass == "halo_flag" then
					ent:SetTeamName(v.name)
				end

				local phy = ent:GetPhysicsObject()

				if phy and IsValid(phy) then
					phy:EnableMotion(false)
				end

				if v.ent then
					if IsValid(v.ent) then
						v.ent:Remove()
					end
					v.ent = nil
				end

				v.ent = ent
			end
		end
	end
end

CurWeps = {}

local function RemoveSpawnedWeapons()
	for k, v in pairs(CurWeps) do
		if !v or !IsValid(v) then
			CurWeps[k] = nil
		end
	end
end

local function SpawnWeapons()
	RemoveSpawnedWeapons()

	if MapID and CurGT.WeaponType and MapData[MapID].Weapons and MapData[MapID].Weapons[CurGT.WeaponType] then
		local weps = MapData[MapID].Weapons[CurGT.WeaponType]

		for k, v in pairs(weps) do
			if !CurWeps[k] then
				local entClass = v.name

				local ent = ents.Create(entClass)

				if v.mat then
					ent:SetMaterial(v.mat)
				end

				if ent and IsValid(ent) then
					ent:SetPos(Vector(v.pos.x, v.pos.y, v.pos.z - 55))
					ent:SetAngles(v.ang)
					ent:Spawn()
					ent:Activate()

					local phy = ent:GetPhysicsObject()

					if phy and IsValid(phy) then
						phy:EnableMotion(false)
					end
				end

				CurWeps[k] = ent
			end
		end
	end
end

local function PickNewTeams()
	for plyID, ply in pairs(player.GetAll()) do
		-- Update all players on GMData
		ply:SetNWInt("roundActive", GMData["roundActive"])

		if CurGT.MixTeams or ply:Team() < 1 or ply:Team() > 999 then
			print("Pcking those teams")
			ply:PickTeam()
		elseif ply.NextTeam then
			print("Pcking next team")
			ply:PickTeam(ply.NextTeam)
		end

		ply.NextTeam = nil
	end
end

local function SpawnBots(amount)
	if !amount then
		amount = ServerOptions.MaxBots
	end

	-- Spawn bots
	for i=1,amount-#player.GetAll(),1 do
		RunConsoleCommand("bot")
	end
end

function StartRound()
	GMData["roundActive"] = Rounds.Active

	-- If we didn't change maps, remove all entities from
	-- last gametype.
	CleanupEnts()
	SpawnGametypeEnts()
	SpawnWeapons()
	PickNewTeams()
	SpawnBots(amount)

	if timer.Exists("WeaponSpawning") then
		timer.Destroy("WeaponSpawning")
	end

	if CurGT.WeaponRespawnRate then 
		timer.Create("WeaponSpawning", CurGT.WeaponRespawnRate, 0, SpawnWeapons)
	end

end

function GetSteamID(ply)
	if ply and IsValid(ply) then 
		if ply:IsBot() then
			return ply:GetName()
		else
			return ply:SteamID()
		end
	else 
		print("ply was not valid!")
	end
end

function NetworkTeamData(players)
	for plyID, ply in pairs(players) do
		-- Send our new countdown timer
		ply:SetNWInt("timeCountdown", math.floor(GMData.inactiveTimer))

		if GMData.roundActive == Rounds.Voting then
			ply:SetNWInt("timeRemainingTimer", GMData.VotingCountdown)
		end

		-- Update all players on GMData
		for GMDataKey, GMDataValue in pairs(GMData) do
			ply:SetNWInt(GMDataKey, GMDataValue)
		end

		-- Update all players on teamdata
		for teamID, teamDataTable in pairs(TeamData) do
			for key, teamDataValue in pairs(teamDataTable) do
				ply:SetNWInt("team" .. teamID .. key, teamDataValue)
			end
		end

		local id = GetSteamID(ply)

		if PlayerData[id] then
			for plyDataKey, plyDataValue in pairs(PlayerData[id]) do
				ply:SetNWInt(plyDataKey, plyDataValue)
			end
		end

		ply:SetNWInt("CurrentGametype", CurrentGametype)
		ply:SetNWInt("CurrentGamemode", CurrentGametype)
	end
end

function CheckForWin(teamIDorPly)
	local score = nil

	if CurGT.IsTeam then
		score = GetTeamData(teamIDorPly, "Score")
	else
		score = GetPlayerData(teamIDorPly, "Score")
	end

	if score >= CurGT.PointsToWin then
		Win(teamIDorPly)
	end
end

local function GetTopTeam()
	local top = nil
	local topID = nil
	local tie = false

	for teamIDx, teamDataTable in pairs(CurGT.Teams) do
		local teamScore = GetTeamData(teamIDx, "Score")

		if !top or teamScore > top then
			top = teamScore
			topID = teamIDx
			tie = false
		elseif teamScore == top then
			tie = true
			top = teamScore
			topID = teamIDx
		end
	end

	return top, topID, tie
end

local function GetTopPlayer()
	local top = nil
	local topPly = nil
	local tie = false

	for plyID, ply in pairs(player.GetAll()) do
		if IsValid(ply) then
			local plyScore = GetPlayerData(ply, "Score")

			if !top or plyScore > top then
				top = plyScore
				topPly = ply
				tie = false
			elseif plyScore == top then
				tie = true
				top = plyScore
				topPly = ply
			end
		end
	end

	return top, topPly, tie
end

local function TeamWin(teamID)
	local teamWon = true
	local top, topID, tie = nil

	-- The timelimit was reached
	if teamID <= -1 then
		if CurGT.NoWinOnTimeout then
			teamWon = false
		end

		if CurGT.TeamWinsOnTimeout then
			tie = false
			topID = CurGT.TeamWinsOnTimeout
			top = GetTeamData(CurGT.TeamWinsOnTimeout, "Score")
		else
			top, topID, tie = GetTopTeam()
		end

		if !top or tie then
			MessageAllPlayers(
				"The game is a tie! Starting again in 10 seconds!",
				Color(255, 200, 0)
			)
		else
			for k, v in pairs(team.GetPlayers(topID)) do
				v:databaseChangeValue("xp", 100)
			end

			MessageAllPlayers(
				CurGT.Teams[topID].Name .. " team has won! Starting again in 10 seconds!",
				Color(255, 200, 0)
			)
		end
	else
		topID = teamID
		top = GetTeamData(teamID, "Score")

		for k, v in pairs(team.GetPlayers(topID)) do
			v:databaseChangeValue("xp", 100)
		end

		MessageAllPlayers(
			CurGT.Teams[teamID].Name .. " team has won! Starting again in 10 seconds!",
			Color(255, 200, 0)
		)
	end

	return teamWon, top, topID, tie
end

local function PlayerWin(ply)
	local top, topPly, tie = nil

	-- Check to see if ply == -1, if it is, that means
	-- we timed out.
	if tonumber(winningPly) then
		top, topPly, tie = GetTopPlayer()

		if !top or tie then
			print("The game is a tie!")
			MessageAllPlayers(
				"The game is a tie! Starting again in 10 seconds!",
				Color(255, 200, 0)
			)
		else
			print("Player " .. topPly:GetName() .. " has won!!")
			topPly:databaseChangeValue("xp", 100)

			MessageAllPlayers(
				topPly:GetName() .. " has won!! Starting again in 10 seconds!",
				Color(255, 200, 0)
			)
		end
	else
		if winningPly and IsValid(winningPly) then
			print("Player " .. winningPly:GetName() .. " has won!!")
			winningPly:databaseChangeValue("xp", 100)

			MessageAllPlayers(
				winningPly:GetName() .. " has won!! Starting again in 10 seconds!",
				Color(255, 200, 0)
			)
		end
	end

	return top, topPly, tie
end

local function WinGTHook(top, topID, teamWon)
	if teamWon then
		-- If the team won and it wasn't a tie, give them a point.
		ChangeTeamData(topID, "Score", CurGT.PointsOnWin, true)
	end

	-- Check to see if the hook says the shold win. If not,
	-- start a new round, if so, start a new game.
	if !CurGT.ShouldWin(topID, top + CurGT.PointsOnWin, teamWon) then
		ResetGametype(CurrentGametype, true)
	else
		timer.Simple(ServerOptions.VotingLength + ServerOptions.RoundResetLength, ResetGametype)
		EndGametype()
	end
end

function Win(teamIDorPly)
	-- Only check for wins if the round is active.
	if !GMData or GMData["roundActive"] ~= Rounds.Active then return false end

	local sTeams = CurGT.Teams

	local top = nil
	local topID = nil
	local topPly = nil
	local tie = false
	local teamWon = true

	if CurGT.IsTeam then
		local teamID = teamIDorPly
		teamWon, top, topID, tie = TeamWin(teamID)
	else
		local winningPly = teamIDorPly
		top, topPly, tie = PlayerWin(winningPly)
	end

	-- Check to see if the gametype has a hook to check
	-- if round has actually ended.
	if CurGT.ShouldWin then
		WinGTHook(top, topID, teamWon)
	else
		timer.Simple(ServerOptions.VotingLength + ServerOptions.RoundResetLength, ResetGametype)
		EndGametype()
	end
end

function EndGametype()
	GMData["roundActive"] = Rounds.Ending

	if timer.Exists("timeRemainingTimer") then
		timer.Destroy("timeRemainingTimer")
	end

	-- Set everyone's timeCountdown
	for playerID, ply in pairs(player.GetAll()) do
		ply:SetNWInt("roundActive", GMData["roundActive"])
	end

	timer.Simple(ServerOptions.RoundResetLength, MapVoting)
end

local function NetworkVotingData()
	for playerID, ply in pairs(player.GetAll()) do
		ply:SetNWInt("timeCountdown", GMData.VotingCountdown)
		ply:SetNWInt("roundActive", GMData["roundActive"])
	end

	for choice, choiceInfo in pairs(choices) do
		for playerID, ply in pairs(player.GetAll()) do
			ply:SetNWInt("choice" .. choice, choiceInfo.Gm)
			ply:SetNWInt("choice" .. choice .. "Votes", 0)
			ply:SetNWInt("choice" .. choice .. "ID", choiceInfo.MapID)
		end
	end
end

local function GetMapID(mapname)
	for id, x in pairs(MapData) do
		if x.Map == mapname then
			return id
		end
	end

	-- Mapname not found. Return 1.
	return 1
end

local function GenerateVoting()
	for i=1,Voting.Options,1 do
		local gm = math.random(#Gamemodes)
		local map = nil
		local mapID = nil
		local gms = Gamemodes[gm]

		if gms.SupportedMaps then
			local tmpMapName = gms.SupportedMaps[math.random(#gms.SupportedMaps)]
			mapID = GetMapID(tmpMapName)
		else
			mapID = math.random(#Voting.Maps)
		end

		map = Voting.Maps[mapID]

		choices[i] = {
			Gm = gm,
			Map = map,
			MapID = mapID,
			Votes = 0
		}
	end
end

function MapVoting()
	 GMData["roundActive"] = Rounds.Voting

	-- There may be time left on the clock. Stop it.
	if timer.Exists("timeRemainingTimer") then
		timer.Destroy("timeRemainingTimer")
	end

	GMData.VotingCountdown = math.floor(CurTime() + ServerOptions.VotingLength)

	choices = {}
	whoseVoted = {}

	GenerateVoting()

	NetworkVotingData()
end

-- Player Functions

function SetPlayerData(ply, key, value)
	CheckPlayerData(ply)

	local id = GetSteamID(ply)

	PlayerData[id][key] = value

	ply:SetNWInt(key, value)

	if !CurGT.IsTeam then
		CheckForWin(ply)
	end
end

function GetPlayerData(ply, key)
	CheckPlayerData(ply)

	local id = GetSteamID(ply)

	if PlayerData[id][key] then
		return PlayerData[id][key]
	else
		print("No key found: " .. key)
		return 0
	end
end

function ChangePlayerData(ply, key, value)
	CheckPlayerData(ply)

	SetPlayerData(ply, key, GetPlayerData(ply, key) + value)
end

function CheckPlayerData(ply)
	if IsValid(ply) then
		local id = GetSteamID(ply)

		if !PlayerData[id] then
			ResetPlayerData(ply)
		end
	end
end

function ResetPlayerData(ply)
	if IsValid(ply) and CurGT.Teams[ply:Team()] then
		local id = GetSteamID(ply)

		PlayerData[id] = {
			Score = 0,
			Shield = CurGT.Teams[ply:Team()].Shield,
		}
		ply.hasEnt = nil
	end
end

-- Team function

function SetTeamData(teamID, key, value, check)
	TeamData[teamID][key] = value

	for k, v in pairs(player.GetAll()) do
		v:SetNWInt("team" .. teamID .. key, value)
	end

	if !check then
		CheckForWin(teamID)
	end
end

function GetTeamData(teamID, key)
	if !teamID then
		print("Nil TeamID (GetTeamData())")
		return 0
	end

	if !TeamData[teamID] then 
		print("TeamID no good. " .. teamID)
		return 0
	end

	if TeamData[teamID][key] then
		return TeamData[teamID][key]
	else
		print("Key: " .. key .. "Not found, GetTeamData()")
	end
end

function ChangeTeamData(teamID, key, value, check)
	SetTeamData(teamID, key, GetTeamData(teamID, key) + value, check)
end

function DeathNotifications(victim, attacker)
	umsg.Start("PlayerKilled")
		umsg.Entity(victim)
		umsg.Entity(attacker)
	umsg.End()
end

function SendMTS(id, ply)
	if id > 0 then
		ply:databaseChangeValue("xp", 5)

		umsg.Start("Medal", ply)
			umsg.Short(id)
		umsg.End()
	end
end

function GM:PlayerDeath(victim, inflictor, attacker)
	-- Make sure victim and attacker are real
	if IsValid(victim) and IsValid(attacker) and victim:IsPlayer() and attacker:IsPlayer() then
		victim:databaseChangeValue("deaths", 1)
		attacker:databaseChangeValue("kills", 1)
		attacker:databaseChangeValue("xp", 10)

		if !attacker:Alive() then
			local mts = 36
			SendMTS(mts)
		end

		local wep = attacker:GetActiveWeapon()

		if wep then
			local wepName = wep:GetClass()

			if wepName == "h3_sr_swep" or wepName == "halo_spartan_weapon_sniper" then
				if attacker.sniperKills then
					attacker.sniperKills = attacker.sniperKills + 1
				else
					attacker.sniperKills = 1
				end

				local sk = attacker.sniperKills
				local mts = 0

				if sk == 5 then
					mts = 33
				elseif sk == 10 then
					mts = 34
				end

				-- send
				SendMTS(mts, attacker)

				mts = 0
				print(victim.lastHitGroup)
				if victim.lastHitGroup and victim.lastHitGroup == HITGROUP_HEAD then
					mts = 32
					SendMTS(mts, attacker)
				end
			end

			local ammo = wep:GetPrimaryAmmoType()
			attacker:GiveAmmo(wep:GetMaxClip1(), ammo)
		end

		if !victim.spree then
			victim.spree = 0
		elseif victim.spree >= 5 then
			local mts = 18
			SendMTS(mts, attacker)
		end

		if !attacker.spree then
			attacker.spree = 0
		end

		if !attacker.killingSpree then
			attacker.killingSpree = 0
		end

		attacker.spree = attacker.spree + 1
		attacker.killingSpree = attacker.killingSpree + 1

		local ks = attacker.spree
		local mts = 0

		if ks == 5 then
			mts = 24
		elseif ks == 10 then
			mts = 25
		elseif ks == 15 then
			mts = 26
		elseif ks == 20 then
			mts = 27
		elseif ks == 25 then
			mts = 28
		elseif ks == 30 then
		 	mts = 29
		end

		SendMTS(mts, attacker)

		if attacker.lastKill then
			if CurTime() - 4 <= attacker.lastKill then
				print("You're on a killing streak of " .. attacker.killingSpree)
				local mts = 0
				local sc = attacker.killingSpree

				if sc == 2 then
					mts = 1
				elseif sc == 3 then
					mts = 2
				elseif sc == 4 then
					mts = 3
				elseif sc == 5 then
					mts = 4
				elseif sc == 6 then
					mts = 5
				elseif sc == 7 then
					mts = 6
				elseif sc == 8 then
					mts = 7
				elseif sc == 9 then
					mts = 8
				elseif sc >= 10 then
					mts = 9
				end

				SendMTS(mts, attacker)
			else
				attacker.killingSpree = 1
			end
		end

		attacker.lastKill = CurTime()

		-- They are the same person
		if victim == attacker then
			-- Suicide
			ChangePlayerData(victim, "Score", CurGT.PointsOnSuicide)

			if CurGT.IsTeam then
				ChangeTeamData(victim:Team(), "Score", CurGT.PointsOnSuicide)
			end
		
		-- They are not the same person
		else
			-- They are on the same team
			if CurGT.IsTeam and CurGT.FriendlyFire and victim:Team() == attacker:Team() then
				ChangePlayerData(attacker, "Score", CurGT.PointsOnTeamKill)
				ChangeTeamData(attacker:Team(), "Score", CurGT.PointsOnTeamKill)
			else
				ChangePlayerData(victim, "Score", CurGT.PointsOnDeath)
				ChangePlayerData(attacker, "Score", CurGT.PointsOnKill)

				if CurGT.IsTeam then
					ChangeTeamData(victim:Team(), "Score", CurGT.PointsOnDeath)
					ChangeTeamData(attacker:Team(), "Score", CurGT.PointsOnKill)
				end
			end
		end

		if IsValid(victim) and CurGT.Teams[victim:Team()] then
			victim.NextSpawnTime = CurTime() + CurGT.Teams[victim:Team()].RespawnTime
			victim:SetNWInt("timeCountdown", math.floor(victim.NextSpawnTime))
			SetPlayerData(victim, "Shield", CurGT.Teams[victim:Team()].Shield)

			local steamID = victim:SteamID()
			if steamID == "BOT" then steamID = victim:GetName() end

			-- If the player is healing, stop them from healing.
			if timer.Exists(steamID .. "Shieldx") then -- nil
				timer.Destroy(steamID .. "Shieldx")
			end

			DeathNotifications(victim, attacker)
		end

		if CurGT.OnDeath then
			CurGT.OnDeath(victim, attacker)
		end
	end

	if victim and IsValid(victim) and victim:IsPlayer() then
		victim.spree = 0
		victim.sniperKills = 0
		victim.killingSpree = 0

		print("playing sound!") -- Doesn't work
		victim:EmitSound("ghalo/effects/malespartandeathscream1.mp3")
	end
end

function GiveShieldsBack(ply)
	if IsValid(ply) then
		ChangePlayerData(ply, "Shield", CurGT.Teams[ply:Team()].ShieldRechargeRate)

		if GetPlayerData(ply, "Shield") >= CurGT.Teams[ply:Team()].Shield then
			SetPlayerData(ply, "Shield", CurGT.Teams[ply:Team()].Shield)
		else
			local steamID = ply:SteamID()
			if steamID == "BOT" then steamID = ply:GetName() end

			timer.Create(steamID .. "Shieldx", 0.25, 1, function()
				GiveShieldsBack(ply)
			end)
		end
	end
end

function GM:EntityTakeDamage(target, dmginfo)
	local caller = dmginfo:GetInflictor()
	local attacker = dmginfo:GetAttacker()
	local amount = dmginfo:GetDamage()

	if IsValid(target) and target:IsPlayer() then
		local steamID = GetSteamID(target)

		if target:IsPlayer() then
			local tempShield = GetPlayerData(target, "Shield")
			if tempShield > 0 then
				local tempShield = tempShield - amount

				if tempShield >= -10 then
					dmginfo:ScaleDamage(0)
				end

				if tempShield <= 0 then
					tempShield = 0
				end

				SetPlayerData(target, "Shield", tempShield)

				if IsValid(target) and CurGT.Teams[target:Team()] then
					if timer.Exists(steamID .. "Shield") then
						timer.Adjust(steamID .. "Shield", CurGT.Teams[target:Team()].ShieldRechargeWait, 1, function()
							if IsValid(target) then
								GiveShieldsBack(target)
							end
						end)
					else
						timer.Create(steamID .. "Shield", CurGT.Teams[target:Team()].ShieldRechargeWait, 1, function()
							if IsValid(target) then
								GiveShieldsBack(target)
							end
						end)
					end
				end
			end

			-- If the player is healing, stop them from healing.
			if timer.Exists(steamID .. "Shieldx") then
				timer.Destroy(steamID .. "Shieldx")
			end
		end
	end
end

function GM:PlayerShouldTakeDamage( victim, ply )
	if ply:IsPlayer() then	
		if CurGT.IsTeam and ply:Team() == victim:Team() and !CurGT.FriendlyFire then
			return false
		end
	end

	return true 
end

function GM:ScalePlayerDamage( ply, hitgroup, dmginfo )
	-- if ( hitgroup == HITGROUP_HEAD ) then
	-- end

	ply.lastHitGroup = hitgroup

	-- if ( hitgroup == HITGROUP_LEFTARM or
	-- 	hitgroup == HITGROUP_RIGHTARM or
	-- 	hitgroup == HITGROUP_LEFTLEG or
	-- 	hitgroup == HITGROUP_RIGHTLEG or
	-- 	hitgroup == HITGROUP_GEAR ) then

	-- 	dmginfo:ScaleDamage( 0.50 )

	-- end
end
