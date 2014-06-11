

// Variables that are used on both client and server

SWEP.Author				= ""
SWEP.Contact			= ""
SWEP.Purpose			= ""
SWEP.Instructions		= ""

SWEP.ViewModelFOV		= 54
SWEP.ViewModelFlip		= true
SWEP.CSMuzzleFlashes	= true
SWEP.ViewModel			= "models/weapons/v_pist_glock18.mdl"
SWEP.WorldModel			= "models/weapons/w_pist_glock18.mdl"
SWEP.AnimPrefix			= "anim"
SWEP.HoldType			= "pistol"

// Note: This is how it should have worked. The base weapon would set the category
// then all of the children would have inherited that.
// But a lot of SWEPS have based themselves on this base (probably not on purpose)
// So the category name is now defined in all of the child SWEPS.
//SWEP.Category					= "Counter-Strike: Source"
SWEP.m_bInReload				= false;
SWEP.m_flAccuracyPenalty		= 0.0;
SWEP.m_fFireDuration			= 0.0;

SWEP.m_flLastAttackTime			= 0.0;

SWEP.Spawnable			= false
SWEP.AdminSpawnable		= false

SWEP.MaxPlayerSpeed			= 240
SWEP.WeaponPrice			= 400

// Weapon characteristics:
SWEP.Penetration			= 1
SWEP.Damage					= 28
SWEP.RangeModifier			= 0.81
SWEP.Bullets				= 1
SWEP.CycleTime				= 0.16
SWEP.MaxInaccuracy			= 1.5

SWEP.Primary.Empty			= Sound( "Default.ClipEmpty_Rifle" )
SWEP.Primary.Sound			= Sound( "Weapon_Glock.Single" )
SWEP.Primary.M4Sil			= Sound( "Weapon_M4A1.Silenced" )
SWEP.Primary.M4A1RISSil			= Sound( "Weapon_M4A1RIS.Silenced" )
SWEP.Primary.M4A1Sil			= Sound( "weapons/m4a1/m4a1-4.wav" )
SWEP.Primary.SCARLSil			= Sound( "Weapon_SCARL.SilFire" )
SWEP.Primary.NumAmmo		= SWEP.Bullets
SWEP.Primary.Cone			= VECTOR_CONE_6DEGREES
SWEP.Primary.ClipSize		= 20				// Size of a clip
SWEP.Primary.DefaultClip	= 20				// Default number of bullets in a clip
SWEP.Primary.Automatic		= false				// Automatic/Semi Auto
SWEP.Primary.Ammo			= BULLET_PLAYER_9MM

SWEP.Secondary.ClipSize		= -1				// Size of a clip
SWEP.Secondary.DefaultClip	= -1				// Default number of bullets in a clip
SWEP.Secondary.Automatic	= false				// Automatic/Semi Auto
SWEP.Secondary.Ammo			= "None"

SWEP.BurstMsg			= "Switched to burst."
SWEP.NormalMsg			= "Switched to semi-automatic."
SWEP.RifleNormalMsg			= "Switched to automatic."

SWEP.SwayScale = 1

PistolBurst = 0
Burst = 0
Zoom = 0
Silenced = 0
PistolSilenced = 0


function SWEP:GetBulletSpread()

	local cone;

	local ramp = RemapValClamped(	self.m_flAccuracyPenalty,
										0.0,
										self.MaxInaccuracy,
										0.0,
										1.0 );

		// We lerp from very accurate to inaccurate over time
	cone = LerpVector( ramp, VECTOR_CONE_1DEGREES, self.Primary.Cone );

	local fMaxSpeed = self.Owner:GetMaxSpeed()
	cone = cone * ( self.Owner:GetVelocity():Length() / fMaxSpeed + 1)

	if ( self.Owner:Crouching() && self.Owner:IsOnGround() ) then
		cone = cone / ( 1 + ramp )
	elseif ( !self.Owner:IsOnGround() ) then
		cone = cone * ( ramp * 10 )
	end
	
	if ( (self.Zoom == 1) or (self.Zoom == 2) ) then
	cone = cone / ( 1 + ramp )
	end

	return cone;

end

/*---------------------------------------------------------
   Name: SWEP:Initialize( )
   Desc: Called when the weapon is first loaded
---------------------------------------------------------*/
function SWEP:Initialize()


	if ( SERVER ) then
		self:SetWeaponHoldType( self.HoldType )
		self:SetNPCMinBurst( 1 )
		self:SetNPCMaxBurst( 3 )
		self:SetNPCFireRate( self.CycleTime )
	end

end


/*---------------------------------------------------------
   Name: SWEP:PrimaryAttack( )
   Desc: +attack1 has been pressed
---------------------------------------------------------*/
function SWEP:PrimaryAttack()

	if ((PistolBurst == 1))
	then
	self:Burst()
	else if ((Burst == 1)) then
	self:RifleBurst()
	else


	self.m_flLastAttackTime = CurTime();

	local pOwner = self.Owner;

	// Only the player fires this way so we can cast
	local pPlayer = self.Owner;
	if (!pPlayer) then
		return;
	end

	if ( self.Weapon:Clip1() <= 0 && self.Primary.ClipSize > -1 ) then
		if ( self:Ammo1() > 0 ) then
			self:Reload();
		else
			self.Weapon:EmitSound( self.Primary.Empty );

			self.Weapon:SetNextPrimaryFire( CurTime() + self.Weapon:SequenceDuration() );
			self.Weapon:SetNextSecondaryFire( CurTime() + self.Weapon:SequenceDuration() );
		end

		return;
	end

	// Abort here to handle burst and auto fire modes
	if ( (self.Primary.ClipSize > -1 && self.Weapon:Clip1() == 0) || ( self.Primary.ClipSize <= -1 && !pPlayer:GetAmmoCount(self.Primary.Ammo) ) ) then
		return;
	end

	pPlayer:MuzzleFlash();

	// To make the firing framerate independent, we may have to fire more than one bullet here on low-framerate systems,
	// especially if the weapon we're firing has a really fast rate of fire.
	local iBulletsToFire = 0;
	local fireRate = self.CycleTime;

	// MUST call sound before removing a round from the clip of a CHLMachineGun
	self.Weapon:EmitSound(self.Primary.Sound);
	self.Weapon:SetNextPrimaryFire( CurTime() + fireRate );
	self.Weapon:SetNextSecondaryFire( CurTime() + fireRate );
	iBulletsToFire = iBulletsToFire + self.Bullets;

	// Make sure we don't fire more than the amount in the clip, if this weapon uses clips
	if ( self.Primary.ClipSize > -1 ) then
		if ( iBulletsToFire > self.Weapon:Clip1() ) then
			iBulletsToFire = self.Weapon:Clip1();
		end
		self:TakePrimaryAmmo( self.Primary.NumAmmo );
	end

	self:CSShootBullet( self.Damage, iBulletsToFire, self:GetBulletSpread() );

	//Factor in the view kick
	if ( !pPlayer:IsNPC() ) then
		self:AddViewKick();
	end

	self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK );
	pPlayer:SetAnimation( PLAYER_ATTACK1 );

	// Add an accuracy penalty which can move past our maximum penalty time if we're really spastic
	self.m_flAccuracyPenalty = self.m_flAccuracyPenalty + self.RangeModifier;

end
end
end

function SWEP:Burst()
	self.m_flLastAttackTime = CurTime();

	local pOwner = self.Owner;

	// Only the player fires this way so we can cast
	local pPlayer = self.Owner;
	if (!pPlayer) then
		return;
	end

	if ( self.Weapon:Clip1() <= 0 && self.Primary.ClipSize > -1 ) then
		if ( self:Ammo1() > 0 ) then
			self:Reload();
		else
			self.Weapon:EmitSound( self.Primary.Empty );

			self.Weapon:SetNextPrimaryFire( CurTime() + self.Weapon:SequenceDuration() );
			self.Weapon:SetNextSecondaryFire( CurTime() + self.Weapon:SequenceDuration() );
		end

		return;
	end

	// Abort here to handle burst and auto fire modes
	if ( (self.Primary.ClipSize > -1 && self.Weapon:Clip1() == 0) || ( self.Primary.ClipSize <= -1 && !pPlayer:GetAmmoCount(self.Primary.Ammo) ) ) then
		return;
	end

	pPlayer:MuzzleFlash();

	// To make the firing framerate independent, we may have to fire more than one bullet here on low-framerate systems,
	// especially if the weapon we're firing has a really fast rate of fire.
	local iBulletsToFire = 0;
	local fireRate = self.CycleTime;

	// MUST call sound before removing a round from the clip of a CHLMachineGun
	self.Weapon:EmitSound(self.Primary.Sound);
	self.Weapon:SetNextPrimaryFire( CurTime() + fireRate );
	self.Weapon:SetNextSecondaryFire( CurTime() + fireRate );
	iBulletsToFire = iBulletsToFire + self.Bullets;

	// Make sure we don't fire more than the amount in the clip, if this weapon uses clips
	if ( self.Primary.ClipSize > -1 ) then
		if ( iBulletsToFire > self.Weapon:Clip1() ) then
			iBulletsToFire = self.Weapon:Clip1();
		end
		self:TakePrimaryAmmo( self.Primary.NumAmmo );
	end
	
	if ( self.Primary.ClipSize >= 3 ) then
	self:CSShootBullet( self.Primary.Damage, iBulletsToFire, self.Primary.Cone );
	timer.Create("FireBurstShot1" .. tostring(self.Owner),0.08,1,BurstFire,self,7,1,0.015)
	timer.Create("FireBurstShot2" .. tostring(self.Owner),0.16,1,BurstFire,self,7,1,0.015)
	self.Weapon:EmitSound( self.Primary.Sound )
	self.Weapon:SetNextSecondaryFire( CurTime() + 0.5 )
	self.Weapon:SetNextPrimaryFire( CurTime() + 0.5 )
	end

	self:CSShootBullet( self.Damage, iBulletsToFire, self:GetBulletSpread() );

	//Factor in the view kick
	if ( !pPlayer:IsNPC() ) then
		self:AddViewKick();
	end

	self.Weapon:SendWeaponAnim( ACT_VM_SECONDARYATTACK );
	pPlayer:SetAnimation( PLAYER_ATTACK1 );

	// Add an accuracy penalty which can move past our maximum penalty time if we're really spastic
	self.m_flAccuracyPenalty = self.m_flAccuracyPenalty + self.RangeModifier;
end

function SWEP:RifleBurst()
	self.m_flLastAttackTime = CurTime();

	local pOwner = self.Owner;

	// Only the player fires this way so we can cast
	local pPlayer = self.Owner;
	if (!pPlayer) then
		return;
	end

	if ( self.Weapon:Clip1() <= 0 && self.Primary.ClipSize > -1 ) then
		if ( self:Ammo1() > 0 ) then
			self:Reload();
		else
			self.Weapon:EmitSound( self.Primary.Empty );

			self.Weapon:SetNextPrimaryFire( CurTime() + self.Weapon:SequenceDuration() );
			self.Weapon:SetNextSecondaryFire( CurTime() + self.Weapon:SequenceDuration() );
		end

		return;
	end

	// Abort here to handle burst and auto fire modes
	if ( (self.Primary.ClipSize > -1 && self.Weapon:Clip1() == 0) || ( self.Primary.ClipSize <= -1 && !pPlayer:GetAmmoCount(self.Primary.Ammo) ) ) then
		return;
	end

	pPlayer:MuzzleFlash();

	// To make the firing framerate independent, we may have to fire more than one bullet here on low-framerate systems,
	// especially if the weapon we're firing has a really fast rate of fire.
	local iBulletsToFire = 0;
	local fireRate = self.CycleTime;

	// MUST call sound before removing a round from the clip of a CHLMachineGun
	self.Weapon:EmitSound(self.Primary.Sound);
	self.Weapon:SetNextPrimaryFire( CurTime() + fireRate );
	self.Weapon:SetNextSecondaryFire( CurTime() + fireRate );
	iBulletsToFire = iBulletsToFire + self.Bullets;

	// Make sure we don't fire more than the amount in the clip, if this weapon uses clips
	if ( self.Primary.ClipSize > -1 ) then
		if ( iBulletsToFire > self.Weapon:Clip1() ) then
			iBulletsToFire = self.Weapon:Clip1();
		end
		self:TakePrimaryAmmo( self.Primary.NumAmmo );
	end
	
	if ( self.Primary.ClipSize >= 3 ) then
	self:CSShootBullet( self.Primary.Damage, iBulletsToFire, self.Primary.Cone );
	timer.Create("FireBurstShot1" .. tostring(self.Owner),0.08,1,BurstFireRifle,self,7,1,0.015)
	timer.Create("FireBurstShot2" .. tostring(self.Owner),0.16,1,BurstFireRifle,self,7,1,0.015)
	self.Weapon:EmitSound( self.Primary.Sound )
	self.Weapon:SetNextSecondaryFire( CurTime() + 0.5 )
	self.Weapon:SetNextPrimaryFire( CurTime() + 0.5 )
	end

	self:CSShootBullet( self.Damage, iBulletsToFire, self:GetBulletSpread() );

	//Factor in the view kick
	if ( !pPlayer:IsNPC() ) then
		self:AddViewKick();
	end

	self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK );
	pPlayer:SetAnimation( PLAYER_ATTACK1 );

	// Add an accuracy penalty which can move past our maximum penalty time if we're really spastic
	self.m_flAccuracyPenalty = self.m_flAccuracyPenalty + self.RangeModifier;
end

function BurstFire( self, damage, number, accuracy)
	if ( !self:CanPrimaryAttack() ) then return end
	self:CSShootBullet( self.Damage, iBulletsToFire, self:GetBulletSpread() );
	self:TakePrimaryAmmo( self.Primary.NumAmmo );
	self.Weapon:SetNextSecondaryFire( CurTime() + 0.4 )
	self.Weapon:SetNextPrimaryFire( CurTime() + 0.4 )
	self.Weapon:SendWeaponAnim ( ACT_VM_SECONDARYATTACK )
	self.Weapon:EmitSound( self.Primary.Sound )
end

function BurstFireRifle( self, damage, number, accuracy)
	if ( !self:CanPrimaryAttack() ) then return end
	self:CSShootBullet( self.Damage, iBulletsToFire, self:GetBulletSpread() );
	self:TakePrimaryAmmo( self.Primary.NumAmmo );
	self.Weapon:SetNextSecondaryFire( CurTime() + 0.4 )
	self.Weapon:SetNextPrimaryFire( CurTime() + 0.4 )
	self.Weapon:SendWeaponAnim ( ACT_VM_PRIMARYATTACK )
	self.Weapon:EmitSound( self.Primary.Sound )
end

function SWEP:DrawHUD()
	if ( ( self.Weapon:GetNetworkedBool( "Zoomed"  ) ) ) then
		surface.SetDrawColor( 0, 0, 0, 255 )
		surface.DrawLine( 0, y, ScrW(), y )
		surface.DrawLine( x, 0, x, ScrH() )
		surface.SetTexture(surface.GetTextureID("weapons/scopes/scope"))
		surface.SetDrawColor( 255, 255, 255, 255 )
		surface.DrawTexturedRect( x - (ScrH() / 2), 0, ScrH(), ScrH() )
		surface.SetDrawColor( 0, 0, 0, 255 )
		surface.DrawRect(0, 0, x - (ScrH() / 2), ScrH() )
		surface.DrawRect(x + (ScrH() / 2), 0, ScrW() - (x + (ScrH() / 2)), ScrH() )
	end
end

function SWEP:SetZoomed( b )

	self.Weapon:SetNetworkedBool( "Zoomed", b )

end

function SWEP:AdjustMouseSensitivity()
	if Zoom == 0 then
		return -1
	end
	if Zoom == 1 then
		return 0.1
	end
	if Zoom == 2 then
		return 0.001
	end
end

//-----------------------------------------------------------------------------
// Purpose:
//-----------------------------------------------------------------------------
function SWEP:DoMachineGunKick( pPlayer, dampEasy, maxVerticleKickAngle, fireDurationTime, slideLimitTime )

	local	KICK_MIN_X			= 0.2	//Degrees
	local	KICK_MIN_Y			= 0.2	//Degrees
	local	KICK_MIN_Z			= 0.1	//Degrees

	local vecScratch = Angle( 0, 0, 0 );

	//Find how far into our accuracy degradation we are
	local duration;
	if ( fireDurationTime > slideLimitTime ) then
		duration	= slideLimitTime
	else
		duration	= fireDurationTime;
	end
	local kickPerc = duration / slideLimitTime;

	// do this to get a hard discontinuity, clear out anything under 10 degrees punch
	pPlayer:ViewPunchReset( 10 );

	//Apply this to the view angles as well
	vecScratch.pitch = -( KICK_MIN_X + ( maxVerticleKickAngle * kickPerc ) );
	vecScratch.yaw = -( KICK_MIN_Y + ( maxVerticleKickAngle * kickPerc ) ) / 3;
	vecScratch.roll = KICK_MIN_Z + ( maxVerticleKickAngle * kickPerc ) / 8;

	//Wibble left and right
	if ( math.random( -1, 1 ) >= 0 ) then
		vecScratch.yaw = vecScratch.yaw * -1;
	end

	//Wobble up and down
	if ( math.random( -1, 1 ) >= 0 ) then
		vecScratch.roll = vecScratch.roll * -1;
	end

	//Clip this to our desired min/max
	// vecScratch = UTIL_ClipPunchAngleOffset( vecScratch, vec3_angle, Angle( 24.0, 3.0, 1.0 ) );

	//Add it to the view punch
	// NOTE: 0.5 is just tuned to match the old effect before the punch became simulated
	pPlayer:ViewPunch( vecScratch * 0.5 );

end

/*---------------------------------------------------------
   Name: SWEP:SecondaryAttack( )
   Desc: +attack2 has been pressed
---------------------------------------------------------*/
function SWEP:SecondaryAttack()
return false
end

/*---------------------------------------------------------
   Name: SWEP:FinishReload( )
   Desc: FinishReload
---------------------------------------------------------*/
function SWEP:FinishReload()
	self.m_bInReload = false;
end

/*---------------------------------------------------------
   Name: SWEP:Reload( )
   Desc: Reload is being pressed
---------------------------------------------------------*/
function SWEP:Reload()

	if ( (Silenced == 1) ) then
	self:SilencedReload()
	else if ( (PistolSilenced == 1) ) then
	self:SilencedReload()
	else

	self.Owner:SetFOV( 90, self.Weapon:SequenceDuration() )
	Zoom = 0

	self.m_fFireDuration = 0.0;

	local fRet = self.Weapon:DefaultReload( ACT_VM_RELOAD );
	if ( fRet ) then
		self.m_bInReload = true;
		self.m_flAccuracyPenalty = 0.0;

		timer.Simple( self.Weapon:SequenceDuration(), function() self.FinishReload(self) end )
	end
	return fRet;

end
end
end

function SWEP:SilencedReload()


	self.Owner:SetFOV( 90, self.Weapon:SequenceDuration() )
	Zoom = 0

	self.m_fFireDuration = 0.0;

	local fRet = self.Weapon:DefaultReload( ACT_VM_RELOAD_SILENCED );
	if ( fRet ) then
		self.m_bInReload = true;
		self.m_flAccuracyPenalty = 0.0;

		timer.Simple( self.Weapon:SequenceDuration(), self.FinishReload, self )
	end
	return fRet;

end


//-----------------------------------------------------------------------------
// Purpose:
//-----------------------------------------------------------------------------
function SWEP:AddViewKick()

	local	EASY_DAMPEN			= 0.5
	local	MAX_VERTICAL_KICK	= 1.0	//Degrees
	local	SLIDE_LIMIT			= 2.0	//Seconds

	//Get the view kick
	local pPlayer = self.Owner;

	if ( pPlayer == NULL ) then
		return;
	end

	self:DoMachineGunKick( pPlayer, EASY_DAMPEN, MAX_VERTICAL_KICK, self.m_fFireDuration, SLIDE_LIMIT );

end


//-----------------------------------------------------------------------------
// Purpose:
//-----------------------------------------------------------------------------
function SWEP:UpdatePenaltyTime( void )

	local pOwner = self.Owner;

	if ( pOwner == NULL ) then
		return;
	end

	// Check our penalty time decay
	if ( !pOwner:KeyDown( IN_ATTACK ) ) then
		self.m_flAccuracyPenalty = self.m_flAccuracyPenalty - FrameTime();
		self.m_flAccuracyPenalty = math.Clamp( self.m_flAccuracyPenalty, 0.0, PISTOL_ACCURACY_MAXIMUM_PENALTY_TIME );
	end

end


/*---------------------------------------------------------
   Name: SWEP:Think( )
   Desc: Called every frame
---------------------------------------------------------*/
function SWEP:Think()

	self:UpdatePenaltyTime();

	//self.BaseClass:Think();

	if ( self.m_bInReload ) then
		return;
	end

	local pOwner = self.Owner;

	if ( pOwner == NULL ) then
		return;
	end

	if ( pOwner:KeyDown( IN_ATTACK ) ) then
		self.m_fFireDuration = self.m_fFireDuration + FrameTime();
	elseif ( !pOwner:KeyDown( IN_ATTACK ) ) then
		self.m_fFireDuration = 0.0;
	end

end


/*---------------------------------------------------------
   Name: SWEP:Holster( weapon_to_swap_to )
   Desc: Weapon wants to holster
   RetV: Return true to allow the weapon to holster
---------------------------------------------------------*/
function SWEP:Holster( wep )

	if ( GAMEMODE.IsSandboxDerived ) then

		// Set the player's speed
		GAMEMODE:SetPlayerSpeed( self.Owner, 250, 500 )

	end

	self.m_bInReload = false;
	self.Owner:SetCanZoom( true )
	
	PistolBurst = 0
	Burst = 0
	Zoom = 0
	Silenced = 0
	PistolSilenced = 0

	return true

end

/*---------------------------------------------------------
   Name: SWEP:Deploy( )
   Desc: Whip it out
---------------------------------------------------------*/
function SWEP:Deploy()

	if ( (Silenced == 1) ) then
	self:DeploySilenced()
	else if (PistolSilenced == 1) then
	self:DeploySilenced()
	else
	

	self.Weapon:SendWeaponAnim( ACT_VM_DRAW )
	self:SetDeploySpeed( self.Weapon:SequenceDuration() )

	self.m_fFireDuration	= 0.0;
	self.m_bInReload		= false;

	local pl = self.Owner;

	pl:SetCanZoom( false )

	if ( SERVER ) then
		pl:SetFOV( 90, self.Weapon:SequenceDuration() )
	end

	GAMEMODE:SetPlayerSpeed( pl, self.MaxPlayerSpeed, 63.33 )
	pl:SetCrouchedWalkSpeed( 63.33 / 190 )
	pl:SetDuckSpeed( 0.4 )
	pl:SetUnDuckSpeed( 0.2 )

	return true

end
end
end

function SWEP:DeploySilenced()

	self.Weapon:SendWeaponAnim( ACT_VM_DRAW_SILENCED )
	self:SetDeploySpeed( self.Weapon:SequenceDuration() )

	self.m_fFireDuration	= 0.0;
	self.m_bInReload		= false;

	local pl = self.Owner;

	pl:SetCanZoom( false )

	if ( SERVER ) then
		pl:SetFOV( 90, self.Weapon:SequenceDuration() )
	end

	GAMEMODE:SetPlayerSpeed( pl, self.MaxPlayerSpeed, 63.33 )
	pl:SetCrouchedWalkSpeed( 63.33 / 190 )
	pl:SetDuckSpeed( 0.4 )
	pl:SetUnDuckSpeed( 0.2 )

	return true

end


/*---------------------------------------------------------
   Name: SWEP:CSShootBullet( )
   Desc: A convenience function to shoot bullets
---------------------------------------------------------*/
function SWEP:CSShootBullet( damage, num_bullets, aimcone )

	// Only the player fires this way so we can cast
	local pPlayer = self.Owner;

	if ( !pPlayer ) then
		return;
	end

	local pHL2MPPlayer = pPlayer;

		// Fire the bullets
	local info = {};
	info.Num = num_bullets;
	info.Src = pHL2MPPlayer:GetShootPos();
	info.Dir = pPlayer:GetAimVector();
	info.Spread = aimcone;
	info.Damage = damage;
	info.Attacker = pPlayer;
	info.Tracer = 0;

	info.Owner = self.Owner
	info.Weapon = self.Weapon

	info.ShootCallback = self.ShootCallback;

	info.Callback = function( attacker, trace, dmginfo )

		info.Weapon:FirePenetratingBullets( attacker, trace, dmginfo );

		return info:ShootCallback( attacker, trace, dmginfo );

	end

	pPlayer:FireBullets( info );

end


/*---------------------------------------------------------
   Name: SWEP:ShootCallback( )
   Desc: A convenience function to shoot bullets
---------------------------------------------------------*/
function SWEP:ShootCallback( attacker, trace, dmginfo )
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

	oldPos = oldPos
	oldPos = oldPos + oldAng:Forward() * BobCycleY/2

	return oldPos, oldAng
end