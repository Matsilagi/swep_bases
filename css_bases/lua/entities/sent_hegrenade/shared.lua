
//ENT.Base = "base_entity"
ENT.Type = "anim"

ENT.PrintName		= "grenade"
ENT.Author			= ""
ENT.Contact			= ""
ENT.Purpose			= nil
ENT.Instructions	= nil


/*---------------------------------------------------------
   Name: OnRemove
   Desc: Called just before entity is deleted
---------------------------------------------------------*/
function ENT:OnRemove()
end

function ENT:PhysicsUpdate()
end

function ENT:PhysicsCollide(data,phys)

local Ent = data.HitEntity

if (Ent:IsPlayer() || Ent:IsNPC() || Ent:GetClass() == "prop_ragdoll") then 
			local effectdata = EffectData()
			effectdata:SetStart( data.HitPos )
			effectdata:SetOrigin( data.HitPos )
			effectdata:SetScale( 1 )
			util.Effect( "BloodImpact", effectdata )

Ent:TakeDamage( 2, self:GetOwner() )

			self:EmitSound( "physics/flesh/flesh_impact_bullet".. math.random(1, 3) .. ".wav" )
		end

	if data.Speed > 50 then
		self.Entity:EmitSound(Sound("HEGrenade.Bounce"))
	end
	
	local impulse = -data.Speed * data.HitNormal * .4 + (data.OurOldVelocity * -.6)
	phys:ApplyForceCenter(impulse)
end
