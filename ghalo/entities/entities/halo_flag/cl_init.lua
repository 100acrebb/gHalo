
include("shared.lua")

function ENT:Draw()
	self.Entity:DrawModel()

	local name = self:GetNWString("name", name)

	if name and string.len(name) > 0 then
		AddWorldTip(nil, name, 0.5, self:GetPos(), self)
	end
end
