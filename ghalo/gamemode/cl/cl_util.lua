
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

-- http://lua-users.org/wiki/SimpleRound
function round(num, idp)
  local mult = 10^(idp or 0)
  return math.floor(num * mult + 0.5) / mult
end

function GetRank(xp)
	print("XP: " .. xp)
	return string.len(tostring(xp)) - 1
end

function GetProgress(xp)
	if xp == 0 then
		xp = 1
	end

	local equ = (10 ^ (GetRank(xp)))

	local tempa = xp - equ
	local tempb = (10 ^ (GetRank(xp) + 1)) - equ
	print("Tempa:".. tempa)
	print("Tempa:".. tempb)
	return tempa / tempb * 100
end
