

MAT_ORGANIC = {

	MAT_ALIENFLESH,
	MAT_ANTLION,
	MAT_BLOODYFLESH,
	MAT_FLESH

}

if ( SERVER ) then

	if ( !util.IsValidModel( "models/weapons/v_knife_t.mdl" ) ) then

		SWEP.m_bIsDisabled	= true

		return

	end

	AddCSLuaFile( "shared.lua" )

	SWEP.HoldType			= "knife"

end

if ( CLIENT ) then

	SWEP.PrintName			= "#Cstrike_WPNHUD_Knife"
	SWEP.ClassName			= string.Strip( GetScriptPath(), "weapons/" )
	SWEP.Author				= "VALVe"
	SWEP.Slot				= 2
	SWEP.SlotPos			= 1
	SWEP.WepSelectFont		= "CSweaponsSmall"
	SWEP.WepSelectLetter	= "J"

	SWEP.weapon				= {}
	SWEP.weapon.character	= "J"

	killicon.AddFont( SWEP.ClassName, "CSKillIcons", SWEP.weapon.character:lower(), Color( 255, 80, 0, 255 ) )

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


SWEP.Base				= "swep_stunstick_css"
SWEP.Category			= "Counter-Strike: Source"

SWEP.activate			= Sound( "common/null.wav" )
SWEP.deactivate			= Sound( "common/null.wav" )

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.ViewModelFOV		= 54
SWEP.ViewModelFlip		= false
SWEP.ViewModel			= "models/weapons/v_knife_t.mdl"
SWEP.WorldModel			= "models/weapons/w_knife_t.mdl"

SWEP.Weight				= 0

SWEP.MaxPlayerSpeed			= 250
SWEP.WeaponPrice			= 0

// Weapon characteristics:
SWEP.Penetration			= 1
SWEP.Damage					= 50
SWEP.RangeModifier			= 0.99
SWEP.Bullets				= 1

SWEP.Primary.Sound			= Sound( "Weapon_Knife.Slash" )
SWEP.Primary.Special1		= Sound( "Weapon_Knife.Stab" )
SWEP.Primary.HitOrganic		= Sound( "Weapon_Knife.Hit" )
SWEP.Primary.Hit			= Sound( "Weapon_Knife.HitWall" )
SWEP.Primary.Damage			= SWEP.Damage
SWEP.Primary.DamageType		= DMG_SLASH
SWEP.Primary.Delay			= 0.4

SWEP.Secondary.Damage		= SWEP.Damage * 2
SWEP.Secondary.Delay		= 0.8
SWEP.Secondary.Automatic	= true

PistolBurst = 0
Burst = 0
Zoom = 0
Silenced = 0
PistolSilenced = 0

function SWEP:PrimaryAttack()

	local pPlayer		= self.Owner;

	if ( !pPlayer ) then
		return;
	end

	local vecSrc		= pPlayer:GetShootPos();
	local vecDirection	= pPlayer:GetAimVector();

	local trace			= {}
		trace.start		= vecSrc
		trace.endpos	= vecSrc + ( vecDirection * 75.0 )
		trace.filter	= pPlayer

	local traceHit		= util.TraceLine( trace )

	if ( traceHit.Hit ) then

		if ( table.HasValue( MAT_ORGANIC, traceHit.MatType ) ) then
			self.Weapon:EmitSound( self.Primary.HitOrganic );
		else
			self.Weapon:EmitSound( self.Primary.Hit );
		end

		self.Weapon:SendWeaponAnim( ACT_VM_HITCENTER );
		pPlayer:LagCompensation( true );
		pPlayer:SetAnimation( PLAYER_ATTACK1 );

		self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay );
		self.Weapon:SetNextSecondaryFire( CurTime() + self.Primary.Delay );

		if ( SERVER ) then
			pPlayer:TraceHullAttack( vecSrc, traceHit.HitPos, Vector( -16, -16, -40 ), Vector( 16, 16, 16 ), self.Primary.Damage, self.Primary.DamageType, self.Primary.Force, false );
		end

		self:ImpactEffect( traceHit );

		return

	end

	self.Weapon:EmitSound( self.Primary.Sound );

	self.Weapon:SendWeaponAnim( ACT_VM_MISSCENTER );
	pPlayer:LagCompensation( false );
	pPlayer:SetAnimation( PLAYER_ATTACK1 );

	self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay );
	self.Weapon:SetNextSecondaryFire( CurTime() + self.Primary.Delay );

end

function SWEP:SecondaryAttack()

	local pPlayer		= self.Owner;

	if ( !pPlayer ) then
		return;
	end

	local vecSrc		= pPlayer:GetShootPos();
	local vecDirection	= pPlayer:GetAimVector();

	local trace			= {}
		trace.start		= vecSrc
		trace.endpos	= vecSrc + ( vecDirection * 75.0 )
		trace.filter	= pPlayer

	local traceHit		= util.TraceLine( trace )

	if ( traceHit.Hit ) then

		if ( table.HasValue( MAT_ORGANIC, traceHit.MatType ) ) then
			self.Weapon:EmitSound( self.Primary.Special1 );
		else
			self.Weapon:EmitSound( self.Primary.Hit );
		end

		self.Weapon:SendWeaponAnim( ACT_VM_HITCENTER );
		pPlayer:LagCompensation( true );
		pPlayer:SetAnimation( PLAYER_ATTACK1 );

		self.Weapon:SetNextPrimaryFire( CurTime() + self.Secondary.Delay );
		self.Weapon:SetNextSecondaryFire( CurTime() + self.Secondary.Delay );

		if ( SERVER ) then
			pPlayer:TraceHullAttack( vecSrc, traceHit.HitPos, Vector( -16, -16, -40 ), Vector( 16, 16, 16 ), self.Secondary.Damage, self.Primary.DamageType, self.Primary.Force, false );
		end

		self:ImpactEffect( traceHit );

		return

	end

	self.Weapon:EmitSound( self.Primary.Sound );

	self.Weapon:SendWeaponAnim( ACT_VM_MISSCENTER );
	pPlayer:LagCompensation( false );
	pPlayer:SetAnimation( PLAYER_ATTACK1 );

	self.Weapon:SetNextPrimaryFire( CurTime() + self.Secondary.Delay );
	self.Weapon:SetNextSecondaryFire( CurTime() + self.Secondary.Delay );

end

function SWEP:ImpactEffect( traceHit )

	if ( table.HasValue( MAT_ORGANIC, traceHit.MatType ) ) then
		util.ImpactTrace( traceHit, self.Owner );
		return;
	end

	local tr = traceHit
			local Pos1 = tr.HitPos + tr.HitNormal
			local Pos2 = tr.HitPos - tr.HitNormal
	util.Decal( "ManhackCut", Pos1, Pos2 )

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
