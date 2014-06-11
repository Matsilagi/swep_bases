if ( SERVER ) then

	if ( !util.IsValidModel( "models/weapons/v_pist_usp.mdl" ) ) then

		SWEP.m_bIsDisabled	= true

		return

	end

	AddCSLuaFile( "shared.lua" )

	SWEP.HoldType			= "pistol"

end

if ( CLIENT ) then

	SWEP.PrintName			= "#Cstrike_WPNHUD_USP45"
	SWEP.ClassName			= string.Strip( GetScriptPath(), "weapons/" )
	SWEP.Author				= "VALVe"
	SWEP.Slot				= 1
	SWEP.SlotPos			= 1

	SWEP.weapon				= {}
	SWEP.weapon.character	= "A"

	SWEP.ammo				= {}
	SWEP.ammo.character		= "M"

	killicon.AddFont( SWEP.ClassName, "CSKillIcons", SWEP.weapon.character:lower(), Color( 255, 80, 0, 255 ) )

end


SWEP.Base				= "css_base"
SWEP.Category			= "Counter-Strike: Source"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.ViewModel			= "models/weapons/v_pist_usp.mdl"
SWEP.WorldModel			= "models/weapons/w_pist_usp.mdl"

SWEP.Weight				= 5

SWEP.MaxPlayerSpeed			= 250
SWEP.WeaponPrice			= 500

// Weapon characteristics:
SWEP.Penetration			= 1
SWEP.Damage					= 34
SWEP.RangeModifier			= 0.79
SWEP.Bullets				= 1
SWEP.CycleTime				= 0.15
SWEP.MaxInaccuracy			= 1.5

SWEP.Primary.Sound			= Sound( "Weapon_USP.Single" )
SWEP.Primary.USPSil			= Sound( "Weapon_USP.SilencedShot" )
SWEP.Primary.Cone			= VECTOR_CONE_4DEGREES
SWEP.Primary.ClipSize		= 12
SWEP.Primary.DefaultClip	= 13
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= BULLET_PLAYER_45ACP

PistolBurst = 0
Burst = 0
Zoom = 0
Silenced = 0
PistolSilenced = 0

function SWEP:PrimaryAttack()

	if (PistolSilenced == 1) then
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
	self.Weapon:EmitSound(self.Primary.USPSil);
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
	if(PistolSilenced == 0) then
		if(SERVER) then
			self.Weapon:SendWeaponAnim( ACT_VM_ATTACH_SILENCER )
		end
	        self.Weapon:SetNextPrimaryFire( CurTime() + self.Weapon:SequenceDuration() );
	        self.Weapon:SetNextSecondaryFire( CurTime() + self.Weapon:SequenceDuration() );
                PistolSilenced = 1
		else
		if(SERVER) then
			self.Weapon:SendWeaponAnim( ACT_VM_DETACH_SILENCER )
		end
	        self.Weapon:SetNextPrimaryFire( CurTime() + self.Weapon:SequenceDuration() );
	        self.Weapon:SetNextSecondaryFire( CurTime() + self.Weapon:SequenceDuration() );
               PistolSilenced = 0
	end
end
