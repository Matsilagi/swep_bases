
local r_drawhud	= CreateClientConVar( "r_drawhud", 1, true, false )

function surface.ScreenScale( size )
	return size * ( ScrH() / 480.0 )
end

surface.SScale	= surface.ScreenScale

FgColor			= Color( 255, 220, 0, 200 )
BgColor			= Color( 0, 0, 0, 76 )

Panel			= Panel || {}
Panel.FgColor	= FgColor
Panel.BgColor	= BgColor

local function R_DrawHud( name )

	if ( r_drawhud:GetBool() ) then return end

	// So we can change weapons
	if (name == "CHudWeaponSelection") then return true end
	if (name == "CHudChat") then return true end
	if (name == "CHudGMod") then return true end

	return false;

end

hook.Add( "HUDShouldDraw", "R_DrawHud", R_DrawHud )

