
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self.team = nil
	self.owner = nil
	self.name = nil
end

function ENT:AltModel(mod, notSolid, noCollide)
	print("mod: " .. mod)
	self:SetModel(mod)
	self:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,
	self:SetMoveType( MOVETYPE_VPHYSICS )   -- after all, gmod is a physics
	self:SetSolid( SOLID_VPHYSICS )         -- Toolbox

	if notSolid or noCollide then
		if !nocollide then
			self:SetTrigger(true)
		end
		self:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
	end
 
    local phys = self:GetPhysicsObject()

	if (phys:IsValid()) then
		phys:Wake()
	end
end

function ENT:Touch(ent)
	if self.team and ent and IsValid(ent) and ent:IsPlayer() then
		CurGT.OnTouch(self, ent)
	end
end

function ENT:Think()
	if self.owner then
		local temppos = self.owner:GetPos()
		local tempang = self.owner:GetAngles()
		local pos = temppos
		-- entModel:GetPhysicsObject():EnableMotion( true )

		local angle = tempang.y

		if angle < 0 then
			angle = -angle
			angle = 360 - angle
		end


		angle = angle * math.pi / 180

		local r = 15

		local cx = math.cos(angle) * r * 3
		local cy = math.sin(angle) * r * 3

		self:SetPos(Vector(pos.x + cx, pos.y + cy, self.owner:GetPos().z + 20))
		self:GetPhysicsObject():EnableMotion( false )
	end
end

function ENT:SetTeamName(name)
	print("=====+ Networking Name: " .. name)
	self.name = name
	self:SetNWString("name", name)
end
