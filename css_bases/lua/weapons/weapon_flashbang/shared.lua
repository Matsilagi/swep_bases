

if ( SERVER ) then

	if ( !util.IsValidModel( "models/weapons/v_eq_flashbang.mdl" ) ) then

		SWEP.m_bIsDisabled	= true

		return

	end

	AddCSLuaFile( "shared.lua" )

end

if ( CLIENT ) then

	SWEP.PrintName			= "#Cstrike_WPNHUD_Flashbang"
	SWEP.Author				= "VALVe"
	SWEP.Slot				= 3
	SWEP.SlotPos			= 1
	SWEP.WepSelectFont		= "CSweaponsSmall"
	SWEP.WepSelectLetter	= "G"

	SWEP.weapon				= {}
	SWEP.weapon.character	= "G"

	SWEP.ammo				= {}
	SWEP.ammo.font			= "CSTypeDeath"
	SWEP.ammo.character		= "Q"

	killicon.AddFont( "sent_flashbang", "CSKillIcons", SWEP.weapon.character:lower(), Color( 255, 80, 0, 255 ) )

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


SWEP.Base				= "swep_frag_css"
SWEP.Category			= "Counter-Strike: Source"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.ViewModelFOV		= 54
SWEP.ViewModelFlip		= true
SWEP.ViewModel			= "models/weapons/v_eq_flashbang.mdl"
SWEP.WorldModel			= "models/weapons/w_eq_flashbang.mdl"

SWEP.Weight				= 2

SWEP.MaxPlayerSpeed			= 250
SWEP.WeaponPrice			= 300

// Weapon characteristics:
SWEP.Penetration			= 1
SWEP.Damage					= 50
SWEP.RangeModifier			= 0.99
SWEP.Bullets				= 1

SWEP.Primary.AmmoType		= "sent_flashbang"

PistolBurst = 0
Burst = 0
Zoom = 0
Silenced = 0
PistolSilenced = 0

function SWEP:Operator_HandleAnimEvent( pEvent, pOperator )

	if ( self.fThrewGrenade ) then
		return;
	end

	local pOwner = self.Owner;
	self.fThrewGrenade = false;

	if( pEvent ) then
		if pEvent == "EVENT_WEAPON_SEQUENCE_FINISHED" then
			self.m_fDrawbackFinished = true;
			return;

		elseif pEvent == "EVENT_WEAPON_THROW" then
			self:ThrowGrenade( pOwner );
			self:DecrementAmmo( pOwner );
			self.fThrewGrenade = true;
			return;

		else
			return;
		end
	end

local RETHROW_DELAY	= self.Primary.Delay
	if( self.fThrewGrenade ) then
		self.Weapon:SetNextPrimaryFire( CurTime() + RETHROW_DELAY );
		self.m_flNextPrimaryAttack	= CurTime() + RETHROW_DELAY;
		self.m_flTimeWeaponIdle = FLT_MAX;
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

function SWEP:Think()

	if ((self.fThrewGrenade && CurTime() > self.Primary.Delay)) then
		self.fThrewGrenade = false;

		self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay );
		self.m_flNextPrimaryAttack = CurTime() + self.Primary.Delay;
		self.m_flTimeWeaponIdle = CurTime() + self.Primary.Delay;
	end

	if ((self.m_flSequenceDuration > CurTime())) then
		self:Operator_HandleAnimEvent( "EVENT_WEAPON_SEQUENCE_FINISHED" );
		self.m_flSequenceDuration = CurTime();
	end

	if( self.m_fDrawbackFinished ) then
		local pOwner = self.Owner;

		if (pOwner) then
			if( self.m_AttackPaused ) then
			if self.m_AttackPaused == GRENADE_PAUSED_PRIMARY then
				if( !(pOwner:KeyDown( IN_ATTACK )) ) then
					self.Weapon:SendWeaponAnim( ACT_VM_THROW );
					self:Operator_HandleAnimEvent( "EVENT_WEAPON_THROW" );

					self.m_fDrawbackFinished = false;
				end
				return;

			else
				return;
			end
			end
		end
	end

	local pPlayer = self.Owner;

	if ( !pPlayer ) then
		return;
	end

	if ( self.m_bRedraw ) then
		self:Reload();
	end

end
