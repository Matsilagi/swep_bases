

// Variables that are used on both client and server

SWEP.Author			= ""
SWEP.Contact		= ""
SWEP.Purpose		= ""
SWEP.Instructions	= ""

SWEP.ViewModelFOV	= 54
SWEP.ViewModelFlip	= false
SWEP.ViewModel		= "models/weapons/v_crowbar.mdl"
SWEP.WorldModel		= "models/weapons/w_crowbar.mdl"
SWEP.AnimPrefix		= "crowbar"
SWEP.HoldType		= "melee"

SWEP.EnableIdle			= false

// Note: This is how it should have worked. The base weapon would set the category
// then all of the children would have inherited that.
// But a lot of SWEPS have based themselves on this base (probably not on purpose)
// So the category name is now defined in all of the child SWEPS.
SWEP.Category			= "Half-Life 2 LUA"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= false

CROWBAR_RANGE	= 75.0
CROWBAR_REFIRE	= 0.4

SWEP.Primary.Sound			= Sound( "Weapon_Crowbar.Single" )
SWEP.Primary.Hit			= Sound( "Weapon_Crowbar.Single" )
SWEP.Primary.Range			= CROWBAR_RANGE
SWEP.Primary.Damage			= 25.0
SWEP.Primary.DamageType		= DMG_CLUB
SWEP.Primary.Force			= 0.75
SWEP.Primary.ClipSize		= -1				// Size of a clip
SWEP.Primary.Delay			= CROWBAR_REFIRE
SWEP.Primary.DefaultClip	= -1				// Default number of bullets in a clip
SWEP.Primary.Automatic		= true				// Automatic/Semi Auto
SWEP.Primary.Ammo			= "None"

SWEP.Secondary.ClipSize		= -1				// Size of a clip
SWEP.Secondary.DefaultClip	= -1				// Default number of bullets in a clip
SWEP.Secondary.Automatic	= false				// Automatic/Semi Auto
SWEP.Secondary.Ammo			= "None"

SWEP.BobScale = 0
SWEP.SwayScale = 0

BobTime = 0
BobTimeLast = CurTime()

SwayAng = nil
SwayOldAng = Angle()
SwayDelta = Angle()

/*---------------------------------------------------------
   Name: SWEP:Initialize( )
   Desc: Called when the weapon is first loaded
---------------------------------------------------------*/
function SWEP:Initialize()

	if ( SERVER ) then
		self:SetNPCMinBurst( 0 )
		self:SetNPCMaxBurst( 0 )
		self:SetNPCFireRate( self.Primary.Delay )
	end

	self:SetWeaponHoldType( self.HoldType )

end

function SWEP:Think()

	if CLIENT and self.EnableIdle then return end
	if self.idledelay and CurTime() > self.idledelay then
		self.idledelay = nil
		self:SendWeaponAnim(ACT_VM_IDLE)
	end
end


/*---------------------------------------------------------
   Name: SWEP:PrimaryAttack( )
   Desc: +attack1 has been pressed
---------------------------------------------------------*/
function SWEP:PrimaryAttack()

	// Only the player fires this way so we can cast
	local pPlayer		= self.Owner;

	if ( !pPlayer ) then
		return;
	end

	// Make sure we can swing first
	if ( !self:CanPrimaryAttack() ) then return end

	local vecSrc		= pPlayer:GetShootPos();
	local vecDirection	= pPlayer:GetAimVector();

	local trace			= {}
		trace.start		= vecSrc
		trace.endpos	= vecSrc + ( vecDirection * self:GetRange() )
		trace.filter	= pPlayer

	local traceHit		= util.TraceLine( trace )

	if ( traceHit.Hit ) then

		self.Weapon:EmitSound( self.Primary.Hit );

		self.Weapon:SendWeaponAnim( ACT_VM_HITCENTER );
		self:IdleStuff()
		pPlayer:SetAnimation( PLAYER_ATTACK1 );

		self.Weapon:SetNextPrimaryFire( CurTime() + self:GetFireRate() );
		self.Weapon:SetNextSecondaryFire( CurTime() + self.Weapon:SequenceDuration() );

		self:Hit( traceHit, pPlayer );

		return

	end

	self.Weapon:EmitSound( self.Primary.Sound );

	self.Weapon:SendWeaponAnim( ACT_VM_MISSCENTER );
	self:IdleStuff()
	pPlayer:SetAnimation( PLAYER_ATTACK1 );

	self.Weapon:SetNextPrimaryFire( CurTime() + self:GetFireRate() );
	self.Weapon:SetNextSecondaryFire( CurTime() + self.Weapon:SequenceDuration() );

	self:Swing( traceHit, pPlayer );

	return

end


/*---------------------------------------------------------
   Name: SWEP:SecondaryAttack( )
   Desc: +attack2 has been pressed
---------------------------------------------------------*/
function SWEP:SecondaryAttack()
	return false
end

/*---------------------------------------------------------
   Name: SWEP:Reload( )
   Desc: Reload is being pressed
---------------------------------------------------------*/
function SWEP:Reload()
	return false
end

//-----------------------------------------------------------------------------
// Purpose: Get the damage amount for the animation we're doing
// Input  : hitActivity - currently played activity
// Output : Damage amount
//-----------------------------------------------------------------------------
function SWEP:GetDamageForActivity( hitActivity )
	return self.Primary.Damage;
end

//-----------------------------------------------------------------------------
// Purpose: Add in a view kick for this weapon
//-----------------------------------------------------------------------------
function SWEP:AddViewKick()

	local pPlayer  = self:GetOwner();

	if ( pPlayer == NULL ) then
		return;
	end

	if ( pPlayer:IsNPC() ) then
		return;
	end

	local punchAng = Angle( 0, 0 ,0 );

	punchAng.pitch = math.Rand( 1.0, 2.0 );
	punchAng.yaw   = math.Rand( -2.0, -1.0 );
	punchAng.roll  = 0.0;

	pPlayer:ViewPunch( punchAng );

end


/*---------------------------------------------------------
   Name: SWEP:Deploy( )
   Desc: Whip it out
---------------------------------------------------------*/
function SWEP:Deploy()

	self.Weapon:SendWeaponAnim( ACT_VM_DRAW )
	self:SetDeploySpeed( self.Weapon:SequenceDuration() )
	self:IdleStuff()

	return true

end


/*---------------------------------------------------------
   Name: SWEP:Hit( )
   Desc: A convenience function to trace impacts
---------------------------------------------------------*/
function SWEP:Hit( traceHit, pPlayer )

	local vecSrc = pPlayer:GetShootPos();

	util.ImpactTrace( traceHit, pPlayer );

	if ( SERVER ) then
		pPlayer:TraceHullAttack( vecSrc, traceHit.HitPos, Vector( -16, -16, -16 ), Vector( 36, 36, 36 ), self:GetDamageForActivity(), self.Primary.DamageType, self.Primary.Force );
	end
	
	//Had to use an approx. value because i dont know how to work with the punchView stuff of C++ code
	pPlayer:ViewPunch( Angle( -1.2, math.Rand( -2, 1 ), 0 ) );

end


/*---------------------------------------------------------
   Name: SWEP:Swing( )
   Desc: A convenience function to trace impacts
---------------------------------------------------------*/
function SWEP:Swing( traceHit, pPlayer )
end


/*---------------------------------------------------------
   Name: SWEP:CanPrimaryAttack( )
   Desc: Helper function for checking for no ammo
---------------------------------------------------------*/
function SWEP:CanPrimaryAttack()
	return true
end


/*---------------------------------------------------------
   Name: SWEP:CanSecondaryAttack( )
   Desc: Helper function for checking for no ammo
---------------------------------------------------------*/
function SWEP:CanSecondaryAttack()
	return false
end


/*---------------------------------------------------------
   Name: SetDeploySpeed
   Desc: Sets the weapon deploy speed.
		 This value needs to match on client and server.
---------------------------------------------------------*/
function SWEP:SetDeploySpeed( speed )

	self.m_WeaponDeploySpeed = tonumber( speed / GetConVarNumber( "phys_timescale" ) )

	self.Weapon:SetNextPrimaryFire( CurTime() + speed )
	self.Weapon:SetNextSecondaryFire( CurTime() + speed )

end



//-----------------------------------------------------------------------------
// Purpose:
//-----------------------------------------------------------------------------
function SWEP:Drop( vecVelocity )
if ( !CLIENT ) then
	self:Remove();
end
end

function SWEP:GetRange()
	return	self.Primary.Range;
end

function SWEP:GetFireRate()
	return	self.Primary.Delay;
end

/*---------------------------------------------------------
   Name: IdleStuff
   Desc: Helpers for the Idle function.
---------------------------------------------------------*/
function SWEP:IdleStuff()
	if self.EnableIdle then return end
	self.idledelay = CurTime() +self:SequenceDuration()
end

/*---------------------------------------------------------
   Name: CalcViewModelView
   Desc: Overwrites the default GMod v_model system.
---------------------------------------------------------*/
function SWEP:CalcViewModelView(ViewModel, oldPos, oldAng, pos, ang)

	local pPlayer = self.Owner
	local Speed = pPlayer:GetVelocity():Length2D()
	local CT = CurTime()
	local FT = FrameTime()
	local BobCycleMultiplier = Speed / pPlayer:GetRunSpeed()

	BobCycleMultiplier = (BobCycleMultiplier > 1 and math.min(1 + ((BobCycleMultiplier - 1) * 0.2), 5) or BobCycleMultiplier)
	BobTime = BobTime + (CT - BobTimeLast) * (Speed > 0 and (Speed / pPlayer:GetWalkSpeed()) or 0)
	BobTimeLast = CT
	local BobCycleX = math.sin(BobTime * 0.5 % 1 * math.pi * 2) * BobCycleMultiplier
	local BobCycleY = math.sin(BobTime % 1 * math.pi * 2) * BobCycleMultiplier

	oldPos = oldPos + oldAng:Right() * (BobCycleX * 1.5)
	oldPos = oldPos
	oldPos = oldPos + oldAng:Up() * BobCycleY/2

	SwayAng = oldAng - SwayOldAng
	if math.abs(oldAng.y - SwayOldAng.y) > 180 then
		SwayAng.y = (360 - math.abs(oldAng.y - SwayOldAng.y)) * math.abs(oldAng.y - SwayOldAng.y) / (SwayOldAng.y - oldAng.y)
	else
		SwayAng.y = oldAng.y - SwayOldAng.y
	end
	SwayOldAng.p = oldAng.p
	SwayOldAng.y = oldAng.y
	SwayAng.p = math.Clamp(SwayAng.p, -3, 3)
	SwayAng.y = math.Clamp(SwayAng.y, -3, 3)
	SwayDelta = LerpAngle(math.Clamp(FrameTime() * 5, 0, 1), SwayDelta, SwayAng)
	
	return oldPos + oldAng:Up() * SwayDelta.p + oldAng:Right() * SwayDelta.y + oldAng:Up() * oldAng.p / 90 * 2, oldAng
end