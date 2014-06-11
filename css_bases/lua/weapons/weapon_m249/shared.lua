

if ( SERVER ) then

	if ( !util.IsValidModel( "models/weapons/v_mach_m249para.mdl" ) ) then

		SWEP.m_bIsDisabled	= true

		return

	end

	AddCSLuaFile( "shared.lua" )

end

if ( CLIENT ) then

	SWEP.PrintName			= "#Cstrike_WPNHUD_M249"
	SWEP.ClassName			= string.Strip( GetScriptPath(), "weapons/" )
	SWEP.Author				= "VALVe"
	SWEP.Slot				= 0
	SWEP.SlotPos			= 0



	SWEP.weapon				= {}
	SWEP.weapon.character	= "Z"

	SWEP.ammo				= {}
	SWEP.ammo.character		= "N"

	killicon.AddFont( SWEP.ClassName, "CSKillIcons", SWEP.weapon.character:lower(), Color( 255, 80, 0, 255 ) )

end


SWEP.Base				= "css_base"
SWEP.Category			= "Counter-Strike: Source"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.ViewModelFlip		= false
SWEP.ViewModel			= "models/weapons/v_mach_m249para.mdl"
SWEP.WorldModel			= "models/weapons/w_mach_m249para.mdl"

SWEP.Weight				= 25

SWEP.MaxPlayerSpeed			= 210
SWEP.WeaponPrice			= 5750

// Weapon characteristics:
SWEP.Penetration			= 2
SWEP.Damage					= 35
SWEP.RangeModifier			= 0.97
SWEP.Bullets				= 1
SWEP.CycleTime				= 0.08
SWEP.MaxInaccuracy			= 0.5

SWEP.Primary.Sound			= Sound( "Weapon_M249.Single" )
SWEP.Primary.Cone			= VECTOR_CONE_8DEGREES
SWEP.Primary.ClipSize		= 100
SWEP.Primary.DefaultClip	= 100
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= BULLET_PLAYER_556MM_BOX

PistolBurst = 0
Burst = 0
Zoom = 0
Silenced = 0
PistolSilenced = 0