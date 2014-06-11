if ( SERVER ) then

	if ( !util.IsValidModel( "models/weapons/v_rif_m4a1.mdl" ) ) then

		SWEP.m_bIsDisabled	= true

		return

	end

	AddCSLuaFile( "shared.lua" )

end

if ( CLIENT ) then

	SWEP.PrintName			= "#Cstrike_WPNHUD_M4A1"
	SWEP.ClassName			= string.Strip( GetScriptPath(), "weapons/" )
	SWEP.Author				= "VALVe"
	SWEP.Slot				= 0
	SWEP.SlotPos			= 0



	SWEP.weapon				= {}
	SWEP.weapon.character	= "W"

	SWEP.ammo				= {}
	SWEP.ammo.character		= "N"

	killicon.AddFont( SWEP.ClassName, "CSKillIcons", SWEP.weapon.character:lower(), Color( 255, 80, 0, 255 ) )

end


SWEP.Base				= "css_base"
SWEP.Category			= "Counter-Strike: Source"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.ViewModel			= "models/weapons/v_rif_m4a1.mdl"
SWEP.WorldModel			= "models/weapons/w_rif_m4a1.mdl"


SWEP.Weight				= 25

SWEP.MaxPlayerSpeed			= 230
SWEP.WeaponPrice			= 2250

// Weapon characteristics:
SWEP.Penetration			= 2
SWEP.Damage					= 33
SWEP.RangeModifier			= 0.97
SWEP.Bullets				= 1
SWEP.CycleTime				= 0.09
SWEP.MaxInaccuracy			= 1.0

SWEP.Primary.Sound			= Sound( "Weapon_M4A1.Single" )
SWEP.Primary.Cone			= VECTOR_CONE_6DEGREES
SWEP.Primary.ClipSize		= 30
SWEP.Primary.DefaultClip	= 30
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= BULLET_PLAYER_556MM

PistolBurst = 0
Burst = 0
Zoom = 0
Silenced = 0
PistolSilenced = 0

function SWEP:PrimaryAttack()

	if (Silenced == 1) then
	self:SilencedPrimaryAttack()
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

function SWEP:SilencedPrimaryAttack()

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


	// To make the firing framerate independent, we may have to fire more than one bullet here on low-framerate systems,
	// especially if the weapon we're firing has a really fast rate of fire.
	local iBulletsToFire = 0;
	local fireRate = self.CycleTime;

	// MUST call sound before removing a round from the clip of a CHLMachineGun
	self.Weapon:EmitSound(self.Primary.M4Sil);
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


	self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK_SILENCED);
	pPlayer:SetAnimation( PLAYER_ATTACK1 );

	// Add an accuracy penalty which can move past our maximum penalty time if we're really spastic
	self.m_flAccuracyPenalty = self.m_flAccuracyPenalty + self.RangeModifier;

end

function SWEP:SecondaryAttack()
	if(Silenced == 0) then
		if(SERVER) then
			self.Weapon:SendWeaponAnim( ACT_VM_ATTACH_SILENCER )
		end
	        self.Weapon:SetNextPrimaryFire( CurTime() + self.Weapon:SequenceDuration() );
	        self.Weapon:SetNextSecondaryFire( CurTime() + self.Weapon:SequenceDuration() );
                Silenced = 1
		else
		if(SERVER) then
			self.Weapon:SendWeaponAnim( ACT_VM_DETACH_SILENCER )
		end
	        self.Weapon:SetNextPrimaryFire( CurTime() + self.Weapon:SequenceDuration() );
	        self.Weapon:SetNextSecondaryFire( CurTime() + self.Weapon:SequenceDuration() );
                Silenced = 0
	end
end