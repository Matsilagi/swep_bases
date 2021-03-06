

if ( SERVER ) then

	if ( !util.IsValidModel( "models/weapons/v_smg_ump45.mdl" ) ) then

		SWEP.m_bIsDisabled	= true

		return

	end

	AddCSLuaFile( "shared.lua" )

	SWEP.HoldType			= "smg"

end

if ( CLIENT ) then

	SWEP.PrintName			= "#Cstrike_WPNHUD_UMP45"
	SWEP.ClassName			= string.Strip( GetScriptPath(), "weapons/" )
	SWEP.Author				= "VALVe"
	SWEP.Slot				= 0
	SWEP.SlotPos			= 0

	SWEP.HoldType			= "smg"

	SWEP.weapon				= {}
	SWEP.weapon.character	= "Q"

	SWEP.ammo				= {}
	SWEP.ammo.character		= "M"

	killicon.AddFont( SWEP.ClassName, "CSKillIcons", SWEP.weapon.character:lower(), Color( 255, 80, 0, 255 ) )

end


SWEP.Base				= "css_base"
SWEP.Category			= "Counter-Strike: Source"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.ViewModel			= "models/weapons/v_smg_ump45.mdl"
SWEP.WorldModel			= "models/weapons/w_smg_ump45.mdl"

SWEP.Weight				= 25

SWEP.MaxPlayerSpeed			= 230
SWEP.WeaponPrice			= 1700

// Weapon characteristics:
SWEP.Penetration			= 1
SWEP.Damage					= 35
SWEP.RangeModifier			= 0.82
SWEP.Bullets				= 1
SWEP.CycleTime				= 0.1
SWEP.MaxInaccuracy			= 1.0

SWEP.Primary.Sound			= Sound( "Weapon_UMP45.Single" )
SWEP.Primary.Cone			= VECTOR_CONE_6DEGREES
SWEP.Primary.ClipSize		= 25
SWEP.Primary.DefaultClip	= 25
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= BULLET_PLAYER_45ACP

PistolBurst = 0
Burst = 0
Zoom = 0
Silenced = 0
PistolSilenced = 0