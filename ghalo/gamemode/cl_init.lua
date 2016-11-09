
Gamemodes = {}

include("shared/medals.lua")
include("shared/maps.lua")
include("shared.lua")
include("shared/gametypes.lua")

include("cl/cl_worldtips.lua")
include("cl/cl_util.lua")
include("cl/cl_hud.lua")
include("cl/cl_scoreboard.lua")
include("cl/cl_deathnotice.lua")
include("database/cl_database.lua")

function RecieveChatText( um )
	local r = um:ReadShort()
	local g = um:ReadShort()
	local b = um:ReadShort()
	local color = Color( r, g, b )
	local text = um:ReadString()

	-- print("Got a message: " .. text)
	-- print("color: " .. r .. " " .. g .. " " .. b)

	chat.AddText( color, text )
end

usermessage.Hook( "chatmsg", RecieveChatText )

function RecieveKillStreak( um )
	local b = um:ReadShort()

	DrawKillStreaks(b)
end

usermessage.Hook( "Medal", RecieveKillStreak )

function PlaySound( um )
	local b = um:ReadString()

	surface.PlaySound(b .. ".mp3")
end

usermessage.Hook( "PlaySound", PlaySound )

timer.Simple(4, function()
	local snds=file.Find( "sound/ghalo/effects/*", "GAME" )
	for k,v in pairs(snds) do
	    util.PrecacheSound(v)
	end

	local snds=file.Find( "sound/ghalo/voiceover/*", "GAME" )
	for k,v in pairs(snds) do
	    util.PrecacheSound(v)
	end

	local snds=file.Find( "sound/ghalo/music/*", "GAME" )
	for k,v in pairs(snds) do
	    util.PrecacheSound(v)
	end
end)
