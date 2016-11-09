
GM.Name = "Halo: GMod Edition"
GM.Author = "Vader"
GM.Email = "NA"
GM.Website = "NA"

DeriveGamemode( "sandbox" )

-- local oldPrint = print
-- local function print(s)
-- 	oldPrint("[" .. GM.Folder .. "->shared.lua:] " .. s)
-- end

FadeTime = 5
FadeInTime = 5
FadeOutTime = 3

Colors = {
	Red = Color(120, 35, 33),
	Blue = Color(39, 58, 145),
	Green = Color(36, 163, 42),
	Violet = Color(95, 61, 176),
	Teal = Color(56, 117, 112),
	Tan = Color(163, 138, 84),
	Steel = Color(77, 77, 77),
	Sage = Color(34, 88, 61),
	Purple = Color(109, 59, 104),
	Pink = Color(212, 140, 196),
	Orange = Color(213, 110, 33),
	Olive = Color(153, 1178, 84),
	Mc = Color(113, 122, 72),
	Gold = Color(213, 213, 48),
	Cyan = Color(28, 172, 156),
	Crimson = Color(136, 7, 62),
	Cobalt = Color(66, 106, 138),
	Brown = Color(95, 69, 55)
}

Rounds = {
	InActive = 0,
	Active = 1,
	Voting = 2,
	Ending = 3
}

Voting = {
	Options = 4,
	Maps = MapData
}

AllPlayerModels = {
	{"models/halo2/spartan_Red.mdl", Colors.Red},
	{"models/halo2/spartan_Blue.mdl", Colors.Blue},
	{"models/halo2/spartan_Green.mdl", Colors.Green},
	{"models/halo2/spartan_Violet.mdl", Colors.Violet},
	{"models/halo2/spartan_Teal.mdl", Colors.Teal},
	{"models/halo2/spartan_Tan.mdl", Colors.Tan},
	{"models/halo2/spartan_Steel.mdl", Colors.Steel},
	{"models/halo2/spartan_Sage.mdl", Colors.Sage},
	{"models/halo2/spartan_Purple.mdl", Colors.Purple},
	{"models/halo2/spartan_Pink.mdl", Colors.Pink},
	{"models/halo2/spartan_Orange.mdl", Colors.Orange},
	{"models/halo2/spartan_Olive.mdl", Colors.Olive},
	{"models/halo2/spartan_Mc.mdl", Colors.Mc},
	{"models/halo2/spartan_Gold.mdl", Colors.Gold},
	{"models/halo2/spartan_Cyan.mdl", Colors.Cyan},
	{"models/halo2/spartan_Crimson.mdl", Colors.Crimson},
	{"models/halo2/spartan_Cobalt.mdl", Colors.Cobalt},
	{"models/halo2/spartan_Brown.mdl", Colors.Brown}
}

ClientOptions = {
	HUD = true
}

ServerOptions = {
	MaxBots = 4,
	-- Timelimit * seconds
	Seconds = 60,
	InactiveRoundTime = 15,
	DefaultGT = 11,
	RoundResetLength = 5,
	VotingLength = 25
}
