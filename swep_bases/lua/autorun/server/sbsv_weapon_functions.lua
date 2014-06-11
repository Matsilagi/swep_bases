
local ents = {

	"crossbow_bolt",
	"npc_grenade_frag",
	"rpg_missile",

}

local function EntityTakeWeaponDamage( ent, dmginfo )

	local infl = dmginfo:GetInflictor()
	local att = dmginfo:GetAttacker()
	local amount	= dmginfo:GetDamage()

	local pClass 	= infl:GetClass()
	local pOwner 	= infl:GetOwner()

	if (infl:IsValid()) then

		if (table.HasValue( ents, pClass )) then

			if (infl.m_iDamage) then

				dmginfo:SetDamage( infl.m_iDamage )

			end

			if (pOwner && pOwner:IsValid()) then

				dmginfo:SetAttacker( pOwner )

			end

		end
		
	end

end

hook.Add( "EntityTakeDamage", "EntityTakeWeaponDamage", EntityTakeWeaponDamage )

