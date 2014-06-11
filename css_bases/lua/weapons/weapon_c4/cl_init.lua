include("shared.lua")

SWEP.Ghost 				= NULL

language.Add("ammo_c4", "C4 Explosive")	

/*---------------------------------------------------------
   Name: SWEP:Think()
   Desc: Called every frame.
---------------------------------------------------------*/
function SWEP:Think()
	

	if self.Owner ~= LocalPlayer() then return end
	if SERVER then
	if not self.Ghost:IsValid( ) then
	//	self.Ghost = ents.Create("prop_physics")
	//	self.Ghost:SetModel("models/weapons/w_c4_planted.mdl")
	//	self.Ghost:SetOwner(self.Owner)
	end
	end
	
	if not self.Ghost:IsValid() then return end
	
	local tr = {}
	tr.start = self.Owner:GetShootPos()
	tr.endpos = self.Owner:GetShootPos() + 100 * self.Owner:GetAimVector()
	tr.filter = {self.Ghost, self.Owner}
	local trace = util.TraceLine(tr)	
	
	if trace.Hit then
		self.Ghost:SetPos(trace.HitPos + trace.HitNormal)
		trace.HitNormal.z = -trace.HitNormal.z
		self.Ghost:SetAngles(trace.HitNormal:Angle() - Angle(90, 180, 0))

		self.Ghost:SetColor(255, 255, 255, 100)
	else
		self.Ghost:SetColor(255, 255, 255, 0)
	end
end