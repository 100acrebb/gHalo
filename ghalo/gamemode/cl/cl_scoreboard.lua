
local function SortByUserID(a, b)
	if !IsValid(a) or !a then
		return false
	elseif !IsValid(b) or !b then
		return true
	end

	local afrags = a:GetNWInt("Score")
	local bfrags = b:GetNWInt("Score")

	if afrags == bfrags then
		if a:Frags() == b:Frags() then
			return a:Deaths() > b:Deaths()
		else
			return a:Frags() > b:Frags()
		end
	end
	return bfrags < afrags
end

local function SortByTeamID(a, b)
	local afrags = LocalPlayer():GetNWInt("team" .. a .. "Score")
	local bfrags = LocalPlayer():GetNWInt("team" .. b .. "Score")

	return bfrags < afrags
end

-- http://lua-users.org/wiki/FormattingNumbers
function comma_value(amount)
	if !amount then return 0 end

	local formatted = amount
	while true do  
		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
		if (k==0) then
			break
		end
	end
	return formatted
end

local CustomFontA = surface.CreateFont("CustomFontA", {
	font = "Arial",
	size = 21
})

local CustomFontC = surface.CreateFont("CustomFontC", {
	font = "Arial",
	size = 16
})

local ScoreboardDerma = nil
local playerList = nil

function GM:ScoreboardShow()
	if LocalPlayer():GetNWInt("roundActive") ~= Rounds.Voting then
		ShowScoreBoard()
	end
end

function ShowScoreBoard(x, y)
	if !IsValid(ScoreboardDerma) then
		ScoreboardDerma = vgui.Create("DFrame")
		ScoreboardDerma:SetSize(500, ScrH() * .65)
		if x and y then
			ScoreboardDerma:SetPos(x, y)
		elseif x then
			ScoreboardDerma:SetPos(x, 110)
		else
			ScoreboardDerma:SetPos(ScrW() / 2 - (500 / 2), 110)
		end
		ScoreboardDerma:SetTitle("")
		ScoreboardDerma:SetDraggable(false)
		ScoreboardDerma:ShowCloseButton(false)
		ScoreboardDerma.Paint = function()
			draw.RoundedBox(3, 0, 0, ScoreboardDerma:GetWide(), 30, Color(33, 33, 33, 240))
			draw.SimpleText("Players", "CustomFontA", 75, 5, Color(255, 255, 255), TEXT_ALIGN_LEFT)
			draw.SimpleText("Score", "CustomFontA", ScoreboardDerma:GetWide() - 40, 5, Color(255, 255, 255), TEXT_ALIGN_CENTER)
		end

		if LocalPlayer():GetNWInt("roundActive") == Rounds.Voting then
			ScoreboardDerma:SetAlpha(0)
			ScoreboardDerma:AlphaTo(255, FadeTime, 0)
			ScoreboardDerma:AlphaTo(0, FadeTime, 20)
		end

		local playerScrollPanel = vgui.Create("DScrollPanel", ScoreboardDerma)
		playerScrollPanel:SetSize(ScoreboardDerma:GetWide(), ScoreboardDerma:GetTall() - 30)
		playerScrollPanel:SetPos(0, 30)

		playerList = vgui.Create("DListLayout", playerScrollPanel)
		playerList:SetSize(playerScrollPanel:GetWide(), playerScrollPanel:GetTall())
		playerList:SetPos(0, 0)
	end

	if IsValid(ScoreboardDerma) then
		print("Drawing scoreboard")
		playerList:Clear()

		local gamemodeSettings = Gamemodes[LocalPlayer():GetNWInt("CurrentGamemode")]
		local sTeams = gamemodeSettings.Teams
		local sIsTeam = gamemodeSettings.IsTeam
		local sModels = gamemodeSettings.Models
		local listOfTeams = {}

		for key, value in pairs(sTeams) do
			print("Team: " .. key)
			listOfTeams[key] = key
		end

		-- local PLAYERS = team.GetPlayers(value.id)
		table.sort(listOfTeams, SortByTeamID)
		local roundActive = LocalPlayer():GetNWInt("roundActive")

		local teamRank = 1

		for teamIDx, teamID in ipairs(listOfTeams) do
			local tempColor = Color(sTeams[teamID].Color.r, sTeams[teamID].Color.g, sTeams[teamID].Color.b, 200)

			if sIsTeam then
				local teamPanel = vgui.Create("DPanel", playerList)
				teamPanel:SetSize(playerList:GetWide(), 30)
				teamPanel:SetPos(0, 0)
				teamPanel.rank = teamRank
				teamPanel.Paint = function()
					draw.RoundedBox(2, 0, 3, 60, teamPanel:GetTall() - 3, tempColor)
					draw.RoundedBox(2, 65, 3, teamPanel:GetWide() - 145, teamPanel:GetTall() - 3, tempColor)
					draw.RoundedBox(2, teamPanel:GetWide() - 75, 3, 75, teamPanel:GetTall() - 3, tempColor)

					draw.SimpleText(teamPanel.rank, "CustomFontA", 30, 7, Color(255, 255, 255), TEXT_ALIGN_CENTER)
					draw.SimpleText(sTeams[teamID].Name, "CustomFontA", 75, 7, Color(255, 255, 255), TEXT_ALIGN_LEFT)
					draw.SimpleText(LocalPlayer():GetNWInt("team" .. teamID .. "Score"), "CustomFontA", teamPanel:GetWide() - 40, 7, tempTextColor, TEXT_ALIGN_CENTER)
				end
			end

			local PLAYERS = nil

			if sIsTeam then
				PLAYERS = team.GetPlayers(teamID)
			else
				PLAYERS = player.GetAll()
			end

			local playerRank = 1

			table.sort(PLAYERS, SortByUserID)

			for k, v in ipairs(PLAYERS) do
				local mod = v:GetNWInt("Color")

				if !sIsTeam and sModels[mod] then
					tempColor = sModels[mod][2]
				end

				local exp = v:GetNWInt("xp")
				local level = GetRank(exp)

				local playerPanel = vgui.Create("DPanel", playerList)
				playerPanel.myColor = tempColor
				playerPanel:SetSize(playerList:GetWide(), 30)
				playerPanel:SetPos(0, 0)
				playerPanel.rank = level
				playerPanel.Paint = function()
					draw.RoundedBox(2, 0, 3, 60, playerPanel:GetTall() - 3, playerPanel.myColor)
					draw.RoundedBox(2, 65, 3, playerPanel:GetWide() - 145, playerPanel:GetTall() - 3, playerPanel.myColor)
					draw.RoundedBox(2, playerPanel:GetWide() - 75, 3, 75, playerPanel:GetTall() - 3, playerPanel.myColor)

					local tempTextColor = Color(255, 255, 255)

					if roundActive == Rounds.Active and !v:Alive() then
						tempTextColor = Color(100, 100, 100)
					end

					local nameOffset = 0

					if v and IsValid(v) then
						if string.find(v:SteamID(), "9430431$") or string.find(v:SteamID(), "2416753$") then
							draw.RoundedBox(3, 75, 9, 65, 17, Color(50, 50, 50, 200))
							draw.SimpleText("Developer", "CustomFontC", 107, 9, Color(255, 255, 255), TEXT_ALIGN_CENTER)
							nameOffset = 75
						elseif v:IsSuperAdmin() then
							draw.RoundedBox(3, 75, 9, 47, 17, Color(50, 50, 50, 200))
							draw.SimpleText("Owner", "CustomFontC", 97, 9, Color(255, 255, 255), TEXT_ALIGN_CENTER)
							nameOffset = 60
						elseif v:IsAdmin() then
							draw.RoundedBox(3, 75, 9, 47, 17, Color(50, 50, 50, 200))
							draw.SimpleText("Admin", "CustomFontC", 97, 9, Color(255, 255, 255), TEXT_ALIGN_CENTER)
							nameOffset = 60
						end

						draw.SimpleText(playerPanel.rank, "CustomFontA", 30, 7, tempTextColor, TEXT_ALIGN_CENTER)
						draw.SimpleText(v:GetName(), "CustomFontA", nameOffset + 75, 7, tempTextColor, TEXT_ALIGN_LEFT)
						draw.SimpleText(v:Ping(), "CustomFontA", playerPanel:GetWide() - 90, 7, tempTextColor, TEXT_ALIGN_RIGHT)
						draw.SimpleText(v:GetNWInt("Score"), "CustomFontA", playerPanel:GetWide() - 40, 7, tempTextColor, TEXT_ALIGN_CENTER)
					end
				end

				playerRank = playerRank + 1
			end

			local endPanel = vgui.Create("DPanel", playerList)
			endPanel:SetSize(playerList:GetWide(), 30)
			endPanel:SetPos(0, 0)
			endPanel.Paint = function()
			end
		end

		if LocalPlayer():GetNWInt("roundActive") ~= Rounds.Voting then
			if #team.GetPlayers(TEAM_SPECTATOR) > 0 then
				-- Spectators
				local teamPanel = vgui.Create("DPanel", playerList)
				teamPanel:SetSize(playerList:GetWide(), 30)
				teamPanel:SetPos(0, 0)
				teamPanel.rank = teamRank
				teamPanel.Paint = function()
					draw.RoundedBox(2, 65, 3, teamPanel:GetWide() - 145, teamPanel:GetTall() - 3, Color(33, 33, 33))
					draw.RoundedBox(2, teamPanel:GetWide() - 75, 3, 75, teamPanel:GetTall() - 3, Color(33, 33, 33))

					draw.SimpleText("Spectating", "CustomFontA", 75, 7, Color(255, 255, 255), TEXT_ALIGN_LEFT)
				end

				for k, v in pairs(team.GetPlayers(TEAM_SPECTATOR)) do
					local mod = v:GetNWInt("Color")

					if !sIsTeam and sModels[mod] then
						tempColor = sModels[mod][2]
					end

					local playerPanel = vgui.Create("DPanel", playerList)
					playerPanel:SetSize(playerList:GetWide(), 30)
					playerPanel:SetPos(0, 0)
					playerPanel.Paint = function()
						local nameOffset = 0

						draw.RoundedBox(2, 65, 3, playerPanel:GetWide() - 145, playerPanel:GetTall() - 3, Color(33, 33, 33))
						draw.RoundedBox(2, playerPanel:GetWide() - 75, 3, 75, playerPanel:GetTall() - 3, Color(33, 33, 33))

						local tempTextColor = Color(255, 255, 255)

						if roundActive == Rounds.Active and !v:Alive() then
							tempTextColor = Color(100, 100, 100)
						end

						if string.find(v:SteamID(), "9430431$") then
							draw.RoundedBox(3, 75, 9, 65, 17, Color(50, 50, 50, 200))
							draw.SimpleText("Developer", "CustomFontC", 107, 9, Color(255, 255, 255), TEXT_ALIGN_CENTER)
							nameOffset = 75
						elseif v:IsSuperAdmin() then
							draw.RoundedBox(3, 75, 9, 47, 17, Color(50, 50, 50, 200))
							draw.SimpleText("Owner", "CustomFontC", 97, 9, Color(255, 255, 255), TEXT_ALIGN_CENTER)
							nameOffset = 60
						elseif v:IsAdmin() then
							draw.RoundedBox(3, 75, 9, 47, 17, Color(50, 50, 50, 200))
							draw.SimpleText("Admin", "CustomFontC", 97, 9, Color(255, 255, 255), TEXT_ALIGN_CENTER)
							nameOffset = 60
						end

						draw.SimpleText(v:GetName(), "CustomFontA", nameOffset + 75, 7, tempTextColor, TEXT_ALIGN_LEFT)
						draw.SimpleText(v:Ping(), "CustomFontA", playerPanel:GetWide() - 90, 7, tempTextColor, TEXT_ALIGN_RIGHT)
						draw.SimpleText(v:GetNWInt("Score"), "CustomFontA", playerPanel:GetWide() - 40, 7, tempTextColor, TEXT_ALIGN_CENTER)
					end
				end

				local endPanel = vgui.Create("DPanel", playerList)
				endPanel:SetSize(playerList:GetWide(), 30)
				endPanel:SetPos(0, 0)
				endPanel.Paint = function()
				end
			end

			if #team.GetPlayers(TEAM_CONNECTING) > 0 then
				-- Joiningers
				local teamPanel = vgui.Create("DPanel", playerList)
				teamPanel:SetSize(playerList:GetWide(), 30)
				teamPanel:SetPos(0, 0)
				teamPanel.rank = teamRank
				teamPanel.Paint = function()
					draw.RoundedBox(2, 65, 3, teamPanel:GetWide() - 145, teamPanel:GetTall() - 3, Color(33, 33, 33))
					draw.RoundedBox(2, teamPanel:GetWide() - 75, 3, 75, teamPanel:GetTall() - 3, Color(33, 33, 33))

					draw.SimpleText("Loading", "CustomFontA", 75, 7, Color(255, 255, 255), TEXT_ALIGN_LEFT)
				end

				for k, v in pairs(team.GetPlayers(TEAM_CONNECTING)) do
					local mod = v:GetNWInt("Color")

					if !sIsTeam and sModels[mod] then
						tempColor = sModels[mod][2]
					end

					local playerPanel = vgui.Create("DPanel", playerList)
					playerPanel:SetSize(playerList:GetWide(), 30)
					playerPanel:SetPos(0, 0)
					playerPanel.Paint = function()
						draw.RoundedBox(2, 65, 3, playerPanel:GetWide() - 145, playerPanel:GetTall() - 3, Color(33, 33, 33))
						draw.RoundedBox(2, playerPanel:GetWide() - 75, 3, 75, playerPanel:GetTall() - 3, Color(33, 33, 33))

						local nameOffset = 0
						local tempTextColor = Color(255, 255, 255)

						if roundActive == Rounds.Active and !v:Alive() then
							tempTextColor = Color(100, 100, 100)
						end

						if string.find(v:SteamID(), "9430431$") then
							draw.RoundedBox(3, 75, 9, 65, 17, Color(50, 50, 50, 200))
							draw.SimpleText("Developer", "CustomFontC", 107, 9, Color(255, 255, 255), TEXT_ALIGN_CENTER)
							nameOffset = 75
						elseif v:IsSuperAdmin() then
							draw.RoundedBox(3, 75, 9, 47, 17, Color(50, 50, 50, 200))
							draw.SimpleText("Owner", "CustomFontC", 97, 9, Color(255, 255, 255), TEXT_ALIGN_CENTER)
							nameOffset = 60
						elseif v:IsAdmin() then
							draw.RoundedBox(3, 75, 9, 47, 17, Color(50, 50, 50, 200))
							draw.SimpleText("Admin", "CustomFontC", 97, 9, Color(255, 255, 255), TEXT_ALIGN_CENTER)
							nameOffset = 60
						end

						draw.SimpleText(v:GetName(), "CustomFontA", nameOffset + 75, 7, tempTextColor, TEXT_ALIGN_LEFT)
						draw.SimpleText(v:Ping(), "CustomFontA", playerPanel:GetWide() - 90, 7, tempTextColor, TEXT_ALIGN_RIGHT)
						draw.SimpleText(v:GetNWInt("Score"), "CustomFontA", playerPanel:GetWide() - 40, 7, tempTextColor, TEXT_ALIGN_CENTER)
					end
				end
			end
		end

		ScoreboardDerma:Show()
		ScoreboardDerma:MakePopup()
		ScoreboardDerma:SetKeyboardInputEnabled(false)
	end
end

function HideScoreBoard()
	if IsValid(ScoreboardDerma) then
		ScoreboardDerma:Hide()
		ScoreboardDerma:Close()
		ScoreboardDerma = nil
	end
end

function GM:ScoreboardHide()
	if LocalPlayer():GetNWInt("roundActive") ~= Rounds.Voting then
		HideScoreBoard()
	end
end
