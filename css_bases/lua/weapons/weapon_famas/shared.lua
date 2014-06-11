

if ( SERVER ) then

	if ( !util.IsValidModel( "models/weapons/v_rif_famas.mdl" ) ) then

		SWEP.m_bIsDisabled	= true
		SWEP.ViewModelFlip 	= false

		return

	end

	AddCSLuaFile( "shared.lua" )


	SWEP.ViewModelFlip 		= false

end

if ( CLIENT ) then

	SWEP.PrintName			= "#Cstrike_WPNHUD_FAMAS"
	SWEP.ClassName			= string.Strip( GetScriptPath(), "weapons/" )
	SWEP.Author				= "VALVe"
	SWEP.Slot				= 0
	SWEP.SlotPos			= 0
	SWEP.ViewModelFlip 		= false


	SWEP.weapon				= {}
	SWEP.weapon.character	= "T"

	SWEP.ammo				= {}
	SWEP.ammo.character		= "N"

	killicon.AddFont( SWEP.ClassName, "CSKillIcons", SWEP.weapon.character:lower(), Color( 255, 80, 0, 255 ) )

end


SWEP.Base				= "css_base"
SWEP.Category			= "Counter-Strike: Source"

SWEP.UseScope                           = true

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.ViewModel			= "models/weapons/v_rif_famas.mdl"
SWEP.WorldModel			= "models/weapons/w_rif_famas.mdl"

SWEP.Weight				= 75

SWEP.MaxPlayerSpeed			= 240
SWEP.WeaponPrice			= 400

SWEP.ZoomedPrimaryAutomatic             = true
SWEP.ZoomedPrimaryDelay                 = 0.2
SWEP.ZoomedPrimaryCone                  = 0
SWEP.ZoomedPrimaryDamage                = 32
SWEP.ZoomedPrimaryRecoil                = 0.2
SWEP.ZoomedTracerFreq                   = 0
SWEP.ZoomedDrawCrosshair		= false

SWEP.UnzoomedPrimaryAutomatic           = true
SWEP.UnzoomedPrimaryDelay               = 0.09
SWEP.UnzoomedPrimaryCone                = 0.03
SWEP.UnzoomedPrimaryDamage              = 32
SWEP.UnzoomedPrimaryRecoil              = 0.2
SWEP.UnzoomedTracerFreq                 = 1
SWEP.UnzoomedDrawCrosshair		= false

// Weapon characteristics:
SWEP.Penetration			= 2
SWEP.Damage					= 30
SWEP.RangeModifier			= 0.96
SWEP.Bullets				= 1
SWEP.CycleTime				= 0.09
SWEP.MaxInaccuracy			= 1.0

SWEP.Primary.Sound			= Sound( "Weapon_FAMAS.Single" )
SWEP.Primary.Cone			= VECTOR_CONE_6DEGREES
SWEP.ZoomedPrimaryCone			= VECTOR_CONE_3DEGREES
SWEP.Primary.ClipSize		= 30
SWEP.Primary.DefaultClip	= 30
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= BULLET_PLAYER_556MM

PistolBurst = 0
Burst = 0
Zoom = 0
Silenced = 0
PistolSilenced = 0


function SWEP:SecondaryAttack()
	if(Burst == 0) then
	        self.Weapon:SetNextSecondaryFire( CurTime() + 0.2 );
	self.Owner:PrintMessage(HUD_PRINTTALK, self.BurstMsg)
                Burst = 1
		else
	        self.Weapon:SetNextSecondaryFire( CurTime() + 0.2 );
	self.Owner:PrintMessage(HUD_PRINTTALK, self.RifleNormalMsg)
               Burst = 0
	end
end