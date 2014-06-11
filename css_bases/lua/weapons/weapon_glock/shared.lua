

if ( SERVER ) then

	if ( !util.IsValidModel( "models/weapons/v_pist_glock18.mdl" ) ) then

		SWEP.m_bIsDisabled	= true

		return

	end

	AddCSLuaFile( "shared.lua" )

	SWEP.HoldType			= "pistol"

end

if ( CLIENT ) then

	SWEP.PrintName			= "#Cstrike_WPNHUD_Glock18"
	SWEP.ClassName			= string.Strip( GetScriptPath(), "weapons/" )
	SWEP.Author				= "VALVe"
	SWEP.Slot				= 1
	SWEP.SlotPos			= 1

	SWEP.weapon				= {}
	SWEP.weapon.character	= "C"

	SWEP.ammo				= {}
	SWEP.ammo.character		= "R"

	killicon.AddFont( SWEP.ClassName, "CSKillIcons", SWEP.weapon.character:lower(), Color( 255, 80, 0, 255 ) )

end


SWEP.Base				= "css_base"
SWEP.Category			= "Counter-Strike: Source"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.ViewModel			= "models/weapons/v_pist_glock18.mdl"
SWEP.WorldModel			= "models/weapons/w_pist_glock18.mdl"

SWEP.Weight				= 5

SWEP.MaxPlayerSpeed			= 250
SWEP.WeaponPrice			= 400

// Weapon characteristics:
SWEP.Penetration			= 1
SWEP.Damage					= 25
SWEP.RangeModifier			= 0.75
SWEP.Bullets				= 1
SWEP.CycleTime				= 0.15
SWEP.MaxInaccuracy			= 1.5

SWEP.Primary.Sound			= Sound( "Weapon_Glock.Single" )
SWEP.Primary.Cone			= VECTOR_CONE_4DEGREES
SWEP.Primary.ClipSize		= 20
SWEP.Primary.DefaultClip	= 20
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= BULLET_PLAYER_9MM


PistolBurst = 0
Burst = 0
Zoom = 0
Silenced = 0
PistolSilenced = 0


function SWEP:SecondaryAttack()
	if(PistolBurst == 0) then
	        self.Weapon:SetNextSecondaryFire( CurTime() + 0.2 );
	self.Owner:PrintMessage(HUD_PRINTTALK, self.BurstMsg)
                PistolBurst = 1
		else
	        self.Weapon:SetNextSecondaryFire( CurTime() + 0.2 );
	self.Owner:PrintMessage(HUD_PRINTTALK, self.NormalMsg)
               PistolBurst = 0
	end
end