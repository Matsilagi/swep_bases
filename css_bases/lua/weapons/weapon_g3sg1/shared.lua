

if ( SERVER ) then

	if ( !util.IsValidModel( "models/weapons/v_snip_scout.mdl" ) ) then

		SWEP.m_bIsDisabled	= true

		return

	end

	AddCSLuaFile( "shared.lua" )

end

if ( CLIENT ) then

	SWEP.PrintName			= "#Cstrike_WPNHUD_g3sg1"
	SWEP.ClassName			= string.Strip( GetScriptPath(), "weapons/" )
	SWEP.Author				= "VALVe"
	SWEP.Slot				= 0
	SWEP.SlotPos			= 0



	SWEP.weapon				= {}
	SWEP.weapon.character	= "I"

	SWEP.ammo				= {}
	SWEP.ammo.character		= "V"

	killicon.AddFont( SWEP.ClassName, "CSKillIcons", SWEP.weapon.character:lower(), Color( 255, 80, 0, 255 ) )

end


SWEP.Base				= "css_base"
SWEP.Category			= "Counter-Strike: Source"

SWEP.UseScope                           = true

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.ViewModel			= "models/weapons/v_snip_g3sg1.mdl"
SWEP.WorldModel			= "models/weapons/w_snip_g3sg1.mdl"

SWEP.Weight				= 20

SWEP.MaxPlayerSpeed			= 210
SWEP.WeaponPrice			= 5000

SWEP.ZoomedPrimaryAutomatic             = true
SWEP.ZoomedPrimaryDelay                 = 0.2
SWEP.ZoomedPrimaryCone                  = 0
SWEP.ZoomedPrimaryDamage                = 32
SWEP.ZoomedPrimaryRecoil                = 0.2
SWEP.ZoomedTracerFreq                   = 0
SWEP.ZoomedDrawCrosshair		= false

SWEP.UnzoomedPrimaryAutomatic           = true
SWEP.UnzoomedPrimaryDelay               = 0.25
SWEP.UnzoomedPrimaryCone                = 0.03
SWEP.UnzoomedPrimaryDamage              = 32
SWEP.UnzoomedPrimaryRecoil              = 0.2
SWEP.UnzoomedTracerFreq                 = 1
SWEP.UnzoomedDrawCrosshair		= false

// Weapon characteristics:
SWEP.Penetration			= 3
SWEP.Damage					= 80
SWEP.RangeModifier			= 0.98
SWEP.Bullets				= 1
SWEP.CycleTime				= 0.25
SWEP.MaxInaccuracy			= 0

SWEP.Primary.Sound			= Sound( "Weapon_G3SG1.Single" )
SWEP.Primary.Cone			= VECTOR_CONE_5DEGREES
SWEP.ZoomedPrimaryCone			= VECTOR_CONE_3DEGREES
SWEP.Primary.ClipSize		= 20
SWEP.Primary.DefaultClip	= 20
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= BULLET_PLAYER_762MM

PistolBurst = 0
Burst = 0
Zoom = 0
Silenced = 0
PistolSilenced = 0

function SWEP:SecondaryAttack()
	if(Zoom == 0) then
		if(SERVER) then
			self.Owner:SetFOV( 25, 0.3 )
			self.Weapon:EmitSound( Sound( "Default.Zoom" ) )
			self:SetZoomed(true)
		end
	        self.Weapon:SetNextSecondaryFire( CurTime() + 0.2 );
                Zoom = 1
		else if(Zoom == 1) then
		if(SERVER) then
			self.Owner:SetFOV( 15, 0.2 )
			self.Weapon:EmitSound( Sound( "Default.Zoom" ) )
		end
	        self.Weapon:SetNextSecondaryFire( CurTime() + 0.2 );
                Zoom = 2
		else
		if(SERVER) then
			self.Owner:SetFOV( 90, 0.2 )
			self.Weapon:EmitSound( Sound( "Default.Zoom" ) )
			self:SetZoomed(false)
		end
	        self.Weapon:SetNextSecondaryFire( CurTime() + 0.2 );
                Zoom = 0
	end
end
end