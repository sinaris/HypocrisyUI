local AddOn, NameSpace = ...

local Globals = NameSpace['Globals']
local Config = NameSpace['Config']
local Functions = NameSpace['Functions']

local ReputationBar = {}
NameSpace['ReputationBar'] = ReputationBar

local format = string.format
local floor = math.floor

local Colors = FACTION_BAR_COLORS

local OnEvent = function( self, event )
	if( not GetWatchedFactionInfo() ) then
		if( self:IsVisible() ) then
			self:Hide()
		end

		return
	else
		if( not self:IsVisible() ) then
			self:Show()
		end
	end

	local Name, ID, Min, Max, Value = GetWatchedFactionInfo()

	self['Status']:SetMinMaxValues( Min, Max )
	self['Status']:SetValue( Value )
	self['Status']:SetStatusBarColor( Colors[ID]['r'], Colors[ID]['g'], Colors[ID]['b'] )

	self['Text']:SetFormattedText( '%s / %s (%s%%)', Functions['Comma']( Value - Min ), Functions['Comma']( Max - Min ), floor( ( Value - Min ) / ( Max - Min ) * 100 ) )
end

local CreateBar = function()
	local Bar = CreateFrame( 'Frame', 'ReputationBar', UIParent )
	Bar:SetPoint( unpack( Config['ReputationBar']['Position'] ) )
	Bar:SetSize( Config['ReputationBar']['Width'], Config['ReputationBar']['Height'] )
	Bar:SetFrameStrata( 'BACKGROUND' )
	Bar:SetFrameLevel( 2 )
	Functions['CreateBackdrop']( Bar )

	Bar['Status'] = Globals['StatusBar']( '$parent_Status', Bar, Globals['Textures']['StatusBar'], { 0.5, 0, 0.75, 1.0 } )
	Bar['Status']:SetFrameLevel( Bar:GetFrameLevel() + 1 )
	Bar['Status']:SetMinMaxValues( 0, 100 )
	Bar['Status']:SetFrameLevel( 5 )
	Functions['SetInside']( Bar['Status'] )

	Bar['Status']['bg'] = Bar['Status']:CreateTexture( nil, 'BORDER' )
	Bar['Status']['bg']:SetAllPoints( Bar['Status'] )
	Bar['Status']['bg']:SetTexture( Globals['Textures']['StatusBar'] )
	Bar['Status']['bg']:SetAlpha( 0.10 )

	Bar['Text'] = Globals['FontString']( Bar['Status'], 'OVERLAY', Globals['Fonts']['Font'], 10, 'OUTLINE', 'CENTER', true )
	Bar['Text']:SetPoint( 'CENTER', Bar, 'CENTER', 0, 0 )

	Bar:RegisterEvent( 'UPDATE_FACTION' )
	Bar:RegisterEvent( 'PLAYER_ENTERING_WORLD' )
	Bar:SetScript( 'OnEvent', OnEvent )
	Bar:SetScript( 'OnMouseUp', function()
		ToggleCharacter( 'ReputationFrame' )
	end )
end

Globals['Init']['ReputationBar'] = function()
	if( not Config['ReputationBar']['Enable'] ) then
		return
	end

	CreateBar()
end
