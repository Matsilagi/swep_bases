
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

function ENT:Initialize()

	self.Entity:SetModel("models/weapons/w_eq_smokegrenade_thrown.mdl")
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	self.Entity:DrawShadow( false )
	
	local phys = self.Entity:GetPhysicsObject()
	
	if (phys:IsValid()) then
		phys:Wake()
phys:SetMass( 3 )
	end
	
	self.timer = CurTime() + 3
end

local exp
function ENT:Think()
	if self.timer < CurTime() then
		local pos = self.Entity:GetPos()
		
		self.Entity:EmitSound(Sound("BaseSmokeEffect.Sound"))
		
local exp = ents.Create( "env_ar2explosion" )

		exp:SetPos(pos)
		exp:Spawn()
		exp:Activate()
		exp:Fire( "Explode", "", 0 )

		exp = ents.Create("env_smoketrail")
			exp:SetKeyValue("startsize","100000")
			exp:SetKeyValue("endsize","130")
			exp:SetKeyValue("spawnradius","250")
			exp:SetKeyValue("minspeed","0.1")
			exp:SetKeyValue("maxspeed","4")
			exp:SetKeyValue("startcolor",self.smokecolor or "200 200 200 200")
			exp:SetKeyValue("endcolor",self.smokecolor or "200 200 200")
			exp:SetKeyValue("opacity","1.5")
			exp:SetKeyValue("spawnrate","60")
			exp:SetKeyValue("lifetime","7")
			exp:SetPos(pos)
			exp:SetParent(self.Entity)
		exp:Spawn()
		exp:Fire("kill","",20)
		self.Entity:Fire("kill","",20)

		self.timer = CurTime() + 25
	end
end

function ENT:KeyValue( key, value )
	if (key == "smokecolor") then
		self.smokecolor = value
	end
end

/*---------------------------------------------------------
   Name: OnTakeDamage
   Desc: Entity takes damage
---------------------------------------------------------*/
function ENT:OnTakeDamage( dmginfo )

/*
	Msg( tostring(dmginfo) .. "\n" )
	Msg( "Inflictor:\t" .. tostring(dmginfo:GetInflictor()) .. "\n" )
	Msg( "Attacker:\t" .. tostring(dmginfo:GetAttacker()) .. "\n" )
	Msg( "Damage:\t" .. tostring(dmginfo:GetDamage()) .. "\n" )
	Msg( "Base Damage:\t" .. tostring(dmginfo:GetBaseDamage()) .. "\n" )
	Msg( "Force:\t" .. tostring(dmginfo:GetDamageForce()) .. "\n" )
	Msg( "Position:\t" .. tostring(dmginfo:GetDamagePosition()) .. "\n" )
	Msg( "Reported Pos:\t" .. tostring(dmginfo:GetReportedPosition()) .. "\n" )	// ??
*/

end


/*---------------------------------------------------------
   Name: Use
---------------------------------------------------------*/
function ENT:Use( activator, caller, type, value )
end


/*---------------------------------------------------------
   Name: StartTouch
---------------------------------------------------------*/
function ENT:StartTouch( entity )
end


/*---------------------------------------------------------
   Name: EndTouch
---------------------------------------------------------*/
function ENT:EndTouch( entity )
end


/*---------------------------------------------------------
   Name: Touch
---------------------------------------------------------*/
function ENT:Touch( entity )
end
