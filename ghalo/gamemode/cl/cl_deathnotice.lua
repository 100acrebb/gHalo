
local CustomFontG = surface.CreateFont("CustomFontG", {
	font = "Arial",
	size = 18
})

local deathNoticeDerma = nil
local playerList = nil

local deathNoticeList = {}
local deathNoticeCur = 0
local maxDeathNotice = 5

function drawDeathNotice(victim, attacker)
	if !IsValid(deathNoticeDerma) then
		deathNoticeDerma = vgui.Create("DFrame")
		deathNoticeDerma:SetSize(420, 200)
		deathNoticeDerma:SetPos(20, 20)
		deathNoticeDerma:SetTitle("")
		deathNoticeDerma:SetDraggable(false)
		deathNoticeDerma:ShowCloseButton(false)

		deathNoticeDerma.Paint = function()
			draw.RoundedBox(5, 0, 0, 650, 200, Color(0, 0, 0, 0))
		end

		local playerScrollPanel = vgui.Create("DScrollPanel", deathNoticeDerma)
		playerScrollPanel:SetSize(deathNoticeDerma:GetWide(), deathNoticeDerma:GetTall())
		playerScrollPanel:SetPos(0, 0)

		playerList = vgui.Create("DListLayout", playerScrollPanel)
		playerList:SetSize(playerScrollPanel:GetWide(), playerScrollPanel:GetTall())
		playerList:SetPos(0, 0)
		playerList:SetVerticalScrollbarEnabled(false)

		deathNoticeDerma:Show()
	end

	if IsValid(deathNoticeDerma) then
		if IsValid(victim) and IsValid(attacker) then
			local gmSettings = Gamemodes[LocalPlayer():GetNWInt("CurrentGamemode")]
			local sIsTeam = gmSettings.IsTeam
			local aTeam = gmSettings.Teams[attacker:Team()]
			local vTeam = gmSettings.Teams[victim:Team()]

			local playerPanel = vgui.Create("DPanel", playerList)
			playerPanel:SetSize(playerList:GetWide(), 40)
			playerPanel:SetPos(0, 0)
			playerPanel.Paint = function()
				draw.RoundedBox(5, 2, 2, playerPanel:GetWide() - 4, playerPanel:GetTall() - 4, Color(33, 33, 33, 240))

				local msgColor = Color(255, 255, 255)

				if attacker:Team() and sIsTeam then
					msgColor = aTeam.Color
				end

				local killMessage = victim:GetName() .. " was killed by " .. attacker:GetName()

				if victim == attacker and attacker == LocalPlayer() then
					killMessage = "You killed yourself!"
				elseif victm == attacker then
					killMessage = victim:GetName() .. " killed themselves"
				elseif victim == LocalPlayer() then
					if sIsTeam and victim:Team() == attacker:Team() then
						killMessage = "You were killed by your teammate " .. attacker:GetName()
						msgColor = Color(155, 89, 182)
					else
						killMessage = "You were killed by " .. attacker:GetName()
						msgColor = Color(255, 255, 255)
					end
				elseif attacker == LocalPlayer() then
					killMessage = "You killed " .. victim:GetName()
					if sIsTeam and victim:Team() == attacker:Team() then
						killMessage = "You killed your teammate " .. victim:GetName()
						msgColor = Color(155, 89, 182)
					else
						killMessage = "You killed " .. victim:GetName()
						msgColor = Color(46, 204, 113)
					end
				elseif sIsTeam and victim:Team() == attacker:Team() then
					killMessage = victim:GetName() .. " was killed by their teammate " .. attacker:GetName()
					msgColor = Color(155, 89, 182)
				end

				draw.SimpleText(killMessage, "CustomFontG", 15, 10, msgColor)
			end

			timer.Simple(6, function()
				if IsValid(playerPanel) then
					playerPanel:Remove()
				end
			end)

			playerList:SetVerticalScrollbarEnabled(false)
		end
	end
end

function PlayerKilledMessage( um )
	local victim = um:ReadEntity()
	local attacker = um:ReadEntity()
	-- print(victim:GetName() .. " was killed by " .. attacker:GetName())
	drawDeathNotice(victim, attacker)
end

usermessage.Hook("PlayerKilled", PlayerKilledMessage)
