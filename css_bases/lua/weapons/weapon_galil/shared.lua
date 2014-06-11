

if ( SERVER ) then

	if ( !util.IsValidModel( "models/weapons/v_rif_galil.mdl" ) ) then

		SWEP.m_bIsDisabled	= true

		return

	end

	AddCSLuaFile( "shared.lua" )

end

if ( CLIENT ) then

	SWEP.PrintName			= "#Cstrike_WPNHUD_Galil"
	SWEP.ClassName			= string.Strip( GetScriptPath(), "weapons/" )
	SWEP.Author				= "VALVe"
	SWEP.Slot				= 0
	SWEP.SlotPos			= 0



	SWEP.weapon				= {}
	SWEP.weapon.character	= "V"

	SWEP.ammo				= {}
	SWEP.ammo.character		= "N"

	killicon.AddFont( SWEP.ClassName, "CSKillIcons", SWEP.weapon.character:lower(), Color( 255, 80, 0, 255 ) )

end


SWEP.Base				= "css_base"
SWEP.Category			= "Counter-Strike: Source"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.ViewModelFlip		= false
SWEP.ViewModel			= "models/weapons/v_rif_galil.mdl"
SWEP.WorldModel			= "models/weapons/w_rif_galil.mdl"

SWEP.Weight				= 25

SWEP.MaxPlayerSpeed			= 221
SWEP.WeaponPrice			= 2000

// Weapon characteristics:
SWEP.Penetration			= 2
SWEP.Damage					= 30
SWEP.RangeModifier			= 0.98
SWEP.Bullets				= 1
SWEP.CycleTime				= 0.09
SWEP.MaxInaccuracy			= 1.5

SWEP.Primary.Sound			= Sound( "Weapon_Galil.Single" )
SWEP.Primary.Cone			= VECTOR_CONE_6DEGREES
SWEP.Primary.ClipSize		= 35
SWEP.Primary.DefaultClip	= 35
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= BULLET_PLAYER_556MM

PistolBurst = 0
Burst = 0
Zoom = 0
Silenced = 0
PistolSilenced = 0