
include('shared.lua')


SWEP.ClassName			= string.Strip( GetScriptPath(), "weapons/" )
SWEP.DrawAmmo			= true					// Should draw the default HL2 ammo counter
SWEP.DrawCrosshair		= true					// Should draw the default crosshair
SWEP.DrawWeaponInfoBox	= false					// Should draw the weapon info box
SWEP.BounceWeaponIcon   = false					// Should the weapon icon bounce?

// This is the font that's used to draw the death icons

// Override this in your SWEP to set the icon in the weapon selection
SWEP.weapon				= {}
SWEP.weapon.font		= "CSweaponsSmall"
SWEP.weapon.character	= "C"

SWEP.ammo				= {}
SWEP.ammo.font			= "CSTypeDeath"
SWEP.ammo.character		= "R"

killicon.AddFont( SWEP.ClassName, "CSKillIcons", SWEP.weapon.character, Color( 255, 80, 0, 255 ) )

OrangeDim				= Color( 255, 176, 0, 120 )

/*---------------------------------------------------------
	You can draw to the HUD here - it will only draw when
	the client has the weapon deployed..
---------------------------------------------------------*/
SWEP.DrawHUD = DrawCSSHud


/*---------------------------------------------------------
	Checks the objects before any action is taken
	This is to make sure that the entities haven't been removed
---------------------------------------------------------*/
function SWEP:DrawWeaponSelection( x, y, wide, tall, alpha )

	// Set us up the texture
	surface.SetDrawColor( color_transparent )
	surface.SetTextColor( 255, 220, 0, alpha )
	surface.SetFont( self.weapon.font )
	local w, h = surface.GetTextSize( self.weapon.character )

	// Draw that mother
	surface.SetTextPos( x + ( wide / 2 ) - ( w / 2 ),
						y + ( tall / 2 ) - ( h / 2 ) )
	surface.DrawText( self.weapon.character )

end


function SWEP:HUDShouldDraw( element )

	if (element == "CHudSuitPower") then return false end
	if (element == "CHudHealth") then return false end
	if (element == "CHudBattery") then return false end
	if (element == "CHudAmmo") then return false end
	if (element == "CHudSecondaryAmmo") then return false end

	return true;

end

