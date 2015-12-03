local AddOn, NameSpace = ...

local Globals = NameSpace['Globals']
local Config = NameSpace['Config']
local Functions = NameSpace['Functions']

local ExperienceBar = {}
NameSpace['ExperienceBar'] = ExperienceBar

local format = string.format
local floor = math.floor

local UnitXP, UnitXPMax = UnitXP, UnitXPMax
local GetXPExhaustion = GetXPExhaustion
local Bars = 20

local OnEvent = function( self, event )
	if( Globals['MyLevel'] == MAX_PLAYER_LEVEL ) then
		self:UnregisterAllEvents()
		self:Hide()

		return
	end

	if( event == 'PLAYER_UPDATE_RESTING' or event == 'PLAYER_ENTERING_WORLD' ) then
		local IsResting = IsResting()

		if( IsResting ) then
			self['RestedText']:Show()
		else
			self['RestedText']:Hide()
		end
	end

	local Current = UnitXP( 'player' )
	local Max = UnitXPMax( 'player' )
	local Rested = GetXPExhaustion()
	local IsRested = GetRestState()

	self['Status']:SetMinMaxValues( 0, Max )
	self['Status']:SetValue( Current )

	if( IsRested == 1 and Rested ) then
		self['Rested']:SetMinMaxValues( 0, Max )
		self['Rested']:SetValue( Rested + Current )
	else
		self['Rested']:SetValue( 0 )
	end

	self['Text']:SetFormattedText( '%s / %s (%s%%)', Functions['Comma']( Current ), Functions['Comma']( Max ), floor( Current / Max * 100 ) )
end

local OnEnter = function( self )
	local Current = UnitXP( 'player' )
	local Max = UnitXPMax( 'player' )
	local Rested = GetXPExhaustion()

	GameTooltip:SetOwner( self, 'ANCHOR_TOPLEFT', 0, 3 )
	GameTooltip:AddLine( format( XP .. ': %d / %d (%d%% - %d/%d)', Current, Max, Current / Max * 100, Bars - ( Bars * ( Max - Current ) / Max ), Bars ) )
	GameTooltip:AddLine( format( LEVEL_ABBR .. ': %d (%d%% - %d/%d)', Max - Current, ( Max - Current ) / Max * 100, 1 + Bars * ( Max - Current ) / Max, Bars ) )

	if( Rested ) then
		local Hex = Functions['RGBToHex']( 0, 0.4, 0.8 )

		GameTooltip:AddLine( format( '%s' .. TUTORIAL_TITLE26 .. ': +%d (%d%%)', Hex, Rested, Rested / Max * 100 ) )
	end

	GameTooltip:Show()
end

local CreateBar = function()
	local Bar = CreateFrame( 'Frame', 'ExperienceBar', UIParent )
	Bar:SetPoint( unpack( Config['ExperienceBar']['Position'] ) )
	Bar:SetSize( Config['ExperienceBar']['Width'], Config['ExperienceBar']['Height'] )
	Bar:SetFrameStrata( 'BACKGROUND' )
	Bar:SetFrameLevel( 2 )
	Functions['CreateBackdrop']( Bar )

	Bar['Status'] = Globals['StatusBar']( '$parent_Status', Bar, Globals['Textures']['StatusBar'], { 0.5, 0, 0.75, 1.0 } )
	Bar['Status']:SetFrameLevel( Bar:GetFrameLevel() + 1 )
	Bar['Status']:SetMinMaxValues( 0, 100 )
	Bar['Status']:SetFrameLevel( 5 )
	Functions['SetInside']( Bar['Status'] )

	Bar['Rested'] = Globals['StatusBar']( '$parent_Status', Bar, Globals['Textures']['StatusBar'], { 0, 0.4, 0.8, 1.0 } )
	Bar['Rested']:SetFrameLevel( Bar['Status']:GetFrameLevel() - 1 )
	Bar['Rested']:SetMinMaxValues( 0, 100 )
	Functions['SetInside']( Bar['Rested'] )

	Bar['Text'] = Globals['FontString']( Bar['Status'], 'OVERLAY', Globals['Fonts']['Font'], 10, 'OUTLINE', 'CENTER', true )
	Bar['Text']:SetPoint( 'CENTER', Bar, 'CENTER', 0, 0 )

	Bar['RestedText'] = Globals['FontString']( Bar['Status'], 'OVERLAY', Globals['Fonts']['Font'], 10, 'OUTLINE', 'CENTER', true )
	Bar['RestedText']:SetPoint( 'LEFT', Bar['Text'], 'RIGHT', 5, 0 )
	Bar['RestedText']:SetText( 'zZz..' )

	Bar:RegisterEvent( 'PLAYER_XP_UPDATE' )
	Bar:RegisterEvent( 'PLAYER_LEVEL_UP' )
	Bar:RegisterEvent( 'UPDATE_EXHAUSTION' )
	Bar:RegisterEvent( 'PLAYER_UPDATE_RESTING' )
	Bar:RegisterEvent( 'PLAYER_ENTERING_WORLD' )

	Bar:SetScript( 'OnEvent', OnEvent )
	Bar:SetScript( 'OnEnter', OnEnter )
	Bar:SetScript( 'OnLeave', GameTooltip_Hide )
end

Globals['Init']['ExperienceBar'] = function()
	if( not Config['ExperienceBar']['Enable'] ) then
		return
	end

	CreateBar()
end
