
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

function ENT:Initialize()

util.PrecacheSound("ambient/explosions/explode_4.wav")

	self.Entity:SetModel("models/weapons/w_eq_fraggrenade_thrown.mdl")
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	self.Entity:DrawShadow( true )

self.FleshHit = { 
	Sound( "physics/flesh/flesh_impact_bullet1.wav" ),
	Sound( "physics/flesh/flesh_impact_bullet2.wav" ),
	Sound( "physics/flesh/flesh_impact_bullet3.wav" ) }
	

self.Entity:SetNetworkedString("Owner", "World")
	
	local phys = self.Entity:GetPhysicsObject()
	
	if (phys:IsValid()) then
		phys:Wake()
phys:SetMass( 3 )
	end
	
	self.timer = CurTime() + 2
end

function ENT:Think()
	if self.timer < CurTime() then
		local range = 512
		local damage = 0
		local pos = self.Entity:GetPos()
		
		//self:EmitSound( "weapons/hegrenade/explode".. math.random(3, 5) .. ".wav" )
		self.Entity:Remove()
self:SetPhysicsAttacker(owner)
		
		for i,pl in pairs(player.GetAll()) do
			local plp = pl:GetShootPos()
			
			if (plp - pos):Length() <= range then
				local trace = {}
					trace.start = plp
					trace.endpos = pos
					trace.filter = pl
					trace.mask = COLLISION_GROUP_PLAYER
				trace = util.TraceLine(trace)
				
				if trace.Fraction == 1 then
					pl:TakeDamage(trace.Fraction * damage)
				end
			end
		end
		local explo = ents.Create( "env_explosion" )
		explo:SetOwner( self.GrenadeOwner )
explo:SetPhysicsAttacker(owner)
		explo:SetPos( self.Entity:GetPos() )
		explo:SetKeyValue( "iMagnitude", "200" )
                explo:SetKeyValue("spawnflags",80)
                self:EmitSound( "weapons/hegrenade/explode".. math.random(3, 5) .. ".wav" )
		explo:Spawn()
		explo:Activate()
		explo:Fire( "Explode", "", 0 )

		local effectdata = EffectData()
	effectdata:SetOrigin( self.Entity:GetPos() )
	util.Effect( "HelicopterMegaBomb", effectdata )	 -- Big flame

local shake = ents.Create( "env_shake" )
self:EmitSound( "ambient/explosions/explode_4.wav" )
		shake:SetOwner( self.Owner )
		shake:SetPos( self.Entity:GetPos() )
		shake:SetKeyValue( "amplitude", "3500" )	-- Power of the shake
		shake:SetKeyValue( "radius", "900" )	-- Radius of the shake
		shake:SetKeyValue( "duration", "3" )	-- Time of shake
		shake:SetKeyValue( "frequency", "255" )	-- How har should the screenshake be
		shake:SetKeyValue( "spawnflags", "4" )	-- Spawnflags( In Air )
		shake:Spawn()
		shake:Activate()
		shake:Fire( "StartShake", "", 0 )
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
