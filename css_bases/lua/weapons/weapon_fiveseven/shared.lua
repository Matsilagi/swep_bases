

if ( SERVER ) then

	if ( !util.IsValidModel( "models/weapons/v_pist_fiveseven.mdl" ) ) then

		SWEP.m_bIsDisabled	= true

		return

	end

	AddCSLuaFile( "shared.lua" )

	SWEP.HoldType			= "pistol"

end

if ( CLIENT ) then

	SWEP.PrintName			= "#Cstrike_WPNHUD_FiveSeven"
	SWEP.ClassName			= string.Strip( GetScriptPath(), "weapons/" )
	SWEP.Author				= "VALVe"
	SWEP.Slot				= 1
	SWEP.SlotPos			= 1

	SWEP.weapon				= {}
	SWEP.weapon.character	= "U"

	SWEP.ammo				= {}
	SWEP.ammo.character		= "S"

	killicon.AddFont( SWEP.ClassName, "CSKillIcons", SWEP.weapon.character:lower(), Color( 255, 80, 0, 255 ) )

end


SWEP.Base				= "css_base"
SWEP.Category			= "Counter-Strike: Source"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.ViewModel			= "models/weapons/v_pist_fiveseven.mdl"
SWEP.WorldModel			= "models/weapons/w_pist_fiveseven.mdl"

SWEP.Weight				= 5

SWEP.MaxPlayerSpeed			= 240
SWEP.WeaponPrice			= 750

// Weapon characteristics:
SWEP.Penetration			= 1
SWEP.Damage					= 27
SWEP.RangeModifier			= 0.885
SWEP.Bullets				= 1
SWEP.CycleTime				= 0.16
SWEP.MaxInaccuracy			= 1.5

SWEP.Primary.Sound			= Sound( "Weapon_FiveSeven.Single" )
SWEP.Primary.Cone			= VECTOR_CONE_4DEGREES
SWEP.Primary.ClipSize		= 20
SWEP.Primary.DefaultClip	= 20
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= BULLET_PLAYER_57MM

PistolBurst = 0
Burst = 0
Zoom = 0
Silenced = 0
PistolSilenced = 0