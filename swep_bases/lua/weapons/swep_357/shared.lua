

// Variables that are used on both client and server

SWEP.Author			= ""
SWEP.Contact		= ""
SWEP.Purpose		= ""
SWEP.Instructions	= ""

SWEP.ViewModelFOV	= 54
SWEP.ViewModelFlip	= false
SWEP.ViewModel		= "models/weapons/v_357.mdl"
SWEP.WorldModel		= "models/weapons/w_357.mdl"
SWEP.AnimPrefix		= "python"
SWEP.HoldType		= "pistol"
SWEP.EnableIdle				= false	

// Note: This is how it should have worked. The base weapon would set the category
// then all of the children would have inherited that.
// But a lot of SWEPS have based themselves on this base (probably not on purpose)
// So the category name is now defined in all of the child SWEPS.
SWEP.Category			= "Half-Life 2 LUA"
SWEP.m_bFiresUnderwater	= false

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= false

SWEP.Primary.Empty			= Sound( "Weapon_Pistol.Empty" )
SWEP.Primary.Sound			= Sound( "Weapon_357.Single" )
SWEP.Primary.Damage			= 75
SWEP.Primary.NumShots		= 1
SWEP.Primary.NumAmmo		= SWEP.Primary.NumShots
SWEP.Primary.Cone			= vec3_origin
SWEP.Primary.ClipSize		= 6					// Size of a clip
SWEP.Primary.Delay			= 0.75
SWEP.Primary.DefaultClip	= 6					// Default number of bullets in a clip
SWEP.Primary.Automatic		= true				// Automatic/Semi Auto
SWEP.Primary.Ammo			= "357"
SWEP.Primary.Tracer			= 4
SWEP.Primary.TracerName		= "Tracer"

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


/*---------------------------------------------------------
   Name: SWEP:PrimaryAttack( )
   Desc: +attack1 has been pressed
---------------------------------------------------------*/
function SWEP:PrimaryAttack()

	// Only the player fires this way so we can cast
	local pPlayer = self.Owner;

	if ( !pPlayer ) then
		return;
	end

	// Make sure we can shoot first
	if ( !self:CanPrimaryAttack() ) then return end

	if ( self.Weapon:Clip1() <= 0 && self.Primary.ClipSize > -1 ) then
		if ( self:Ammo1() > 0 ) then
			self.Weapon:EmitSound( self.Primary.Empty );
			self:Reload();
		else
			self.Weapon:EmitSound( self.Primary.Empty );
			self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay );
		end

		return;
	end

	if ( self.m_bIsUnderwater && !self.m_bFiresUnderwater ) then
		self.Weapon:EmitSound( self.Primary.Empty );
		self.Weapon:SetNextPrimaryFire( CurTime() + 0.2 );

		return;
	end

	self.Weapon:EmitSound( self.Primary.Sound );
	pPlayer:MuzzleFlash();

	self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK );
	pPlayer:SetAnimation( PLAYER_ATTACK1 );

	self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay );
	self.Weapon:SetNextSecondaryFire( CurTime() + self.Primary.Delay );

	self:TakePrimaryAmmo( self.Primary.NumAmmo );

	self:ShootBullet( self.Primary.Damage, self.Primary.NumShots, self.Primary.Cone );

	//Disorient the player
	local angles = pPlayer:EyeAngles();

	angles.pitch = angles.pitch + math.random( -1, 1 );
	angles.yaw   = angles.yaw   + math.random( -1, 1 );
	angles.roll  = 0;

	if ( pPlayer:IsNPC() ) then return end

if ( !CLIENT ) then
	pPlayer:SetEyeAngles( angles );
end

	pPlayer:ViewPunch( Angle( -8, math.Rand( -2, 2 ), 0 ) );
	self:IdleStuff()

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
	self.Weapon:DefaultReload( ACT_VM_RELOAD );
	self:IdleStuff()
	end


/*---------------------------------------------------------
   Name: SWEP:PreThink( )
   Desc: Called before every frame
---------------------------------------------------------*/
function SWEP:PreThink()
end


/*---------------------------------------------------------
   Name: SWEP:Think( )
   Desc: Called every frame
---------------------------------------------------------*/
function SWEP:Think()

	if CLIENT and self.EnableIdle then return end
	if self.idledelay and CurTime() > self.idledelay then
		self.idledelay = nil
		self:SendWeaponAnim(ACT_VM_IDLE)
	end

	local pPlayer = self.Owner;

	if ( !pPlayer ) then
		return;
	end

	self:PreThink();

	if ( pPlayer:WaterLevel() >= 3 ) then
		self.m_bIsUnderwater = true;
	else
		self.m_bIsUnderwater = false;
	end

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
   Name: SWEP:ShootBullet( )
   Desc: A convenience function to shoot bullets
---------------------------------------------------------*/
function SWEP:ShootBullet( damage, num_bullets, aimcone )

	// Only the player fires this way so we can cast
	local pPlayer = self.Owner;

	if ( !pPlayer ) then
		return;
	end

	local vecSrc		= pPlayer:GetShootPos();
	local vecAiming		= pPlayer:GetAimVector();

	local info = { Num = num_bullets, Src = vecSrc, Dir = vecAiming, Spread = aimcone, Tracer = self.Primary.Tracer, Damage = damage };
	info.Attacker = pPlayer;
	info.TracerName = self.Primary.TracerName;

	info.Owner = self.Owner
	info.Weapon = self.Weapon

	info.ShootCallback = self.ShootCallback;

	info.Callback = function( attacker, trace, dmginfo )
		return info:ShootCallback( attacker, trace, dmginfo );
	end

	// Fire the bullets, and force the first shot to be perfectly accuracy
	pPlayer:FireBullets( info );

end


/*---------------------------------------------------------
   Name: SWEP:ShootCallback( )
   Desc: A convenience function to shoot bullets
---------------------------------------------------------*/
function SWEP:ShootCallback( attacker, trace, dmginfo )
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