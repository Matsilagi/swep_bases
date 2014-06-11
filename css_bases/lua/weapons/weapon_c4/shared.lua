

if ( SERVER ) then

	if ( !util.IsValidModel( "models/weapons/v_eq_fraggrenade.mdl" ) ) then

		SWEP.m_bIsDisabled	= true

		return

	end

	AddCSLuaFile( "shared.lua" )

end

if ( CLIENT ) then

	SWEP.PrintName			= "#Cstrike_WPNHUD_C4"
	SWEP.Author				= "VALVe"
	SWEP.Slot				= 3
	SWEP.SlotPos			= 1
	SWEP.WepSelectFont		= "Icons2"
	SWEP.WepSelectLetter	= "C"

	SWEP.weapon				= {}
	SWEP.weapon.character	= "C"

	SWEP.ammo				= {}
	SWEP.ammo.font			= "CSweaponsSmall2"
	SWEP.ammo.character		= "d"

	killicon.AddFont( "sent_c4", "CSKillIcons", SWEP.weapon.character:lower(), Color( 255, 80, 0, 255 ) )

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


SWEP.Base				= "swep_frag_css_c4"
SWEP.Category			= "Counter-Strike: Source"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.DeployDelay			= 1

SWEP.ViewModelFOV		= 54
SWEP.ViewModelFlip		= false
SWEP.ViewModel			= "models/weapons/v_c4.mdl"
SWEP.WorldModel			= "models/weapons/w_c4.mdl"

SWEP.HoldType		= "grenade"

SWEP.Weight				= 2

SWEP.MaxPlayerSpeed			= 250
SWEP.WeaponPrice			= 300

// Weapon characteristics:
SWEP.Penetration			= 1
SWEP.Damage					= 50
SWEP.RangeModifier			= 0.99
SWEP.Bullets				= 1

SWEP.Timer				= 30

SWEP.Blacklist = {}
SWEP.Blacklist["sent_c4"] 	= true

PistolBurst = 0
Burst = 0
Zoom = 0
Silenced = 0
PistolSilenced = 0


/*---------------------------------------------------------
	Reload
---------------------------------------------------------*/
function SWEP:Reload()
         if CLIENT then return end
            if self.DetonationMode == 2 then return end



         if self.reloadtimer == 1 and self.SetNextReload == 1 then
         self.chargetimer = 5
         self.Owner:PrintMessage(4,"Charge set to 5 seconds.")
         self.Owner:EmitSound("weapons/c4/c4_click.wav")
         timer.Simple(0.2,self.NextReload1,self)
         self.SetNextReload = 0
self.Weapon:SendWeaponAnim( ACT_VM_DRAW )
         end

         if self.reloadtimer == 2 and self.SetNextReload == 1 then
         self.chargetimer = 10
         self.Owner:PrintMessage(4,"Charge set to 10 seconds.")
         self.Owner:EmitSound("weapons/c4/c4_click.wav")
         timer.Simple(0.2,self.NextReload2,self)
         self.SetNextReload = 0
self.Weapon:SendWeaponAnim( ACT_VM_DRAW )
         end

         if self.reloadtimer == 3 and self.SetNextReload == 1 then
         self.chargetimer = 20
         self.Owner:PrintMessage(4,"Charge set to 20 seconds.")
         self.Owner:EmitSound("weapons/c4/c4_click.wav")
         timer.Simple(0.2,self.NextReload3,self)
         self.SetNextReload = 0
self.Weapon:SendWeaponAnim( ACT_VM_DRAW )
         end

         if self.reloadtimer == 4 and self.SetNextReload == 1 then
         self.chargetimer = 60
         self.Owner:PrintMessage(4,"Charge set to 60 seconds.")
         self.Owner:EmitSound("weapons/c4/c4_click.wav")
         timer.Simple(0.2,self.NextReload4,self)
         self.SetNextReload = 0
self.Weapon:SendWeaponAnim( ACT_VM_DRAW )

         else return end


end

function SWEP:NextReload1()
         self.SetNextReload = 1
         self.reloadtimer = 2
end

function SWEP:NextReload2()
         self.SetNextReload = 1
         self.reloadtimer = 3

end

function SWEP:NextReload3()
         self.SetNextReload = 1
         self.reloadtimer = 4
end

function SWEP:NextReload4()
         self.SetNextReload = 1
         self.reloadtimer = 1
end

function SWEP:PrimaryAttack()

	if (not self:CanPrimaryAttack()) then return end

	local tr = {}
	tr.start = self.Owner:GetShootPos()
	tr.endpos = self.Owner:GetShootPos() + 100 * self.Owner:GetAimVector()
	tr.filter = {self.Owner}
	local trace = util.TraceLine(tr)

	if not trace.Hit then return end

	self.Weapon:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	self.Weapon:SetNextSecondaryFire(CurTime() + self.Primary.Delay)

	self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK)

	timer.Simple(3, function()
		if (not self.Owner or not self.Owner:Alive() or self.Weapon:GetOwner():GetActiveWeapon():GetClass() ~= "weapon_c4" or not IsFirstTimePredicted()) then return end

		self.Weapon:SendWeaponAnim(ACT_VM_SECONDARYATTACK)

		local tr = {}
		tr.start = self.Owner:GetShootPos()
		tr.endpos = self.Owner:GetShootPos() + 100 * self.Owner:GetAimVector()
		tr.filter = {self.Owner}
		local trace = util.TraceLine(tr)

		if not trace.Hit then
			timer.Simple(0.6, function()
				if self.Owner:GetAmmoCount(self.Primary.Ammo) > 0 then
					self.Weapon:SendWeaponAnim(ACT_VM_DRAW)
				else
					self.Weapon:Remove()
					self.Owner:ConCommand("lastinv")
				end
			end)

			return 
		end

		self.Owner:SetAnimation(PLAYER_ATTACK1)
		self:TakePrimaryAmmo(1)

		if (CLIENT) then return end
	
		C4 = ents.Create("sent_c4")
		C4:SetPos(trace.HitPos + trace.HitNormal)

		trace.HitNormal.z = -trace.HitNormal.z

		C4:SetAngles(trace.HitNormal:Angle() - Angle(90, 180, 0))

		C4.Owner = self.Owner
		C4.Timer = self.Timer
		C4:Spawn()

		if trace.Entity and trace.Entity:IsValid() and not self.Blacklist[trace.Entity:GetClass()] then
			if not trace.Entity:IsNPC() and not trace.Entity:IsPlayer() and trace.Entity:GetPhysicsObject():IsValid() then
				constraint.Weld(C4, trace.Entity)
			end
		else
			C4:SetMoveType(MOVETYPE_NONE)
		end

		timer.Simple(0.6, function()
			if (not self.Owner:Alive() or self.Weapon:GetOwner():GetActiveWeapon():GetClass() ~= "weapon_c4") or not IsFirstTimePredicted() then return end

			if self.Owner:GetAmmoCount(self.Primary.Ammo) > 0 then
				self.Weapon:SendWeaponAnim(ACT_VM_DRAW)
			else
				self.Weapon:Remove()
				self.Owner:ConCommand("lastinv")
			end
		end)
	end)
end

function SWEP:SecondaryAttack()
	self.Weapon:SetNextPrimaryFire(CurTime() + 0.1)
	self.Weapon:SetNextSecondaryFire(CurTime() + 0.1)

	if self.Timer == 30 then
		if (SERVER) then
			self.Owner:PrintMessage(HUD_PRINTTALK, "60 Seconds.")
		end

		self.Timer = 60
		self.Owner:EmitSound("C4.PlantSound")
	elseif self.Timer == 60 then
		if (SERVER) then
			self.Owner:PrintMessage(HUD_PRINTTALK, "120 Seconds.")
		end

		self.Timer = 120
		self.Owner:EmitSound("C4.PlantSound")
	elseif self.Timer == 120 then
		if (SERVER) then
			self.Owner:PrintMessage(HUD_PRINTTALK, "300 Seconds.")
		end

		self.Timer = 300
		self.Owner:EmitSound("C4.PlantSound")
	elseif self.Timer == 300 then
		if (SERVER) then
			self.Owner:PrintMessage(HUD_PRINTTALK, "30 Seconds.")
		end

		self.Timer = 30
		self.Owner:EmitSound("C4.PlantSound")
	end
end

function SWEP:Deploy()

	self.ActionDelay = (CurTime() + self.DeployDelay)

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

/*---------------------------------------------------------
   Name: SWEP:CanPrimaryAttack()
   Desc: Helper function for checking for no ammo.
---------------------------------------------------------*/
function SWEP:CanPrimaryAttack()

	if (self.Owner:GetAmmoCount(self.Primary.Ammo) <= 0) or (self.Owner:WaterLevel() > 2) then
		self.Weapon:SetNextPrimaryFire(CurTime() + 0.5)
		return false
	end

	if (not self.Owner:IsNPC()) and (self.Owner:KeyDown(IN_SPEED)) then
		self.Weapon:SetNextPrimaryFire(CurTime() + 0.5)
		return false
	end

	return true
end