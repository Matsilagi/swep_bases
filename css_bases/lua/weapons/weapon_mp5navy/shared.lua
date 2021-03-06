

if ( SERVER ) then

	if ( !util.IsValidModel( "models/weapons/v_smg_mp5.mdl" ) ) then

		SWEP.m_bIsDisabled	= true

		return

	end

	AddCSLuaFile( "shared.lua" )

end

if ( CLIENT ) then

	SWEP.PrintName			= "#Cstrike_WPNHUD_MP5"
	SWEP.ClassName			= string.Strip( GetScriptPath(), "weapons/" )
	SWEP.Author				= "VALVe"
	SWEP.Slot				= 0
	SWEP.SlotPos			= 0



	SWEP.weapon				= {}
	SWEP.weapon.character	= "X"

	SWEP.ammo				= {}
	SWEP.ammo.character		= "R"

	killicon.AddFont( SWEP.ClassName, "CSKillIcons", SWEP.weapon.character:lower(), Color( 255, 80, 0, 255 ) )

end


SWEP.Base				= "css_base"
SWEP.Category			= "Counter-Strike: Source"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.ViewModel			= "models/weapons/v_smg_mp5.mdl"
SWEP.WorldModel			= "models/weapons/w_smg_mp5.mdl"

SWEP.Weight				= 25

SWEP.MaxPlayerSpeed			= 230
SWEP.WeaponPrice			= 1500

// Weapon characteristics:
SWEP.Penetration			= 1
SWEP.Damage					= 28
SWEP.RangeModifier			= 0.84
SWEP.Bullets				= 1
SWEP.CycleTime				= 0.075
SWEP.MaxInaccuracy			= 1.0

SWEP.Primary.Sound			= Sound( "Weapon_MP5Navy.Single" )
SWEP.Primary.Cone			= VECTOR_CONE_6DEGREES
SWEP.Primary.ClipSize		= 30
SWEP.Primary.DefaultClip	= 30
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= BULLET_PLAYER_9MM

PistolBurst = 0
Burst = 0
Zoom = 0
Silenced = 0
PistolSilenced = 0