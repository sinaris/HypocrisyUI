local AddOn, NameSpace = ...

local Globals = NameSpace['Globals']

local Functions = {}


local select = select
local format = string.format
local reverse = string.reverse
local match = string.match
local format = string.format
local gsub = string.gsub
local modf = math.modf
local floor = math.floor
local ceil = math.ceil

Functions['Kill'] = function( self )
	if( self.IsProtected ) then
		if( self:IsProtected() ) then
			error( 'Attempted to kill a protected object: <' .. self:GetName() .. '>' )
		end
	end

	if( self.UnregisterAllEvents ) then
		self:UnregisterAllEvents()
	end

	if( self.GetScript and self:GetScript( 'OnUpdate' ) ) then
		self:SetScript( 'OnUpdate', nil )
	end

	self.Show = Globals['Dummy']
	self:Hide()
end




Functions['CreateBackdrop'] = function( self, Border )
	if( not self ) then
		return
	end

	self:SetBackdrop( Globals['Backdrop'] )
	self:SetBackdropColor( 0, 0, 0, 1 )

	if( Border ) then
		self:SetBackdropBorderColor( 0.125, 0.125, 0.125, 1 )
	else
		self:SetBackdropBorderColor( 0, 0, 0, 1 )
	end
end

Functions['OuterBackdrop'] = function( self, Border )
	if( self['Backdrop'] ) then
		return
	end

	local Backdrop = CreateFrame( 'Frame', nil, self )
	Functions['CreateBackdrop']( self, Border )
	Functions['SetOutside']( Backdrop )

	if( self:GetFrameLevel() - 1 >= 0 ) then
		Backdrop:SetFrameLevel( self:GetFrameLevel() - 1 )
	else
		Backdrop:SetFrameLevel( 0 )
	end

	self['Backdrop'] = Backdrop
end

Functions['SetInside'] = function( self, Anchor, xOffset, yOffset )
	if( self:GetPoint() ) then
		self:ClearAllPoints()
	end

	self:SetPoint( 'TOPLEFT', Anchor or self:GetParent(), 'TOPLEFT', ( xOffset or 2 ), -( yOffset or 2 ) )
	self:SetPoint( 'BOTTOMRIGHT', Anchor or self:GetParent(), 'BOTTOMRIGHT', -( xOffset or 2 ), ( yOffset or 2 ) )
end

Functions['SetOutside'] = function( self, Anchor, xOffset, yOffset )
	if( self:GetPoint() ) then
		self:ClearAllPoints()
	end

	self:SetPoint( 'TOPLEFT', Anchor or self:GetParent(), 'TOPLEFT', -( xOffset or 2 ), ( yOffset or 2 ) )
	self:SetPoint( 'BOTTOMRIGHT', Anchor or self:GetParent(), 'BOTTOMRIGHT', ( xOffset or 2 ), -( yOffset or 2 ) )
end












Functions['RGBToHex'] = function( r, g, b )
	local r = r <= 1 and r >= 0 and r or 0
	local g = g <= 1 and g >= 0 and g or 0
	local b = b <= 1 and b >= 0 and b or 0

	return format( '|cff%02x%02x%02x', r * 255, g * 255, b * 255 )
end

Functions['Comma'] = function( num )
	local Left, Number, Right = match( num, '^([^%d]*%d)(%d*)(.-)$' )

	return Left .. reverse( gsub( reverse( Number ), '(%d%d%d)', '%1,' ) ) .. Right
end

--------------------------------------------------
-- ActionBars
--------------------------------------------------
Functions['ActionBars'] = {}

Functions['ActionBars']['ButtonSkin'] = function( self )
	if( self['SetHighlightTexture'] and not self['hover'] ) then
		local Hover = self:CreateTexture( 'Frame', nil, self )
		Hover:SetTexture( 1.0, 1.0, 1.0, 0.3 )
		Functions['SetInside']( Hover )
		self['hover'] = Hover
		self:SetHighlightTexture( Hover )
	end

	if( self['SetPushedTexture'] and not self['pushed'] ) then
		local Pushed = self:CreateTexture( 'Frame', nil, self )
		Pushed:SetTexture( 0.9, 0.8, 0.1, 0.3 )
		Functions['SetInside']( Pushed )
		self['pushed'] = Pushed
		self:SetPushedTexture( Pushed )
	end

	if( self['SetCheckedTexture'] and not self['checked'] ) then
		local Checked = self:CreateTexture( 'Frame', nil, self )
		Checked:SetTexture( 0, 1.0, 0, 0.3 )
		Functions['SetInside']( Checked )
		self['checked'] = Checked
		self:SetCheckedTexture( Checked )
	end

	local Cooldown = self:GetName() and _G[self:GetName() .. 'Cooldown']
	if( Cooldown ) then
		Cooldown:ClearAllPoints()
		Functions['SetInside']( Cooldown )
	end
end

NameSpace['Functions'] = Functions
