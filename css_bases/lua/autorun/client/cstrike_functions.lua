
function DrawCSSHud()

	local player			= LocalPlayer()
	local self				= player:GetActiveWeapon()

	if ( !self ) then return end
	if ( !self:IsValid() ) then return end
	if ( !player:Alive() ) then return end

	local text_font			= "Icons"
	surface.SetFont( text_font )

	local xpos	= surface.SScale( 16 )
	local ypos	= surface.SScale( 440 )

	local HEALTH			= "b"
	local ARMOR				= "a"

	local DIGIT_WIDTH		= surface.GetTextSize( "00" )
	local NUMBER_WIDTH		= surface.GetTextSize( "000" )

	local icon_xpos			= xpos			+ surface.SScale( 0 )
	local icon_ypos			= ypos			+ surface.SScale( 2 )
	draw.DrawText( HEALTH, text_font, icon_xpos, icon_ypos, OrangeDim )

	local digit_xpos		= xpos			+ surface.SScale( 0 )
	digit_xpos				= digit_xpos	+ surface.SScale( 34 )
	local digit_ypos		= ypos			+ surface.SScale( 2 )
	draw.DrawText( player:Health(), text_font, digit_xpos, digit_ypos, OrangeDim )

	local xpos				= surface.SScale( 156 )
	local ypos				= surface.SScale( 440 )

	local icon_xpos			= xpos			+ surface.SScale( 0 )
	local icon_ypos			= ypos			+ surface.SScale( 2 )
	draw.DrawText( ARMOR, text_font, icon_xpos, icon_ypos, OrangeDim )

	local digit_xpos		= xpos			+ surface.SScale( 0 )
	digit_xpos				= digit_xpos	+ surface.SScale( 34 )
	local digit_ypos		= ypos			+ surface.SScale( 2 )
	draw.DrawText( player:Armor(), text_font, digit_xpos, digit_ypos, OrangeDim )

	local ADJUSTED_WIDTH	= DIGIT_WIDTH + surface.SScale( 2 )
	local xpos				= ScrW()-surface.SScale( 156 ) - ADJUSTED_WIDTH
	local ypos				= surface.SScale( 440 )

	if ( self.Primary.ClipSize > -1 ) then

		local CLIP_WIDTH	= surface.GetTextSize( self.Weapon:Clip1() )
		local digit_xpos	= xpos			+ surface.SScale( 27 )
		digit_xpos			= digit_xpos	+ NUMBER_WIDTH - CLIP_WIDTH
		local digit_ypos	= ypos			+ surface.SScale( 2 )
		draw.DrawText( self.Weapon:Clip1(),	text_font, digit_xpos, digit_ypos, OrangeDim )

	end

	if ( self.Primary.ClipSize > -1 || self.Base == "swep_grenade" ) then

		local AMMO_WIDTH	= surface.GetTextSize( self:Ammo1() )
		local digit2_xpos	= xpos			+ surface.SScale( 82 )
		digit2_xpos			= digit2_xpos	+ NUMBER_WIDTH - AMMO_WIDTH
		local digit2_ypos	= ypos			+ surface.SScale( 2 )
		draw.DrawText( self:Ammo1(), text_font, digit2_xpos, digit2_ypos, OrangeDim )

	end

	if ( self.Primary.ClipSize > -1 ) then

		local bar_xpos		= xpos			+ surface.SScale( 72 )
		local bar_ypos		= ypos			+ surface.SScale( 9 )
		local bar_height	= surface.SScale( 20 )
		local bar_width		= surface.SScale( 2 )
		surface.SetDrawColor( OrangeDim.r, OrangeDim.g, OrangeDim.b, OrangeDim.a )
		surface.DrawRect( bar_xpos, bar_ypos, bar_width, bar_height )

	end

	if ( self.ammo && self.ammo.character ) then

		local icon_xpos		= xpos			+ surface.SScale( 130 )
		local icon_ypos		= ypos			+ surface.SScale( 10 )
		draw.DrawText( self.ammo.character,	self.ammo.font, icon_xpos, icon_ypos, OrangeDim )

	end

end

