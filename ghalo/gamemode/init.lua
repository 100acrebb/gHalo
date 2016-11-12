
Gamemodes = {}

AddCSLuaFile("shared/medals.lua")
AddCSLuaFile("shared/maps.lua")
AddCSLuaFile("shared.lua")
AddCSLuaFile("shared/gametypes.lua")

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("cl/cl_worldtips.lua")
AddCSLuaFile("cl/cl_util.lua")
AddCSLuaFile("cl/cl_hud.lua")
AddCSLuaFile("cl/cl_scoreboard.lua")
AddCSLuaFile("cl/cl_deathnotice.lua")
AddCSLuaFile("database/cl_database.lua")

include("shared/medals.lua")
include("shared/maps.lua")
include("shared.lua")
include("shared/gametypes.lua")

include("server/spawnpoints.lua")
include("server/player.lua")
include("server/gamemode.lua")
include("server/consolecommands.lua")
include("shared.lua")

include("database/database.lua")

CurrentGamemode = 1

CurGT = Gamemodes[CurrentGamemode]
CurGM = Gamemodes[CurrentGamemode]

function GM:Initialize()
	self.BaseClass.Initialize(self)

	ResetGametype()
	SetUpSpawns()
end

function GM:PlayerConnect(name, ip)
	-- print("Player: " .. name .. " has joined.")
	MessageAllPlayers(name .. " has joined the game!")
end

function GM:PlayerDisconnected(ply)
	MessageAllPlayers(ply:GetName() .. " has left the battle!")
	ply:databaseDisconnect()
end

function GM:PlayerAuthed(ply, steamID, uniqueID)
	-- print("Player: " .. ply:Nick() .. " has authed.")
	ply:databaseCheck()
end

function GM:PlayerInitialSpawn(ply)
	-- print("Player: " .. ply:Nick() .. " has spawned on team: " .. ply:Team())
	MessageAllPlayers(ply:Nick() .. " has joined the battle!")

	ply:databaseCheck()

	if GMData["roundActive"] == Rounds.Active then
		ply:PickTeam()
	else
		ply:SetSpectate()
	end

	CheckPlayerData(ply)
	NetworkTeamData({ply})
end

local function AddHands(ply)
	-- I didn't write this code. Joke did.
	local oldhands = ply:GetHands()
	
	if ( IsValid( oldhands ) ) then oldhands:Remove() end

	local hands = ents.Create( "gmod_hands" )
	if ( IsValid( hands ) ) then
		ply:SetHands( hands )
		hands:SetOwner( ply )

		-- Which hands should we use?
		local cl_playermodel = ply:GetInfo( "cl_playermodel" )
		local info = player_manager.TranslatePlayerHands( cl_playermodel )
		if ( info ) then
			hands:SetModel( info.model )
			hands:SetSkin( info.skin )
			hands:SetBodyGroups( info.body )
		end

		-- Attach them to the viewmodel
		local vm = ply:GetViewModel( 0 )
		hands:AttachToViewmodel( vm )

		vm:DeleteOnRemove( hands )
		ply:DeleteOnRemove( hands )

		hands:Spawn()
	end
end

function GM:PlayerSpawn(ply)
	-- print("Player spawning... on team " .. ply:Team())
	ply:Spawned()
	AddHands(ply)
end

function SendSound(string, ply)
	umsg.Start("PlaySound", ply)
		umsg.String(string)
	umsg.End()
end

function GM:ShowSpare1( ply )
	umsg.Start( "ShowStatsList", ply )
    umsg.End()
end
