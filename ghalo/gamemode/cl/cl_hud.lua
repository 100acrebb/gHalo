
print("Rewritting HUD")

-- Fonts
local CustomFontA = surface.CreateFont("CustomFontA", {
	font = "Arial",
	size = 21
})

local CustomFontB = surface.CreateFont("CustomFontB", {
	font = "Arial",
	size = 36
})

local CustomFontD = surface.CreateFont("CustomFontD", {
	font = "Arial",
	size = 20
})

local CustomFontE = surface.CreateFont("CustomFontE", {
	font = "Arial",
	size = 40
})

local CustomFontF = surface.CreateFont("CustomFontF", {
	font = "Arial",
	size = 24
})

-- Animation variables
local shieldRegenAnimationRateUp = 0.25
local shieldRegenAnimationRateDown = 4
local lastShield = 0

-- UI variables
local padding = {
	x = 3,
	y = 3,
	border  = 3
}

local info = {}

info.health = {}
info.weapons = {}
info.grenades = {}
info.radar = {}
info.score = {}
info.gmName = {}
info.time = {}
info.message = {}
info.voting = {}

-- Health
info.health.width = 350
info.health.height = 40
info.health.x = ScrW() / 2 - (info.health.width / 2)
info.health.y = 50
info.health.color = Color(33, 33, 33 , 150)

-- Score
info.score.width = 200
info.score.height = 30
info.score.x = ScrW() - info.score.width - 25
info.score.y = ScrH() - info.score.height * 2 - 50
info.score.color = Color(200, 220, 240, 255)

info.gmName.width = 0
info.gmName.height = 0
info.gmName.x = ScrW() - info.gmName.width - 25
info.gmName.y = ScrH() - info.score.height * 2 - 80
info.gmName.color = Color(200, 220, 240, 255)

info.time.width = 0
info.time.height = 0
info.time.x = ScrW() - info.time.width - 25
info.time.y = info.gmName.y - 25
info.time.color = Color(200, 220, 240, 255)

info.weapons.width = 0
info.weapons.height = 0
info.weapons.x = ScrW() - 25
info.weapons.y = 50
info.weapons.color = Color(200, 220, 240, 255)

info.message.width = 0
info.message.height = 0
info.message.x = ScrW() / 2
info.message.y = ScrH() - 100
info.message.color = Color(200, 220, 240, 255)

info.voting.width = 690
info.voting.height = 270
info.voting.x = 50
info.voting.y = ScrH() - 50 - info.voting.height + 20
info.voting.color = Color(99, 99, 99, 150)

MedalRows = {}
LastTalked = CurTime()

local function inQuad( fraction, beginning, change )
	return change * ( fraction ^ 2 ) + beginning
end

EarnedMedals = {}

function DrawKillStreaks(id)
	local medal = Medals[id]


	if EarnedMedals[id] then
		EarnedMedals[id] = EarnedMedals[id] + 1
	else
		EarnedMedals[id] = 1
	end

	print("Drawing ID: " .. medal.Name)

	if medal.sound and string.len(medal.sound) > 0 then
		if CurTime() - 1 > LastTalked then
			print("Playing sound")
			surface.PlaySound("ghalo/voiceover/" .. medal.sound .. ".mp3")
			LastTalked = CurTime()
		else
			print("Nah")
		end
	end

	local slot = 0

	for i=1,6,1 do
		if slot == 0 then
			if !MedalRows[i] then
				slot = i
			end
		end
	end

	if slot == 0 then
		slot = math.random(1, 4)
		MedalRows[slot]:Remove()
	end

	local x = 50 + (slot - 1) * 50
	local y = ScrH() - 90
	local width = 40
	local height = 40

	local slotImageDerma = vgui.Create("DFrame")
	slotImageDerma:SetSize(width, height)
	slotImageDerma:SetPos(0, ScrH())
	slotImageDerma:SetDraggable(false)
	slotImageDerma:ShowCloseButton(false)
	slotImageDerma:SetTitle("")
	slotImageDerma.Paint = function()
	end

	local slotImage = vgui.Create("DImage", slotImageDerma)
	slotImage:SetPos(0, 0)
	slotImage:SetSize(slotImageDerma:GetWide(), slotImageDerma:GetTall())
	slotImage:SetImage("materials/vgui/medals/" .. medal.image .. ".png", "vgui/avatar_default")

	local anim = Derma_Anim( "easeInOutBack", slotImageDerma, function( pnl, anim, delta, data )
		pnl:SetPos( x, inQuad( delta, ScrH(),  y - ScrH()) ) -- Change the X coordinate from 200 to 200+600
	end )

	anim:Start( 0.5 ) -- Animate for two seconds
	slotImageDerma.Think = function( self )
		if anim:Active() then
			anim:Run()
		end
	end

	slotImage:SizeTo(width - 15, height - 15, 0.10, 0.5)
	slotImageDerma:MoveTo(x + 7, y + 7, 0.10, 0.5)
	slotImage:SizeTo(width, height, 0.10, 0.60)
	slotImageDerma:MoveTo(x, y, 0.10, 0.60)

	slotImageDerma:AlphaTo(0, 0.5, 2)
	slotImageDerma:MoveTo(x, ScrH(), 1, 2, -1, function()
		MedalRows[slot] = nil
		slotImageDerma:Remove()
		slotImageDerma = nil
	end)

	MedalRows[slot] = slotImageDerma
end

function DrawHealth()
	local ply = LocalPlayer()
	local gamemodeSettings = Gamemodes[ply:GetNWInt("CurrentGamemode")]
	
	local health = ply:Health()
	local shield = ply:GetNWInt("Shield")


	local healthColor = Color(75, 0, 0, 200)
	local shieldColor = Color(200, 220, 240, 50)

	if gamemodeSettings.IsTeam and gamemodeSettings.Teams[ply:Team()] then
		draw.RoundedBox(
			1,
			info.health.x,
			info.health.y + 53,
			info.health.width,
			20,
			gamemodeSettings.Teams[ply:Team()].Color
		)
		draw.SimpleText(
			gamemodeSettings.Teams[ply:Team()].Name,
			"CustomFontD",
			ScrW() / 2,
			info.health.y + 54,
			Color(200, 220, 240, 180),
			TEXT_ALIGN_CENTER
		)
	end

	if ply:Alive() then
		-- Draw health bars
		if health < 100 then
			health = health - 1
		end

		-- Draw the background
		draw.RoundedBox(
			1,
			info.health.x,
			info.health.y + 40,
			info.health.width,
			info.health.height / 3,
			Color(shieldColor.r,shieldColor.g,shieldColor.b, 10)
		)

		-- Draw the health bars. We want to draw
		-- a small bar for every 10 health you have.
		-- 1 HP = 1 bar, 10 HP = 1 bar, 99 HP = 9 bars
		-- 100 HP = 10 bars.
		for i=0,health,10 do
			draw.RoundedBox(
				1,
				info.health.x + (padding.border) + ((info.health.width / 111) * i),
				info.health.y + 40 + (padding.border),
				(info.health.width / 10) - (padding.border * 2),
				(info.health.height / 3) - (padding.border * 2),
				healthColor
			)
		end

		-- We want to make the shields look cool
		-- so to do this, only move the bar so much
		-- every frame.
		if shield > lastShield then
			local temp = shield
			shield = lastShield + shieldRegenAnimationRateUp
			if shield >= temp then
				shield = temp
			end
		else
			local temp = shield
			shield = lastShield - shieldRegenAnimationRateDown
			if shield <= temp then
				shield = temp
			end
		end

		lastShield = shield

		-- Draw shield bars
		if shield >= 500 then
			-- Red
			shieldColor = Color(220, 0, 0, 150)
		elseif shield <= 500 and shield > 400 then
			-- Green
			shieldColor = Color(0, 220, 0, 150)
		elseif shield <= 400 and shield > 300 then
			-- Gray
			shieldColor = Color(33, 33, 33, 150)
		elseif shield <= 300 and shield > 200 then
			-- Pink
			shieldColor = Color(220, 0, 220, 150)
		elseif shield <= 200 and shield > 100 then
			-- Red+Green
			shieldColor = Color(220, 220, 0, 150)
		end

		-- If the shield is over 100, we want to 
		-- make it between 0 and 100 because our
		-- bar is between 0 and 100%. (We are using
		-- the modulus operator. 302 becomes 2. 554
		-- becomes 54. 1058 becomes 58.)
		if shield > 0 then
			shield = shield % 100

			-- If 200, then it will == 0. We want 100, not 0.
			if shield == 0 then
				shield = 100
			end

			-- The bar messes up when the value
			-- is less than 5
			if shield < 5 then
				shield = 5
			end
		end

		local tempColor = Color(shieldColor.r, shieldColor.g, shieldColor.b, 255) 

		-- Draw the background
		draw.RoundedBox(
			3,
			info.health.x,
			info.health.y,
			info.health.width,
			info.health.height,
			shieldColor
		)

		if shield > 0 then
			-- Draw the physical bar
			draw.RoundedBox(
				3,
				info.health.x + (padding.border * 2),
				info.health.y + (padding.border * 2),
				(info.health.width * (shield / 100)) - (padding.border * 4),
				info.health.height - (padding.border * 4),
				tempColor
			)
		end
	end
end

function DrawWeapons()
	local ply = LocalPlayer()

	if ply:GetActiveWeapon():IsValid() then
		local clip = ply:GetActiveWeapon():Clip1()
		local clipMax = ply:GetActiveWeapon():GetMaxClip1()
		local ammo = ply:GetAmmoCount(ply:GetActiveWeapon():GetPrimaryAmmoType())

		for i=0,clipMax-1,1 do
			local row = i % 15
			local col = math.floor(i / 15)

			local tempColor = Color(200, 220, 240, 50)

			if i < clip then
				tempColor.a = 200
			end

			draw.RoundedBox(
				3,
				info.weapons.x - 70 - (row * 15),
				info.weapons.y + (col * (25 * ((250 - clipMax) / 250))),
				10,
				(20 * ((250 - clipMax) / 250)),
				tempColor
			)
		end

		draw.SimpleText(
			ammo,
			"CustomFontA",
			info.weapons.x,
			info.weapons.y,
			Color(200, 220, 240, 255),
			TEXT_ALIGN_RIGHT
		)
	end
end

function DrawGrenades()

end

function DrawRadar()

end

function DrawScore()
	local lply = LocalPlayer()

	local gamemodeSettings = Gamemodes[lply:GetNWInt("CurrentGamemode")]
	local sIsTeam = gamemodeSettings.IsTeam
	local sTeams = gamemodeSettings.Teams
	local sPointsToWin = gamemodeSettings.PointsToWin
	local sModels = gamemodeSettings.Models

	-- We display 0 on top, 1 on bottom. We only display
	-- two at a time.
	local scoreData = {
		[0] = {
			Score = 0,
			Color = Color(33, 33, 33, 150)
		},
		[1] = {
			Score = 0,
			Color = Color(33, 33, 33, 150)
		}
	}

	local top = nil
	local topColor = Color(33, 33, 33, 150)
	local bottom = nil
	local bottomColor = Color(33, 33, 33, 150)
	local you = nil

	-- Check if this is a team-based game or not.
	if sIsTeam then
		for teamID, teamDataTable in pairs(sTeams) do
			local teamScore = lply:GetNWInt("team" .. teamID .. "Score")

			if !top or teamScore >= top then
				bottom = top
				bottomColor = topColor

				top = teamScore
				topColor = teamDataTable.Color

				if teamID == lply:Team() and !you then
					you = 0
				elseif teamID == lply:Team() and you and you == 0 then
					you = 1
				end
			elseif !bottom or teamScore >= bottom then
				bottom = teamScore
				bottomColor = teamDataTable.Color

				if teamID == lply:Team() and !you then
					you = 1
				elseif teamID == lply:Team() and you and you == 1 then
					you = nil
				end
			end
		end
	else
		for plyID, ply in pairs(player.GetAll()) do
			local plyScore = ply:GetNWInt("Score")
			local mod = ply:GetNWInt("Color")

			if IsValid(ply) and ply:Team() > 0 and ply:Team() < 1000 and sModels[mod] then
				local plyScore = ply:GetNWInt("Score")
				local mod = ply:GetNWInt("Color")

				if !top or plyScore >= top then
					bottom = top
					bottomColor = topColor

					top = plyScore
					topColor = sModels[mod][2]

					if ply == lply and !you then
						you = 0
					elseif ply == lply and you and you == 0 then
						you = 1
					end
				elseif !bottom or plyScore >= bottom then
					bottom = plyScore
					bottomColor = sModels[mod][2]

					if ply == lply and !you then
						you = 1
					elseif ply == lply and you and you == 1 then
						you = nil
					end
				end
			end
		end
	end

	scoreData[0].Score = top
	scoreData[0].Color = topColor
	scoreData[1].Score = bottom
	scoreData[1].Color = bottomColor

	-- Actually draw the scores

	local x = 1

	if !scoreData[1].Score then
		x = 0
	end

	if scoreData[0].Score then
		for i=0,x,1 do
			-- Add alpha to background
			local tempColor = scoreData[i].Color
			local score = scoreData[i].Score

			if score > sPointsToWin then
				score = sPointsToWin
			end

			local scoreBar = score

			tempColor.a = 100

			-- Draw the background
			draw.RoundedBox(
				3,
				info.score.x,
				info.score.y + (i * 35),
				info.score.width,
				info.score.height,
				tempColor
			)

			tempColor.a = 200

			if (scoreBar / sPointsToWin) < .07 and (scoreBar / sPointsToWin) > 0 then
				scoreBar = sPointsToWin * 0.07
			end

			if score > 0 then
				-- Draw the score bar
				draw.RoundedBox(
					3,
					info.score.x + (padding.border * 2),
					info.score.y + (i * 35) + (padding.border * 2),
					info.score.width * (scoreBar / sPointsToWin) - (padding.border * 4),
					info.score.height - (padding.border * 4),
					tempColor
				)
			end

			if you and you == i then
				score = "=>  " .. score
			end

			draw.SimpleText(
				score,
				"CustomFontA",
				info.score.x - 10,
				info.score.y + 5 + (i * 35),
				Color(200, 220, 240, 255),
				TEXT_ALIGN_RIGHT
			)
		end
	end
end

function DrawGMName()
	local gamemodeSettings = Gamemodes[LocalPlayer():GetNWInt("CurrentGamemode")]
	local sName = gamemodeSettings.Name

	draw.SimpleText(
		sName,
		"CustomFontA",
		info.gmName.x,
		info.gmName.y,
		Color(200, 220, 240, 255),
		TEXT_ALIGN_RIGHT
	)
end

function DrawTime()
	local timeRemaining = LocalPlayer():GetNWInt("timeRemaining") - math.floor(CurTime())
	local minutes = math.floor(timeRemaining / 60)
	local seconds = timeRemaining % 60

	draw.SimpleText(
		string.format("%.2d:%.2d", minutes, seconds),
		"CustomFontA",
		info.time.x,
		info.time.y,
		Color(200, 220, 240, 255),
		TEXT_ALIGN_RIGHT
	)
end

function DrawMessage()
	local ply = LocalPlayer()
	local timeRemaining = ply:GetNWInt("timeCountdown") - math.floor(CurTime())
	local roundActive = ply:GetNWInt("roundActive")

	local message = ""

	local x = info.message.x
	local y = info.message.y
	local font = "CustomFontB"
	local color = Color(200, 220, 240, 255)

	if IsValid(ply) then
		if roundActive == Rounds.Voting and timeRemaining >= 0 then
			local minutes = math.floor(timeRemaining / 60)
			local seconds = timeRemaining % 60

			message = string.format("%.2d:%.2d", minutes, seconds)

			x = 440
			y = 50
			color = Color(71, 105, 130, 200)
			font = "CustomFontE"

			draw.SimpleText("CAST YOUR VOTE", "CustomFontE", 60, 50, Color(255, 255, 255, 200), TEXT_ALIGN_LEFT)
		elseif roundActive == Rounds.InActive and timeRemaining >= 0 then
			message = "Round starts in " .. timeRemaining
		elseif !ply:Alive() then
			if timeRemaining >= 0 then
				message = "Respawn in " .. timeRemaining
			else
				message = "Respawn now!"
			end
		end
	end

	draw.SimpleText(
		message,
		font,
		x,
		y,
		color,
		TEXT_ALIGN_CENTER
	)
end

local votedForOption = -1
local drawAgain = true
optionList = nil
statsList = nil
EndRoundDerma = nil
EndRoundMessageDerma = nil
EndRoundBgDerma = nil
EndRoundBgAnimDerma = nil
EndRoundBgAnimDerma2 = nil

local function inQuad( fraction, beginning, change )
	if fraction > 0.5 then
		fraction = 1 - fraction
	end

	return change * ( fraction ^ 2 ) + beginning
end

function DrawBackground()
	if !IsValid(EndRoundBgDerma) then
		local mats = {
			"votebg1",
			"votebg2",
			"votebg3"
		}

		EndRoundBgDerma = vgui.Create("DFrame")
		EndRoundBgDerma:SetSize(ScrW(), ScrH())
		EndRoundBgDerma:SetPos(0, 0)
		EndRoundBgDerma:SetDraggable(false)
		EndRoundBgDerma:ShowCloseButton(false)
		EndRoundBgDerma:SetTitle("")
		EndRoundBgDerma.Paint = function()
		end

		local bgImage = vgui.Create("DImage", EndRoundBgDerma)
		bgImage:SetSize(EndRoundBgDerma:GetWide(), EndRoundBgDerma:GetTall())
		bgImage:SetPos(0, 0)
		bgImage:SetImage("materials/vgui/hud/" .. mats[math.random(#mats)] .. ".png", "vgui/avatar_default")

		EndRoundBgDerma:Show()
		EndRoundBgDerma:SetAlpha(0)
		EndRoundBgDerma:AlphaTo(255, FadeInTime, 0)
		EndRoundBgDerma:AlphaTo(0, FadeOutTime, 20)

		EndRoundBgAnimDerma = vgui.Create("DFrame")
		EndRoundBgAnimDerma:SetSize(ScrW() * 2, 200)
		EndRoundBgAnimDerma:SetPos(-ScrW(), ScrH() / 2 - 100)
		EndRoundBgAnimDerma:SetDraggable(false)
		EndRoundBgAnimDerma:ShowCloseButton(false)
		EndRoundBgAnimDerma:SetTitle("")
		EndRoundBgAnimDerma.Paint = function()
		end

		EndRoundBgAnimDerma:MoveTo(ScrW(), ScrH() / 2 - 100, 120, 0, 1)

		local bgImage = vgui.Create("DImage", EndRoundBgAnimDerma)
		bgImage:SetSize(EndRoundBgAnimDerma:GetWide(), EndRoundBgAnimDerma:GetTall())
		bgImage:SetPos(0, 0)
		bgImage:SetImage("materials/vgui/hud/dustbackground.png", "vgui/avatar_default")

		EndRoundBgAnimDerma:Show()
		EndRoundBgAnimDerma:SetAlpha(0)
		EndRoundBgAnimDerma:AlphaTo(255, FadeInTime, 1)
		EndRoundBgAnimDerma:AlphaTo(0, FadeOutTime, 19)

		EndRoundBgAnimDerma2 = vgui.Create("DFrame")
		EndRoundBgAnimDerma2:SetSize(ScrW() * 2, 400)
		EndRoundBgAnimDerma2:SetPos(-ScrW(), ScrH() / 2 - 200)
		EndRoundBgAnimDerma2:SetDraggable(false)
		EndRoundBgAnimDerma2:ShowCloseButton(false)
		EndRoundBgAnimDerma2:SetTitle("")
		EndRoundBgAnimDerma2.Paint = function()
		end

		EndRoundBgAnimDerma2:MoveTo(ScrW(), ScrH() / 2 - 200, 240, 0, 1)

		local bgImage = vgui.Create("DImage", EndRoundBgAnimDerma2)
		bgImage:SetSize(EndRoundBgAnimDerma2:GetWide(), EndRoundBgAnimDerma2:GetTall())
		bgImage:SetPos(0, 0)
		bgImage:SetImage("materials/vgui/hud/dustbackground2.png", "vgui/avatar_default")

		EndRoundBgAnimDerma2:Show()
		EndRoundBgAnimDerma2:SetAlpha(0)
		EndRoundBgAnimDerma2:AlphaTo(255, FadeInTime, 2)
		EndRoundBgAnimDerma2:AlphaTo(0, FadeOutTime, 18)
	else
		EndRoundBgDerma:Show()
	end
end

function DrawVotes(i, x, y)
	local votingChoiceVotes = LocalPlayer():GetNWInt("choice" .. i .. "Votes")
	draw.SimpleText(votingChoiceVotes, "CustomFontD", x, y, Color(200, 220, 240, 255), TEXT_ALIGN_RIGHT)
end

local function GetHighestMedal()
	local highest = 1
	local score = -1

	print("There are: " .. #EarnedMedals .. " medals earned.")
	-- if #EarnedMedals > 0 then
		for k, v in pairs(EarnedMedals) do
			print("Looking at " .. k .. " with a value of " .. v)
			if v >= score then
				highest = k
				score = v
			end
		end
	-- end

	print("Returning: " .. highest .. " with a score of " .. score)

	return highest
end

function DrawStatInfo()
	if statsList and IsValid(statsList) then
		statsList:Close()
		statsList = nil
	end

	statsList = vgui.Create("DFrame")
	statsList:SetTitle("")
	statsList:ShowCloseButton(false)
	statsList:SetPos(info.voting.x + 15, info.voting.y - 185)
	statsList:SetSize(info.voting.width - 15, 200)

	local mID = GetHighestMedal()
	local medal = Medals[mID]
	local medalCount = EarnedMedals[mID]

	local tKills = databaseGetValue("kills")
	local tDeaths = databaseGetValue("deaths")
	statsList.Paint = function(self, w, h)
		color = Color(200, 220, 240, 255)

		draw.RoundedBox(
			5, 0, 0, w, h, Color(11, 11, 11, 150)
		)

		draw.RoundedBox(
			5, 5, 5, w - 10, h - 10, Color(11, 11, 11, 150)
		)

		-- Total kills
		draw.SimpleText(
			"Total Kills",
			"CustomFontF",
			80,
			15,
			color,
			TEXT_ALIGN_CENTER
		)
		draw.SimpleText(
			comma_value(tKills),
			"CustomFontF",
			80,
			50,
			color,
			TEXT_ALIGN_CENTER
		)

		-- Total Deaths
		draw.SimpleText(
			"Total Deaths",
			"CustomFontF",
			250,
			15,
			color,
			TEXT_ALIGN_CENTER
		)

		draw.SimpleText(
			comma_value(tDeaths),
			"CustomFontF",
			250,
			50,
			color,
			TEXT_ALIGN_CENTER
		)

		-- Total Deaths
		draw.SimpleText(
			"Kill to Death",
			"CustomFontF",
			420,
			15,
			color,
			TEXT_ALIGN_CENTER
		)

		draw.SimpleText(
			round((tKills * 1.0) / tDeaths, 2),
			"CustomFontF",
			420,
			50,
			color,
			TEXT_ALIGN_CENTER
		)

		-- Most Medal
		draw.SimpleText(
			"Most Medals",
			"CustomFontF",
			w - 90,
			15,
			color,
			TEXT_ALIGN_CENTER
		)

		if medalCount and medalCount > 0 then
			draw.SimpleText(
				comma_value(medalCount),
				"CustomFontF",
				w - 90,
				120,
				color,
				TEXT_ALIGN_CENTER
			)

			draw.SimpleText(
				medal.Name,
				"CustomFontF",
				w - 90,
				150,
				color,
				TEXT_ALIGN_CENTER
			)
		end

		-- Experience
		local exp = LocalPlayer():GetNWInt("xp")
		local bar = GetProgress(exp)
		local level = GetRank(exp)

		-- Total kills
		draw.SimpleText(
			"Level: " .. level,
			"CustomFontF",
			35,
			h / 2 + 15,
			color,
			TEXT_ALIGN_LEFT
		)

		draw.RoundedBox(
			1, 35, h - 40, 400, 25, Color(99, 99, 99, 200)
		)

		draw.RoundedBox(
			1, 35, h - 40, 400 * (bar / 100.0), 25, color
		)

		if medalCount and medalCount > 0 then
			-- Most Medals -- EarnedMedals
			local slotImage = vgui.Create("DImage", statsList)
			slotImage:SetPos(w - 115, 55)
			slotImage:SetSize(50, 50)
			slotImage:SetImage("materials/vgui/medals/" .. medal.image .. ".png", "vgui/avatar_default")
		end
	end
end

function DrawRoundEndScreen()
	-- drawAgain = true

	draw.RoundedBox(
		0,
		0,
		0,
		ScrW(),
		ScrH(),
		Color(11, 11, 11, 255)
	)

	if !IsValid(EndRoundDerma) or !IsValid(optionList) or !IsValid(statsList) then
		DrawBackground()

		EndRoundMessageDerma = vgui.Create("DFrame")
		EndRoundMessageDerma:SetSize(500, 90)
		EndRoundMessageDerma:SetPos(0, 0)
		EndRoundMessageDerma:SetTitle("")
		EndRoundMessageDerma:SetDraggable(false)
		EndRoundMessageDerma:ShowCloseButton(false)
		EndRoundMessageDerma:MakePopup()
		EndRoundMessageDerma:SetKeyboardInputEnabled(false)
		EndRoundMessageDerma.Paint = function()
			DrawMessage()
		end
		EndRoundMessageDerma:SetAlpha(0)
		EndRoundMessageDerma:AlphaTo(255, FadeInTime, 0)
		EndRoundMessageDerma:AlphaTo(0, FadeOutTime, 20)

		EndRoundDerma = vgui.Create("DFrame")
		EndRoundDerma:SetSize(info.voting.width, info.voting.height)
		EndRoundDerma:SetPos(info.voting.x, info.voting.y)
		EndRoundDerma:SetTitle("")
		EndRoundDerma:SetDraggable(false)
		EndRoundDerma:ShowCloseButton(false)
		EndRoundDerma:MakePopup()
		EndRoundDerma.Paint = function()
		end

		local optionScrollPanel = vgui.Create("DPanel", EndRoundDerma)
		optionScrollPanel:SetSize(EndRoundDerma:GetWide(), EndRoundDerma:GetTall() - 30)
		optionScrollPanel:SetPos(0, 30)
		optionScrollPanel.Paint = function()
		end

		optionList = vgui.Create("DPanel", optionScrollPanel)
		optionList:SetSize(EndRoundDerma:GetWide(), optionScrollPanel:GetTall())
		optionList:SetPos(0, 0)
		optionList.Paint = function()
		end
		optionList:SetAlpha(0)
		optionList:AlphaTo(255, FadeInTime, 0)
		optionList:AlphaTo(0, FadeOutTime, 20)

		DrawStatInfo()

		HideScoreBoard()
		ShowScoreBoard(ScrW() - 500 - 30)
	end

	if IsValid(EndRoundDerma) and IsValid(optionList) and drawAgain then
		drawAgain = false
		optionList:Clear()

		for i=1,Voting.Options,1 do
			local votingChoiceGM = LocalPlayer():GetNWInt("choice" .. i)
			local votingChoiceID = LocalPlayer():GetNWInt("choice" .. i .. "ID")

			print("ID: " .. votingChoiceID)
			local mapName = Voting.Maps[votingChoiceID].Name

			local optionPanel = vgui.Create("DButton", optionList)
			optionPanel:SetSize(optionList:GetWide() / (Voting.Options) - 5, optionList:GetTall())
			optionPanel:SetPos((i - 1) * optionList:GetWide() / Voting.Options + 10, starty)
			optionPanel:SetText("")
			optionPanel.Paint = function()
				local tempColor = Color(92, 132, 144, 175)

				if i == votedForOption then
					tempColor = Color(243, 156, 18, 175)
				end

				draw.RoundedBox(5, 5, 5, optionPanel:GetWide() - 10, optionPanel:GetTall() - 10, tempColor)
				draw.RoundedBox(5, 10, 10, optionPanel:GetWide() - 20, optionPanel:GetTall() - 20, Color(33, 33, 33, 100))
				
				-- Map picture
				draw.RoundedBox(5, 10, 10, optionPanel:GetWide() - 20, optionPanel:GetWide() - 20, Color(33, 33, 33, 100))

				if votingChoiceGM then
					DrawVotes(i, optionPanel:GetWide() - 15, optionPanel:GetWide() - 5)
					-- draw.SimpleText(votingChoiceVotes, "CustomFontA", optionPanel:GetWide() - 30, optionPanel:GetWide() - 30, Color(200, 220, 240, 255), TEXT_ALIGN_LEFT)
					draw.SimpleText(mapName, "CustomFontD", 15, optionPanel:GetWide() + 10, Color(200, 220, 240, 255), TEXT_ALIGN_LEFT)
					draw.SimpleText(Gamemodes[votingChoiceGM].Name, "CustomFontD", 15, optionPanel:GetWide() + 40, Color(200, 220, 240, 255), TEXT_ALIGN_LEFT)
				end
			end

			local bgImage = vgui.Create("DImage", optionPanel)
			bgImage:SetSize(optionPanel:GetWide() - 20, optionPanel:GetWide() - 20)
			bgImage:SetPos(10, 10)
			bgImage:SetImage("materials/vgui/maps/" .. Voting.Maps[votingChoiceID].Image .. ".png", "vgui/avatar_default")
			if bgImage:GetImage() == "vgui/avatar_default" then
				-- bgImage:Hide()
				-- bgImage = nil
			end

			optionPanel.DoClick = function()
				print("Voted for " .. i)
				votedForOption = i
				LocalPlayer():ConCommand("vote " .. i)
			end
		end
	else
		if drawAgain then
			print("Something's not valid")
		end
	end
end

EndingDerma = nil

function DrawEndingScreen()
	if !EndingDerma or !IsValid(EndingDerma) then
		surface.PlaySound("ghalo/music/votingsong.ogg")
		surface.PlaySound("ghalo/effects/gameover.ogg")

		EndingDerma = vgui.Create("DFrame")
		EndingDerma:SetSize(ScrW(), ScrH())
		EndingDerma:SetPos(0, 0)
		EndingDerma:SetTitle("")
		EndingDerma:SetDraggable(false)
		EndingDerma:ShowCloseButton(false)
		EndingDerma:MakePopup()
		EndingDerma:SetKeyboardInputEnabled(false)
		EndingDerma.Paint = function()
			draw.RoundedBox(
				0,
				0,
				0,
				EndingDerma:GetWide(),
				EndingDerma:GetTall(),
				Color(0, 0, 0, 255)
			)
	    end

		EndingDerma:SetAlpha(0)
    	EndingDerma:AlphaTo(255, FadeTime - 1, 0, function()
	    	timer.Simple(1.5, function()
	    		EndingDerma:SetAlpha(255)
		    	EndingDerma:Close()
		    	EndingDerma	= nil
	    	end)
    	end)
	end
end

function DrawGametypePopup(gameType)
	local gmSettings = Gamemodes[LocalPlayer():GetNWInt("CurrentGamemode")]
	local ply = LocalPlayer()

	local GTDerma = vgui.Create("DFrame")
	GTDerma:SetSize(525, 125)
	GTDerma:SetPos(ScrW() / 2 - 525 / 2, ScrH() - 125 - 125)
	GTDerma:SetTitle("")
	GTDerma:SetDraggable(false)
	GTDerma:ShowCloseButton(false)
	GTDerma.Paint = function()
		-- The box itself.
		local color = Color(0, 0, 0)

		if gmSettings.IsTeam then
			color = gmSettings.Teams[ply:Team()].Color
		else
			local mods = gmSettings.Models
			if mods and mods[ply:GetNWInt("Color")] then
				color = mods[ply:GetNWInt("Color")][2]
			else
				color = Color(120, 35, 33)
			end
		end

		color.a = 255

		draw.RoundedBox(
			5,
			0,
			0,
			GTDerma:GetWide(),
			GTDerma:GetTall(),
			color
		)

		draw.RoundedBox(
			5,
			5,
			5,
			GTDerma:GetWide() - 10,
			GTDerma:GetTall()- 10,
			color
		)

		-- Gametype picture
		draw.RoundedBox(
			5,
			15,
			15,
			95,
			95,
			Color(33, 33, 33, 255)
		)

		draw.SimpleText(
			gmSettings.Name,
			"CustomFontB",
			95 + 30 + 10,
			15,
			Color(200, 220, 240, 255),
			TEXT_ALIGN_LEFT
		)

		draw.SimpleText(
			gmSettings.Name,
			"CustomFontB",
			95 + 30 + 10,
			15,
			Color(200, 220, 240, 255),
			TEXT_ALIGN_LEFT
		)

		if gmSettings.Description then
			local desc = gmSettings.Description

			draw.SimpleText(
				string.sub(gmSettings.Description, 0, 44),
				"CustomFontA",
				95 + 30 + 10,
				15 + 42,
				Color(200, 220, 240, 255),
				TEXT_ALIGN_LEFT
			)

			if string.len(desc) > 43 then
				draw.SimpleText(
					string.sub(gmSettings.Description, 45, 88),
					"CustomFontA",
					95 + 30 + 10,
					15 + 40 + 30,
					Color(200, 220, 240, 255),
					TEXT_ALIGN_LEFT
				)
			end
		end
    end

	GTDerma:SetAlpha(0)
	GTDerma:AlphaTo(150, 2, 0)
	GTDerma:AlphaTo(0, 2, 8, function()
    	timer.Simple(1.5, function()
    		GTDerma:SetAlpha(255)
	    	GTDerma:Close()
	    	GTDerma	= nil
    	end)
	end)
end

lastTimeRemaining = -1
lastRoundState = -1
lastClock = -1
hasPlayedGameType = false

function DrawHud()
	if !Gamemodes then return false end
	local x = Gamemodes[LocalPlayer():GetNWInt("CurrentGametype")]
	if !x then return false end

	local roundType = LocalPlayer():GetNWInt("roundActive")
	local timeRemaining = LocalPlayer():GetNWInt("timeCountdown") - math.floor(CurTime())
	local clock = LocalPlayer():GetNWInt("timeRemaining") - math.floor(CurTime())

	if lastTimeRemaining > timeRemaining then
		if timeRemaining <= 3 and timeRemaining >= 1 then
			surface.PlaySound("ghalo/effects/beeplow.ogg")
		end

		if timeRemaining == 0 then
			surface.PlaySound("ghalo/effects/beephigh.ogg")
		end
	end

	if lastClock > clock then
		if clock == 60 then
			surface.PlaySound("ghalo/effects/oneminuteremaining.ogg")
		end

		if clock == 10 then
			surface.PlaySound("ghalo/effects/tensecondsremaining.ogg")
		end
	end

	if roundType == Rounds.Active then
		if lastRoundState == Rounds.InActive or !hasPlayedGameType then
			local gmSettings = Gamemodes[LocalPlayer():GetNWInt("CurrentGamemode")]
			if gmSettings and gmSettings.GameType then
				surface.PlaySound("ghalo/effects/" .. gmSettings.GameType .. ".ogg")
			else
				print("No gametype found.")
			end

			if gmSettings then
				DrawGametypePopup(gmSettings.GameType)
				hasPlayedGameType = true
			end

			EarnedMedals = {}
		end

		if EndRoundDerma then
			EndRoundMessageDerma:Close()
			EndRoundMessageDerma = nil
			EndRoundDerma:Close()
			EndRoundDerma = nil
			optionList = nil
			statsList:Close()
			statsList = nil
			votedForOption = -1
			drawAgain = true
			EndRoundBgDerma:Close()
			EndRoundBgDerma = nil
			EndRoundBgAnimDerma:Close()
			EndRoundBgAnimDerma = nil
			EndRoundBgAnimDerma2:Close()
			EndRoundBgAnimDerma2 = nil
			HideScoreBoard()
		end

		DrawHealth()
		DrawWeapons()
		DrawGrenades()
		DrawRadar()
		DrawScore()
		DrawGMName()
		DrawTime()
		DrawMessage()
	else
		hasPlayedGameType = false

		if timeRemaining >= 1 and roundType == Rounds.Voting then
			DrawRoundEndScreen()
		elseif roundType == Rounds.Ending then
			DrawEndingScreen()
		else
			if EndRoundDerma then
				EndRoundMessageDerma:Close()
				EndRoundMessageDerma = nil
				EndRoundDerma:Close()
				EndRoundDerma = nil
				optionList = nil
				statsList:Close()
				statsList = nil
				votedForOption = -1
				drawAgain = true
				EndRoundBgDerma:Close()
				EndRoundBgDerma = nil
				EndRoundBgAnimDerma:Close()
				EndRoundBgAnimDerma = nil
				EndRoundBgAnimDerma2:Close()
				EndRoundBgAnimDerma2 = nil
				HideScoreBoard()
			end
			DrawMessage()
		end
	end

	lastTimeRemaining = timeRemaining
	lastRoundState = roundType
	lastClock = clock
end

function hud()
	if ClientOptions and ClientOptions.HUD then
		PaintWorldTips()
		DrawHud()
	end
end

hook.Add("HUDPaint", "MyHudName", hud) -- I'll explain hooks and functions in a second
 
function hidehud(name)
	for k, v in pairs({"CHudHealth", "CHudBattery", "CHudSecondaryAmmo", "CHudAmmo"}) do
		if name == v then 
			return false
		end
	end
end

hook.Add("HUDShouldDraw", "HideOurHud", hidehud)
