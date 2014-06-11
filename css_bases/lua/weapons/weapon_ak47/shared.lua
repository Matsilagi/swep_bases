

if ( SERVER ) then

	if ( !util.IsValidModel( "models/weapons/v_rif_ak47.mdl" ) ) then

		SWEP.m_bIsDisabled	= true

		return

	end

	AddCSLuaFile( "shared.lua" )

end

if ( CLIENT ) then

	SWEP.PrintName			= "#Cstrike_WPNHUD_AK47"
	SWEP.ClassName			= string.Strip( GetScriptPath(), "weapons/" )
	SWEP.Author				= "VALVe"
	SWEP.Slot				= 0
	SWEP.SlotPos			= 0

	SWEP.weapon				= {}
	SWEP.weapon.character	= "B"

	SWEP.ammo				= {}
	SWEP.ammo.character		= "V"



	killicon.AddFont( SWEP.ClassName, "CSKillIcons", SWEP.weapon.character:lower(), Color( 255, 80, 0, 255 ) )

end


SWEP.Base				= "css_base"
SWEP.Category			= "Counter-Strike: Source"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.ViewModel			= "models/weapons/v_rif_ak47.mdl"
SWEP.WorldModel			= "models/weapons/w_rif_ak47.mdl"

SWEP.Weight				= 25

SWEP.MaxPlayerSpeed			= 240
SWEP.WeaponPrice			= 400

// Weapon characteristics:
SWEP.Penetration			= 2
SWEP.Damage					= 34
SWEP.RangeModifier			= 0.96
SWEP.Bullets				= 1
SWEP.CycleTime				= 0.1
SWEP.MaxInaccuracy			= 1.5

SWEP.Primary.Sound			= Sound( "Weapon_AK47.Single" )
SWEP.Primary.Cone			= VECTOR_CONE_6DEGREES
SWEP.Primary.ClipSize		= 30
SWEP.Primary.DefaultClip	= 30
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= BULLET_PLAYER_762MM

PistolBurst = 0
Burst = 0
Zoom = 0
Silenced = 0
PistolSilenced = 0