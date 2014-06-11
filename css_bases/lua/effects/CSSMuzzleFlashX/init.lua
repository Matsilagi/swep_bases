

//Based on Teta_Bonita's muzzle flash effect.

function EFFECT:Init(data)
	
	self.WeaponEnt = data:GetEntity()
	self.Attachment = data:GetAttachment()
	
	self.Position = self:GetTracerShootPos(data:GetOrigin(), self.WeaponEnt, self.Attachment)
	self.Forward = data:GetNormal()
	self.Angle = self.Forward:Angle()
	self.Right = self.Angle:Right()
	
	local AddVel = self.WeaponEnt:GetOwner():GetVelocity()
	
	local emitter = ParticleEmitter(self.Position)

	local particle = emitter:Add("effects/muzzleflashX", self.Position)
	//particle:SetVelocity(60*self.Right + AddVel)
	particle:SetVelocity(AddVel)
	//particle:SetGravity(AddVel)
	particle:SetDieTime(0.05)
	particle:SetStartAlpha(255)
	particle:SetStartSize(7)
	particle:SetEndSize(7)
	particle:SetRoll(math.Rand(0,0.4))
	particle:SetRollDelta(math.Rand(-1,1))
	particle:SetColor(255,255,255)	

	emitter:Finish()

end


function EFFECT:Think()

	return false
	
end


function EFFECT:Render()

	
end



