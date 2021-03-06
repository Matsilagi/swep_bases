

// Variables that are used on both client and server

SWEP.Author			= ""
SWEP.Contact		= ""
SWEP.Purpose		= ""
SWEP.Instructions	= ""

SWEP.ViewModelFOV	= 54
SWEP.ViewModelFlip	= false
SWEP.ViewModel		= "models/weapons/v_crossbow.mdl"
SWEP.WorldModel		= "models/weapons/w_crossbow.mdl"
SWEP.AnimPrefix		= "bow"
SWEP.HoldType		= "crossbow"

SWEP.EnableIdle			= false	

// Note: This is how it should have worked. The base weapon would set the category
// then all of the children would have inherited that.
// But a lot of SWEPS have based themselves on this base (probably not on purpose)
// So the category name is now defined in all of the child SWEPS.
SWEP.Category			= "Half-Life 2 LUA"
SWEP.m_bFiresUnderwater	= true

//BOLT_MODEL			= "models/crossbow_bolt.mdl"
BOLT_MODEL	= "models/weapons/w_missile_closed.mdl"

BOLT_AIR_VELOCITY	= 3500
BOLT_WATER_VELOCITY	= 1500
BOLT_SKIN_NORMAL	= 0
BOLT_SKIN_GLOW		= 1

CROSSBOW_GLOW_SPRITE	= "sprites/light_glow02_noz.vmt"
CROSSBOW_GLOW_SPRITE2	= "sprites/blueflare1.vmt"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= false

SWEP.Primary.Sound			= Sound( "Weapon_Crossbow.Single" )
SWEP.Primary.Reload			= Sound( "Weapon_Crossbow.Reload" )
SWEP.Primary.Special1		= Sound( "Weapon_Crossbow.BoltElectrify" )
SWEP.Primary.Special2		= Sound( "Weapon_Crossbow.BoltFly" )
SWEP.Primary.Damage			= 100
SWEP.Primary.NumShots		= 1
SWEP.Primary.NumAmmo		= SWEP.Primary.NumShots
SWEP.Primary.Cone			= vec3_origin
SWEP.Primary.ClipSize		= 1					// Size of a clip
SWEP.Primary.Delay			= 0.75
SWEP.Primary.DefaultClip	= 5					// Default number of bullets in a clip
SWEP.Primary.Automatic		= true				// Automatic/Semi Auto
SWEP.Primary.Ammo			= "XBowBolt"
SWEP.Primary.AmmoType		= "crossbow_bolt"

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
   Name: SWEP:Precache( )
   Desc: Use this function to precache stuff
---------------------------------------------------------*/
function SWEP:Precache()

	util.PrecacheSound( "Weapon_Crossbow.BoltHitBody" );
	util.PrecacheSound( "Weapon_Crossbow.BoltHitWorld" );
	util.PrecacheSound( "Weapon_Crossbow.BoltSkewer" );

	util.PrecacheModel( CROSSBOW_GLOW_SPRITE );
	util.PrecacheModel( CROSSBOW_GLOW_SPRITE2 );

	self.BaseClass:Precache();

end


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

	local pOwner = self.Owner;
	local pViewModel = self.Owner:GetViewModel();

	// Make sure we can shoot first
	if ( !self:CanPrimaryAttack() ) then return end

	if ( self.m_bInZoom && IsMultiplayer() ) then
//		self:FireSniperBolt();
		self:FireBolt();
	else
		self:FireBolt();
	end

	// Signal a reload
	self.m_bMustReload = true;
	
	self:IdleStuff()

end


/*---------------------------------------------------------
   Name: SWEP:SecondaryAttack( )
   Desc: +attack2 has been pressed
---------------------------------------------------------*/
function SWEP:SecondaryAttack()

	// Make sure we can shoot first
	if ( !self:CanSecondaryAttack() ) then return end

	self:ToggleZoom();

end

/*---------------------------------------------------------
   Name: SWEP:Reload( )
   Desc: Reload is being pressed
---------------------------------------------------------*/
function SWEP:Reload()

	local pOwner = self.Owner;
	local pViewModel = self.Owner:GetViewModel()

	if ( self.Weapon:DefaultReload( ACT_VM_RELOAD ) ) then
		timer.Simple(1, function() pViewModel:SetSkin( BOLT_SKIN_GLOW ) self:CrossbowLoad() end)
		timer.Simple(0.95, function()self.Owner:EmitSound(self.Primary.Special1)  end)
		self.m_bMustReload = false;
		return true;
	end

	self:IdleStuff()

	return false;

end

//-----------------------------------------------------------------------------
// Purpose:
//-----------------------------------------------------------------------------
function SWEP:CheckZoomToggle()

	local pPlayer = self.Owner;

	if ( pPlayer:KeyPressed( IN_ATTACK2 ) ) then
		self:ToggleZoom();
	end

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

	// Disallow zoom toggling
	// self:CheckZoomToggle();

	if ( self.m_bMustReload ) then
		self:Reload();
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

//-----------------------------------------------------------------------------
// Purpose:
//-----------------------------------------------------------------------------
function SWEP:FireBolt()

	if ( self.Weapon:Clip1() <= 0 && self.Primary.ClipSize > -1 ) then
		if ( self:Ammo1() > 0 ) then
			self:Reload();
		else
			self.Weapon:SetNextPrimaryFire( 0.15 );
		end

		return;
	end

	local pOwner = self.Owner;
	local pViewModel = self.Owner:GetViewModel();

	if ( pOwner == NULL ) then
		return;
	end

if ( !CLIENT ) then
	local vecAiming		= pOwner:GetAimVector();
	local vecSrc		= pOwner:GetShootPos();

	local angAiming;
	angAiming = vecAiming:Angle();

	local pBolt = ents.Create( self.Primary.AmmoType );
	pBolt:SetPos( vecSrc );
	pBolt:SetAngles( angAiming );
	pBolt.m_iDamage = self.Primary.Damage;
	pBolt:SetOwner( pOwner );
	pBolt:Spawn()

	if ( pOwner:WaterLevel() == 3 ) then
		pBolt:SetVelocity( vecAiming * BOLT_WATER_VELOCITY );
	else
		pBolt:SetVelocity( vecAiming * BOLT_AIR_VELOCITY );
	end

end

	self:TakePrimaryAmmo( self.Primary.NumAmmo );

	if ( !pOwner:IsNPC() ) then
		pOwner:ViewPunch( Angle( -2, 0, 0 ) );
	end

	self.Weapon:EmitSound( self.Primary.Sound );
	self.Owner:EmitSound( self.Primary.Special2 );

	self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK );

	self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay );
	self.Weapon:SetNextSecondaryFire( CurTime() + self.Primary.Delay );

	// self:DoLoadEffect();
	// self:SetChargerState( CHARGER_STATE_DISCHARGE );
	
	pViewModel:SetSkin( BOLT_SKIN_NORMAL );
	
	self:CrossbowLoad()
	
	self:IdleStuff()

end

/*---------------------------------------------------------
   Name: SWEP:Holster( weapon_to_swap_to )
   Desc: Weapon wants to holster
   RetV: Return true to allow the weapon to holster
---------------------------------------------------------*/
function SWEP:Holster( wep )

	if ( self.m_bInZoom ) then
		self:ToggleZoom();
	end

	// self:SetChargerState( CHARGER_STATE_OFF );

	return self.BaseClass:Holster( wep );

end

/*---------------------------------------------------------
   Name: SWEP:Deploy( )
   Desc: Whip it out
---------------------------------------------------------*/
function SWEP:Deploy()

	local pOwner = self.Owner;
	local pViewModel = self.Owner:GetViewModel();

	if ( self.Weapon:Clip1() <= 0 ) then
		self.Weapon:SendWeaponAnim( ACT_CROSSBOW_DRAW_UNLOADED );
		return self:SetDeploySpeed( self.Weapon:SequenceDuration() );
	end

	self:IdleStuff()
	pViewModel:SetSkin( BOLT_SKIN_GLOW );

	self.Weapon:SendWeaponAnim( ACT_VM_DRAW );
	return self:SetDeploySpeed( self.Weapon:SequenceDuration() ); 

end


//-----------------------------------------------------------------------------
// Purpose:
//-----------------------------------------------------------------------------
function SWEP:ToggleZoom()

	local pPlayer = self.Owner;

	if ( pPlayer == NULL ) then
		return;
	end

if ( !CLIENT ) then

	if ( self.m_bInZoom ) then
		pPlayer:SetCanZoom( true )
		pPlayer:SetFOV( 0, 0.2 )
		self.m_bInZoom = false;
	else
		pPlayer:SetCanZoom( false )
		pPlayer:SetFOV( 20, 0.1 )
		self.m_bInZoom = true;
	end
end

end

BOLT_TIP_ATTACHMENT	= 2

//-----------------------------------------------------------------------------
// Purpose:
// Input  : skinNum -
//-----------------------------------------------------------------------------
function SWEP:SetSkin( skinNum )

	local pOwner = self.Owner;

	if ( pOwner == NULL ) then
		return;
	end

	local pViewModel = pOwner:GetViewModel();

	if ( pViewModel == NULL ) then
		return;
	end

	pViewModel:SetSkin( skinNum );

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
	return true
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

function SWEP:CrossbowLoad()
local pOwner = self.Owner;
local pViewModel = pOwner:GetViewModel()
local spark = pViewModel:LookupAttachment( "spark" )
local effectdata = EffectData()
effectdata:SetEntity( pViewModel )
effectdata:SetAttachment( spark ) // not sure if we need a start and origin (endpoint) for this effect, but whatever
effectdata:SetScale( 1 )
util.Effect( "CrossbowLoad", effectdata )
end