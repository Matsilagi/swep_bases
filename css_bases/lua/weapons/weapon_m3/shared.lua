

if ( SERVER ) then

	if ( !util.IsValidModel( "models/weapons/v_shot_m3super90.mdl" ) ) then

		SWEP.m_bIsDisabled	= true

		return

	end

	AddCSLuaFile( "shared.lua" )

end

if ( CLIENT ) then

	SWEP.PrintName			= "#Cstrike_WPNHUD_m3"
	SWEP.ClassName			= string.Strip( GetScriptPath(), "weapons/" )
	SWEP.Author				= "VALVe"
	SWEP.Slot				= 0
	SWEP.SlotPos			= 0
	SWEP.WepSelectFont		= "CSweaponsSmall"
	SWEP.WepSelectLetter	= "K"

	SWEP.weapon				= {}
	SWEP.weapon.character	= "K"

	SWEP.ammo				= {}
	SWEP.ammo.font			= "CSTypeDeath"
	SWEP.ammo.character		= "J"

	killicon.AddFont( SWEP.ClassName, "CSKillIcons", SWEP.weapon.character:lower(), Color( 255, 80, 0, 255 ) )

	SWEP.DrawHUD			= DrawCSSHud

	function SWEP:HUDShouldDraw( element )

		if (element == "CHudSuitPower") then return false end
		if (element == "CHudHealth") then return false end
		if (element == "CHudBattery") then return false end
		if (element == "CHudAmmo") then return false end
		if (element == "CHudSecondaryAmmo") then return false end

		return true;

	end

end


SWEP.Base				= "swep_shotgun_css"
SWEP.Category			= "Counter-Strike: Source"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.ViewModelFOV		= 54
SWEP.ViewModelFlip		= true
SWEP.CSMuzzleFlashes	= true
SWEP.ViewModel			= "models/weapons/v_shot_m3super90.mdl"
SWEP.WorldModel			= "models/weapons/w_shot_m3super90.mdl"

SWEP.Weight				= 20

SWEP.MaxPlayerSpeed			= 220
SWEP.WeaponPrice			= 1700

// Weapon characteristics:
SWEP.Penetration			= 1
SWEP.Damage					= 22
SWEP.RangeModifier			= 0.96
SWEP.Bullets				= 9
SWEP.CycleTime				= 0.5

SWEP.Primary.Empty			= Sound( "Default.ClipEmpty_Rifle" )
SWEP.Primary.Sound			= Sound( "Weapon_M3.Single" )
SWEP.Primary.ClipSize		= 8
SWEP.Primary.DefaultClip	= SWEP.Primary.ClipSize + 32
SWEP.Primary.Ammo			= BULLET_PLAYER_BUCKSHOT
SWEP.Primary.Tracer			= 0

PistolBurst = 0
Burst = 0
Zoom = 0
Silenced = 0
PistolSilenced = 0

function SWEP:PrimaryAttack()

	local pOwner = self.Owner;
	if (!pOwner) then
		return;
	end

	if ( self.Weapon:Clip1() <= 0 ) then
		if (pOwner:GetAmmoCount(self.Primary.Ammo) <= 0) then
			self:DryFire();
			return;
		else
			self:StartReload();
			return;
		end
	else
		// If the firing button was just pressed, reset the firing time
		local pPlayer = self.Owner;
		if ( !pPlayer:IsNPC() ) then
			if ( pPlayer && pPlayer:KeyPressed( IN_ATTACK ) ) then
				 self.Weapon:SetNextPrimaryFire( CurTime() );
				 self.Weapon:SetNextSecondaryFire( CurTime() );
				 self.m_flNextPrimaryAttack = CurTime();
			end
		end
	end

	// Only the player fires this way so we can cast
	local pPlayer = self.Owner;

	if (!pPlayer) then
		return;
	end

	// MUST call sound before removing a round from the clip of a CMachineGun
	self.Weapon:EmitSound(self.Primary.Sound);

	pPlayer:MuzzleFlash();

	self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK );

	// Don't fire again until fire animation has completed
	self.Weapon:SetNextPrimaryFire( CurTime() + self.Weapon:SequenceDuration() );
	self.Weapon:SetNextSecondaryFire( CurTime() + self.Weapon:SequenceDuration() );
	self.m_flNextPrimaryAttack = CurTime() + self.Weapon:SequenceDuration();
	self:TakePrimaryAmmo( self.Primary.NumAmmo );

	// player "shoot" animation
	pPlayer:SetAnimation( PLAYER_ATTACK1 );


	self:ShootBullet( self.Damage, self.Bullets, self:GetBulletSpread() );

	local punch;
	punch = Angle( -1.0, 0, 0 );
	if (!pPlayer:IsNPC()) then
		pPlayer:ViewPunch( punch );
	end

end

function SWEP:SecondaryAttack()
end

function SWEP:Holster()

	if ( GAMEMODE.IsSandboxDerived ) then

		// Set the player's speed
		GAMEMODE:SetPlayerSpeed( self.Owner, 250, 500 )

	end

	self.Owner:SetCanZoom( true )

	return true

end

function SWEP:Deploy()

	self.Weapon:SendWeaponAnim( ACT_VM_DRAW )
	self:SetDeploySpeed( self.Weapon:SequenceDuration() )

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

function SWEP:ShootCallback( attacker, trace, dmginfo )

	self.Weapon:FirePenetratingBullets( attacker, trace, dmginfo );

end
