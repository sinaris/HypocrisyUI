local AddOn, NameSpace = ...

local Globals = NameSpace['Globals']
local Config = NameSpace['Config']
local Functions = NameSpace['Functions']

local ActionBars = {}
NameSpace['ActionBars'] = ActionBars

local _G = _G

local format, gsub, sub = string.format, string.gsub, string.sub

local FlyoutButtons = 0

local DisableBlizzard = function()
	SetCVar( 'alwaysShowActionBars', 1 )

	for _, Frame in pairs( {
		MainMenuBar,
		MainMenuBarArtFrame,
		OverrideActionBar,
		PossessBarFrame,
		PetActionBarFrame,
		IconIntroTracker,
		ShapeshiftBarLeft,
		ShapeshiftBarMiddle,
		ShapeshiftBarRight,
		TalentMicroButtonAlert,
	} ) do
		Frame:UnregisterAllEvents()
		Frame.ignoreFramePositionManager = true
		Frame:SetParent( Globals['HiddenFrame'] )
	end

	for i = 1, 6 do
		local Button = _G['OverrideActionBarButton' .. i]

		Button:UnregisterAllEvents()
		Button:SetAttribute( 'statehidden', true )
	end

	hooksecurefunc( 'TalentFrame_LoadUI', function()
		PlayerTalentFrame:UnregisterEvent( 'ACTIVE_TALENT_GROUP_CHANGED' )
	end )

	hooksecurefunc( 'ActionButton_OnEvent', function( self, event )
		if( event == 'PLAYER_ENTERING_WORLD' ) then
			self:UnregisterEvent( 'ACTIONBAR_SHOWGRID' )
			self:UnregisterEvent( 'ACTIONBAR_HIDEGRID' )
			self:UnregisterEvent( 'PLAYER_ENTERING_WORLD' )
		end
	end )

	MainMenuBar.slideOut.IsPlaying = function()
		return true
	end
end

local SkinButtons = function( self )
	local Name = self:GetName()
	local Action = self['action']
	local Button = self
	local Icon = _G[Name .. 'Icon']
	local Count = _G[Name .. 'Count']
	local Flash = _G[Name .. 'Flash']
	local HotKey = _G[Name .. 'HotKey']
	local Border = _G[Name .. 'Border']
	local ButtonName = _G[Name .. 'Name']
	local Normal  = _G[Name .. 'NormalTexture']
	local ButtonBackground = _G[Name .. 'FloatingBG']

	Flash:SetTexture( '' )
	Button:SetNormalTexture( '' )

	Count:ClearAllPoints()
	Count:SetPoint( 'BOTTOMRIGHT', 0, 2 )
	Count:SetFont( Globals['Fonts']['Font'], 10, nil )
	Count:SetShadowOffset( 0, 0 )

	HotKey:ClearAllPoints()
	HotKey:SetPoint( 'TOPRIGHT', 0, -2 )

	if( Border and Button['IsSkinned'] ) then
		Border:SetTexture( '' )

		if( Border:IsShown() ) then
			Button:SetBackdropBorderColor( 0.08, 0.70, 0 )
		else
			-- KEEP THIS FOR LATER USE!!!
			-- Button:SetBackdropBorderColor( unpack( Globals['Colors']['General']['Border'] ) )
		end
	end

	if( ButtonName and Normal and Config['ActionBars']['ShowMacroText'] ) then
		local String = GetActionText( Action )

		if( String ) then
			local Text = sub( String, 1, 5 )
			ButtonName:SetText( Text )
			ButtonName:SetShadowOffset( 0, 0 )
		end
	end

	if( Button['IsSkinned'] ) then
		return
	end

	if( ButtonName ) then
		if( Config['ActionBars']['ShowMacroText'] ) then
			ButtonName:ClearAllPoints()
			ButtonName:SetPoint( 'BOTTOM', 1, 1 )
			ButtonName:SetFont( Globals['Fonts']['Font'], 10, nil )
			ButtonName:SetShadowOffset( 0, 0 )
		else
			ButtonName:SetText( '' )
			Functions['Kill']( ButtonName )
		end
	end

	if( ButtonBackground ) then
		Functions['Kill']( ButtonBackground )
	end

	if( Config['ActionBars']['ShowHotKeyText'] ) then
		HotKey:SetFont( Globals['Fonts']['Font'], 10, nil )
		HotKey:SetShadowOffset( 0, 0 )
		HotKey['ClearAllPoints'] = Globals['Dummy']
		HotKey['SetPoint'] = Globals['Dummy']
	else
		HotKey:SetText( '' )
		Functions['Kill']( HotKey )
	end

	if( Name:match( 'Extra' ) ) then
		Button['Pushed'] = true
	end

	Functions['OuterBackdrop']( Button )
	Functions['SetOutside']( Button['Backdrop'], 0, 0 )

	Button:UnregisterEvent( 'ACTIONBAR_SHOWGRID' )
	Button:UnregisterEvent( 'ACTIONBAR_HIDEGRID' )

	if( Config['ActionBars']['InvertedTextures'] ) then
		if( Button['Gradient'] ) then
			return
		end

		local Gradient = CreateFrame( 'Frame', nil, Button )
		Gradient:SetPoint( 'CENTER', Button, 'CENTER', 0, 0 )
		Gradient:SetAllPoints()
		Gradient:SetFrameStrata( Button:GetFrameStrata() )
		Gradient:SetFrameLevel( Button:GetFrameLevel() + 2 )

		Gradient['Texture'] = Gradient:CreateTexture( nil, 'OVERLAY' )
		Gradient['Texture']:SetTexture( Globals['Textures']['Inverted'] )
		Functions['SetInside']( Gradient['Texture'], Gradient )
		Gradient['Texture']:SetAlpha( 0.9 )

		Button['Gradient'] = Gradient
	end

	if( Config['ActionBars']['GlossTextures'] ) then
		if( Button['Gloss'] ) then
			return
		end

		local Glossy = CreateFrame( 'Frame', nil, Button )
		Glossy:SetPoint( 'CENTER', Button, 'CENTER', 0, 0 )
		Glossy:SetAllPoints()
		Glossy:SetFrameStrata( Button:GetFrameStrata() )
		Glossy:SetFrameLevel( Button:GetFrameLevel() + 2 )

		Glossy['Texture'] = Glossy:CreateTexture( nil, 'OVERLAY' )
		Glossy['Texture']:SetTexture( Globals['Textures']['Gloss'] )
		Functions['SetInside']( Glossy['Texture'], Glossy )
		Glossy['Texture']:SetAlpha( 0.4 )

		Button['Gloss'] = Glossy
	end

	Icon:SetTexCoord( unpack( Globals['TextureCoords'] ) )
	Functions['SetInside']( Icon )
	Icon:SetDrawLayer( 'BACKGROUND', 7 )

	if( Normal ) then
		Normal:ClearAllPoints()
		Normal:SetPoint( 'TOPLEFT' )
		Normal:SetPoint( 'BOTTOMRIGHT' )

		if( Button:GetChecked() ) then
			ActionButton_UpdateState( Button )
		end
	end

	Functions['ActionBars']['ButtonSkin']( Button )

	Button['IsSkinned'] = true
end

local SkinFlyoutButtons = function()
	for i = 1, FlyoutButtons do
		local Button = _G['SpellFlyoutButton' .. i]

		if( Button and not Button['IsSkinned'] ) then
			SkinButtons( Button )

			if( Button:GetChecked() ) then
				Button:SetChecked( nil )
			end

			Button['IsSkinned'] = true
		end
	end
end

local StyleFlyout = function( self )
	if( not self.FlyoutArrow ) then
		return
	end

	local HB = SpellFlyoutHorizontalBackground
	local VB = SpellFlyoutVerticalBackground
	local BE = SpellFlyoutBackgroundEnd

	if( self.FlyoutBorder ) then
		self.FlyoutBorder:SetAlpha( 0 )
		self.FlyoutBorderShadow:SetAlpha( 0 )
	end

	HB:SetAlpha( 0 )
	VB:SetAlpha( 0 )
	BE:SetAlpha( 0 )

	for i = 1, GetNumFlyouts() do
		local ID = GetFlyoutID( i )
		local _, _, NumSlots, IsKnown = GetFlyoutInfo( ID )

		if( IsKnown ) then
			FlyoutButtons = NumSlots
			break
		end
	end

	SkinFlyoutButtons()
end

local UpdateHotKeys = function( self, actionButtonType )
	local HotKey = _G[self:GetName() .. 'HotKey']
	local Text = HotKey:GetText()
	local Indicator = _G['RANGE_INDICATOR']

	if( not Text ) then
		return
	end

	Text = gsub( Text, '(s%-)', 'S' )
	Text = gsub( Text, '(a%-)', 'A' )
	Text = gsub( Text, '(c%-)', 'C' )
	Text = gsub( Text, '(Mouse Button )', 'M' )
	Text = gsub( Text, KEY_MOUSEWHEELDOWN , 'MDn' )
	Text = gsub( Text, KEY_MOUSEWHEELUP , 'MUp' )
	Text = gsub( Text, KEY_BUTTON3, 'M3' )
	Text = gsub( Text, KEY_BUTTON4, 'M4' )
	Text = gsub( Text, KEY_BUTTON5, 'M5' )
	Text = gsub( Text, KEY_NUMPAD0, 'N0' )
	Text = gsub( Text, KEY_NUMPAD1, 'N1' )
	Text = gsub( Text, KEY_NUMPAD2, 'N2' )
	Text = gsub( Text, KEY_NUMPAD3, 'N3' )
	Text = gsub( Text, KEY_NUMPAD4, 'N4' )
	Text = gsub( Text, KEY_NUMPAD5, 'N5' )
	Text = gsub( Text, KEY_NUMPAD6, 'N6' )
	Text = gsub( Text, KEY_NUMPAD7, 'N7' )
	Text = gsub( Text, KEY_NUMPAD8, 'N8' )
	Text = gsub( Text, KEY_NUMPAD9, 'N9' )
	Text = gsub( Text, KEY_NUMPADDECIMAL, 'Nu.' )
	Text = gsub( Text, KEY_NUMPADDIVIDE, 'Nu/' )
	Text = gsub( Text, KEY_NUMPADMINUS, 'Nu-' )
	Text = gsub( Text, KEY_NUMPADMULTIPLY, 'Nu*' )
	Text = gsub( Text, KEY_NUMPADPLUS, 'Nu+' )
	Text = gsub( Text, KEY_NUMLOCK, 'NuL' )
	Text = gsub( Text, KEY_PAGEUP, 'PU' )
	Text = gsub( Text, KEY_PAGEDOWN, 'PD' )
	Text = gsub( Text, KEY_SPACE, 'SpB' )
	Text = gsub( Text, KEY_INSERT, 'Ins' )
	Text = gsub( Text, KEY_HOME, 'Hm' )
	Text = gsub( Text, KEY_DELETE, 'Del' )
	Text = gsub( Text, KEY_INSERT_MAC, 'Hlp' )

	if( HotKey:GetText() == Indicator ) then
		HotKey:SetText( '' )
	else
		HotKey:SetText( Text )
	end
end

local SkinPetStanceButtons = function( Normal, Button, Icon, Name, Pet )
	if( Button['IsSkinned'] ) then
		return
	end

	if( Pet ) then
		Button:SetSize( Config['ActionBars']['SizePetButtons'], Config['ActionBars']['SizePetButtons'] )
	else
		Button:SetSize( Config['ActionBars']['SizeStanceButtons'], Config['ActionBars']['SizeStanceButtons'] )
	end

	Functions['OuterBackdrop']( Button )
	Functions['SetOutside']( Button['Backdrop'], 0, 0 )

	-- KEEP THIS FOR LATER USE!!!
	-- Button:SetBackdropBorderColor( unpack( Globals['Colors']['General']['Border'] ) )

	if( Config['ActionBars']['InvertedTextures'] ) then
		if( Button['Gradient'] ) then
			return
		end

		local Gradient = CreateFrame( 'Frame', nil, Button )
		Gradient:SetPoint( 'CENTER', Button, 'CENTER', 0, 0 )
		Gradient:SetAllPoints()
		Gradient:SetFrameStrata( Button:GetFrameStrata() )
		Gradient:SetFrameLevel( Button:GetFrameLevel() + 2 )

		Gradient['Texture'] = Gradient:CreateTexture( nil, 'OVERLAY' )
		Gradient['Texture']:SetTexture( Globals['Textures']['Inverted'] )
		Functions['SetInside']( Gradient['Texture'], Gradient )
		Gradient['Texture']:SetAlpha( 0.9 )

		Button['Gradient'] = Gradient
	end

	if( Config['ActionBars']['ActionBars_GlossTextures'] ) then
		if( Button['Gloss'] ) then
			return
		end

		local Glossy = CreateFrame( 'Frame', nil, Button )
		Glossy:SetPoint( 'CENTER', Button, 'CENTER', 0, 0 )
		Glossy:SetAllPoints()
		Glossy:SetFrameStrata( Button:GetFrameStrata() )
		Glossy:SetFrameLevel( Button:GetFrameLevel() + 2 )

		Glossy['Texture'] = Glossy:CreateTexture( nil, 'OVERLAY' )
		Glossy['Texture']:SetTexture( Globals['Textures']['Gloss'] )
		Functions['SetInside']( Glossy['Texture'], Glossy )
		Glossy['Texture']:SetAlpha( 0.4 )

		Button['Gloss'] = Glossy
	end

	Icon:SetTexCoord( unpack( Globals['TextureCoords'] ) )
	Functions['SetInside']( Icon )
	Icon:SetDrawLayer( 'BACKGROUND', 7 )

	if( Pet ) then
		if( Config['ActionBars']['SizePetButtons'] < 30 ) then
			local AutoCast = _G[Name .. 'AutoCastable']
			AutoCast:SetAlpha( 0 )
		end

		local Shine = _G[Name .. 'Shine']
		Shine:ClearAllPoints()
		Shine:SetPoint( 'CENTER', Button, 0, 0 )
		Shine:SetSize( Config['ActionBars']['SizePetButtons'], Config['ActionBars']['SizePetButtons'] )
	end

	Button:SetNormalTexture( '' )
	Button.SetNormalTexture = Globals['Dummy']

	local Flash = _G[Name .. 'Flash']
	Flash:SetTexture( '' )

	if( Normal ) then
		Normal:ClearAllPoints()
		Normal:SetPoint( 'TOPLEFT' )
		Normal:SetPoint( 'BOTTOMRIGHT' )
	end

	Functions['ActionBars']['ButtonSkin']( Button )

	Button['IsSkinned'] = true
end

local SkinPetButtons = function()
	for i = 1, NUM_PET_ACTION_SLOTS do
		local Name = 'PetActionButton' .. i
		local Button  = _G[Name]
		local Icon  = _G[Name .. 'Icon']
		local Normal  = _G[Name .. 'NormalTexture2']

		SkinPetStanceButtons( Normal, Button, Icon, Name, true )
	end
end

local SkinStanceButtons = function()
	for i = 1, NUM_STANCE_SLOTS do
		local Name = 'StanceButton' .. i
		local Button = _G[Name]
		local Icon = _G[Name .. 'Icon']
		local Normal = _G[Name .. 'NormalTexture']

		SkinPetStanceButtons( Normal, Button, Icon, Name )
	end
end

local UpdatePetBar = function( self, ... )
	if( InCombatLockdown() ) then
		return
	end

	local ButtonName, PetActionButton, PetActionBackdrop, PetActionIcon, PetAutoCastableTexture, PetAutoCastShine, HotKey

	for i = 1, NUM_PET_ACTION_SLOTS, 1 do
		local Name, Subtext, Texture, IsToken, IsActive, AutoCastAllowed, AutoCastEnabled = GetPetActionInfo( i )

		ButtonName = 'PetActionButton' .. i
		PetActionButton = _G[ButtonName]
		PetActionBackdrop = PetActionButton['Backdrop']
		PetActionIcon = _G[ButtonName .. 'Icon']
		PetAutoCastableTexture = _G[ButtonName .. 'AutoCastable']
		PetAutoCastShine = _G[ButtonName .. 'Shine']
		HotKey = _G[ButtonName .. 'HotKey']

		if( not IsToken ) then
			PetActionIcon:SetTexture( Texture )
			PetActionButton.tooltipName = Name
		else
			PetActionIcon:SetTexture( _G[Texture] )
			PetActionButton.tooltipName = _G[Name]
		end

		PetActionButton.isToken = IsToken
		PetActionButton.tooltipSubtext = Subtext

		if( IsActive ) then
			PetActionButton:SetChecked( true )

			if( PetActionBackdrop ) then
				PetActionBackdrop:SetBackdropBorderColor( Globals['Colors']['Class'][Globals.MyClass][1], Globals['Colors']['Class'][Globals.MyClass][2], Globals['Colors']['Class'][Globals.MyClass][3] )
			end

			if( IsPetAttackAction( i ) ) then
				PetActionButton_StartFlash( PetActionButton )
			end

			PetActionButton:GetCheckedTexture():SetAlpha( 0.00001 )
		else
			PetActionButton:SetChecked( false )

			if( PetActionBackdrop ) then
				PetActionBackdrop:SetBackdropBorderColor( unpack( Globals['Colors']['General']['Border'] ) )
			end

			if( IsPetAttackAction( i ) ) then
				PetActionButton_StopFlash( PetActionButton )
			end
		end

		if( AutoCastAllowed ) then
			PetAutoCastableTexture:Show()
		else
			PetAutoCastableTexture:Hide()
		end

		if( AutoCastEnabled ) then
			AutoCastShine_AutoCastStart( PetAutoCastShine )
		else
			AutoCastShine_AutoCastStop( PetAutoCastShine )
		end

		if( Texture ) then
			if( GetPetActionSlotUsable( i ) ) then
				SetDesaturation( PetActionIcon, nil )
			else
				SetDesaturation( PetActionIcon, 1 )
			end
			PetActionIcon:Show()
		else
			PetActionIcon:Hide()
		end

		if( not PetHasActionBar() and Texture and Name ~= 'PET_ACTION_FOLLOW' ) then
			PetActionButton_StopFlash( PetActionButton )
			SetDesaturation( PetActionIcon, 1 )
			PetActionButton:SetChecked( false )
		end

		if( Config['ActionBars']['ShowHotKeyText'] ) then
			HotKey:ClearAllPoints()
			HotKey:SetPoint( 'BOTTOM', -7, 3 )
			HotKey:SetFont( Globals['Fonts']['Font'], 10, nil )
			HotKey:SetShadowOffset( 0, 0 )
			HotKey['ClearAllPoints'] = Globals['Dummy']
			HotKey['SetPoint'] = Globals['Dummy']
		else
			HotKey:SetText( '' )
			Functions['Kill']( HotKey )
		end
	end
end

local UpdateStanceBar = function( self, ... )
	if( InCombatLockdown() ) then
		return
	end

	local NumForms = GetNumShapeshiftForms()
	local Texture, Name, IsActive, IsCastable, Button, Icon, Cooldown, Start, Duration, Enable

	if( NumForms == 0 ) then
		StanceBar:SetAlpha( 0 )
	else
		StanceBar:SetAlpha( 1 )
		if( Config['ActionBars']['VerticalStanceBars'] ) then
			StanceBar:SetSize( Config['ActionBars']['SizeStanceButtons'] + ( Config['ActionBars']['SpacingStanceButtons'] * 2 ), ( Config['ActionBars']['SizeStanceButtons'] * NumForms ) + ( Config['ActionBars']['SpacingStanceButtons'] * ( NumForms + 1 ) ) )
		else
			StanceBar:SetSize( ( Config['ActionBars']['SizeStanceButtons'] * NumForms ) + ( Config['ActionBars']['SpacingStanceButtons'] * ( NumForms + 1 ) ), Config['ActionBars']['SizeStanceButtons'] + ( Config['ActionBars']['SpacingStanceButtons'] * 2 ) )
		end

		for i = 1, NUM_STANCE_SLOTS do
			local ButtonName = 'StanceButton' .. i

			Button = _G[ButtonName]
			Icon = _G[ButtonName .. 'Icon']

			Button:SetSize( Config['ActionBars']['SizeStanceButtons'], Config['ActionBars']['SizeStanceButtons'] )

			if( i <= NumForms ) then
				Texture, Name, IsActive, IsCastable = GetShapeshiftFormInfo( i )

				if( not Icon ) then
					return
				end

				Icon:SetTexture( Texture )
				Cooldown = _G[ButtonName .. 'Cooldown']

				if( Texture ) then
					Cooldown:SetAlpha( 1 )
				else
					Cooldown:SetAlpha( 0 )
				end

				Start, Duration, Enable = GetShapeshiftFormCooldown( i )
				CooldownFrame_SetTimer( Cooldown, Start, Duration, Enable )

				if( IsActive ) then
					StanceBarFrame.lastSelected = Button:GetID()
					Button:SetChecked( true )
				else
					Button:SetChecked( false )
				end

				if( IsCastable ) then
					Icon:SetVertexColor( 1.0, 1.0, 1.0 )
				else
					Icon:SetVertexColor( 0.4, 0.4, 0.4 )
				end
			end
		end
	end
end

local ShowGrid = function()
	for i = 1, NUM_ACTIONBAR_BUTTONS do
		local Button

		Button = _G[format( 'ActionButton%d', i )]
		Button:SetAttribute( 'showgrid', 1 )
		Button:SetAttribute( 'statehidden', true )
		Button:Show()

		ActionButton_ShowGrid( Button )

		Button = _G[format( 'MultiBarRightButton%d', i )]
		Button:SetAttribute( 'showgrid', 1 )
		Button:SetAttribute( 'statehidden', true )
		Button:Show()

		ActionButton_ShowGrid( Button )

		Button = _G[format( 'MultiBarBottomRightButton%d', i )]
		Button:SetAttribute( 'showgrid', 1 )
		Button:SetAttribute( 'statehidden', true )
		Button:Show()

		ActionButton_ShowGrid( Button )

		Button = _G[format( 'MultiBarLeftButton%d', i )]
		Button:SetAttribute( 'showgrid', 1 )
		Button:SetAttribute( 'statehidden', true )
		Button:Show()

		ActionButton_ShowGrid( Button )

		Button = _G[format( 'MultiBarBottomLeftButton%d', i )]
		Button:SetAttribute( 'showgrid', 1 )
		Button:SetAttribute( 'statehidden', true )
		Button:Show()

		ActionButton_ShowGrid( Button )
	end
end

local UpdateRangeColor = function( self )
	local Name = self:GetName()
	local Icon = _G[Name .. 'Icon']
	local NormalTexture = _G[Name .. 'NormalTexture']
	local ID = self.action
	local IsUsable, NotEnoughMana = IsUsableAction( ID )
	local HasRange = ActionHasRange( ID )
	local InRange = IsActionInRange( ID )

	if( IsUsable ) then
		if( HasRange and InRange == false ) then
			Icon:SetVertexColor( 0.8, 0.1, 0.1 )
			NormalTexture:SetVertexColor( 0.8, 0.1, 0.1 )
		else
			Icon:SetVertexColor( 1.0, 1.0, 1.0 )
			NormalTexture:SetVertexColor( 1.0, 1.0, 1.0 )
		end
	elseif( NotEnoughMana ) then
		Icon:SetVertexColor( 0.1, 0.3, 1.0 )
		NormalTexture:SetVertexColor( 0.1, 0.3, 1.0 )
	else
		Icon:SetVertexColor( 0.3, 0.3, 0.3 )
		NormalTexture:SetVertexColor( 0.3, 0.3, 0.3 )
	end
end

local OnUpdateRangeColor = function( self, elapsed )
	if( not self.rangeTimer ) then
		return
	end

	UpdateRangeColor( self )
end

local AddHooks = function()
	hooksecurefunc( 'ActionButton_Update', SkinButtons )
	hooksecurefunc( 'ActionButton_UpdateFlyout', StyleFlyout )
	hooksecurefunc( 'SpellButton_OnClick', StyleFlyout )
	hooksecurefunc( 'ActionButton_OnUpdate', OnUpdateRangeColor )
	hooksecurefunc( 'ActionButton_Update', UpdateRangeColor )
	hooksecurefunc( 'ActionButton_UpdateUsable', UpdateRangeColor )
	hooksecurefunc( 'ActionButton_UpdateHotkeys', UpdateHotKeys )
end

local CreateBackground = function()
	local Bar1 = CreateFrame( 'Frame', 'ActionBar1', Globals['PetUIFrame'], 'SecureHandlerStateTemplate' )
	Bar1:SetPoint( 'BOTTOM', UIParent, 'BOTTOM', 0, 14 )
	Bar1:SetSize( ( Config['ActionBars']['SizeMainButtons'] * Config['ActionBars']['NumMainButtons'] ) + ( Config['ActionBars']['SpacingMainButtons'] * ( Config['ActionBars']['NumMainButtons'] + 1 ) ) + 2, ( Config['ActionBars']['SizeMainButtons'] * Config['ActionBars']['NumBottomRows'] ) + ( Config['ActionBars']['SpacingMainButtons'] * ( Config['ActionBars']['NumBottomRows'] + 1 ) ) + 2 )
	Bar1:SetFrameStrata( 'BACKGROUND' )
	Bar1:SetFrameLevel( 1 )

	local Bar2 = CreateFrame( 'Frame', 'ActionBar2', Globals['PetUIFrame'], 'SecureHandlerStateTemplate' )
	Bar2:SetAllPoints( Bar1 )

	local Bar3 = CreateFrame( 'Frame', 'ActionBar3', Globals['PetUIFrame'], 'SecureHandlerStateTemplate' )
	Bar3:SetAllPoints( Bar1 )

	local Bar4 = CreateFrame( 'Frame', 'ActionBar4', Globals['PetUIFrame'], 'SecureHandlerStateTemplate' )
	Bar4:SetAllPoints( Bar1 )

	local SplitLeft = CreateFrame( 'Frame', 'SplitBarLeft', Globals['PetUIFrame'], 'SecureHandlerStateTemplate' )
	SplitLeft:SetPoint( 'BOTTOMRIGHT', Bar1, 'BOTTOMLEFT', -3, 0 )
	SplitLeft:SetSize( ( Config['ActionBars']['SizeSplitButtons'] * 3 ) + ( Config['ActionBars']['SpacingSplitButtons'] * 4 ) + 2, ( Config['ActionBars']['SizeSplitButtons'] * Config['ActionBars']['NumBottomRows'] ) + ( Config['ActionBars']['SpacingSplitButtons'] * ( Config['ActionBars']['NumBottomRows'] + 1 ) ) + 2 )
	SplitLeft:SetFrameStrata( 'BACKGROUND' )
	SplitLeft:SetFrameLevel( 1 )

	local SplitRight = CreateFrame( 'Frame', 'SplitBarRight', Globals['PetUIFrame'], 'SecureHandlerStateTemplate' )
	SplitRight:SetPoint( 'BOTTOMLEFT', Bar1, 'BOTTOMRIGHT', 3, 0 )
	SplitRight:SetSize( ( Config['ActionBars']['SizeSplitButtons'] * 3 ) + ( Config['ActionBars']['SpacingSplitButtons'] * 4 ) + 2, ( Config['ActionBars']['SizeSplitButtons'] * Config['ActionBars']['NumBottomRows'] ) + ( Config['ActionBars']['SpacingSplitButtons'] * ( Config['ActionBars']['NumBottomRows'] + 1 ) ) + 2 )
	SplitRight:SetFrameStrata( 'BACKGROUND' )
	SplitRight:SetFrameLevel( 1 )

	local RightActionBar = CreateFrame( 'Frame', 'RightActionBar', Globals['PetUIFrame'], 'SecureHandlerStateTemplate' )
	RightActionBar:SetPoint( 'RIGHT', UIParent, 'RIGHT', 3, 0 )
	RightActionBar:SetSize( ( Config['ActionBars']['SizeRightButtons'] * Config['ActionBars']['NumRightButtons'] ) + ( Config['ActionBars']['SpacingRightButtons'] * ( Config['ActionBars']['NumRightButtons'] + 1 ) ) + 2, ( Config['ActionBars']['SizeRightButtons'] * 2 ) + ( Config['ActionBars']['SpacingRightButtons'] * 3 ) + 2 )
	RightActionBar:SetFrameStrata( 'BACKGROUND' )
	RightActionBar:SetFrameLevel( 1 )

	local PetBar = CreateFrame( 'Frame', 'PetActionBar', Globals['PetUIFrame'], 'SecureHandlerStateTemplate' )
	PetBar:SetPoint( 'BOTTOMRIGHT', RightActionBar, 'TOPRIGHT', 0, 3 )
	if( Config['ActionBars']['VerticalRightBars'] ) then
		PetBar:SetSize( ( Config['ActionBars']['SizePetButtons'] + Config['ActionBars']['SpacingPetButtons'] * 2 ) + 2, ( Config['ActionBars']['SizePetButtons'] * NUM_PET_ACTION_SLOTS + Config['ActionBars']['SpacingPetButtons'] * 11 ) + 2 )
	else
		PetBar:SetSize( ( Config['ActionBars']['SizePetButtons'] * NUM_PET_ACTION_SLOTS + Config['ActionBars']['SpacingPetButtons'] * 11 ) + 2, ( Config['ActionBars']['SizePetButtons'] + Config['ActionBars']['SpacingPetButtons'] * 2 ) + 2 )
	end
	PetBar:SetFrameStrata( 'BACKGROUND' )
	PetBar:SetFrameLevel( 1 )

	--Functions['CreateBackdrop']( Bar1 )
	--Functions['CreateBackdrop']( SplitLeft )
	--Functions['CreateBackdrop']( SplitRight )
	--Functions['CreateBackdrop']( RightActionBar )
	--Functions['CreateBackdrop']( PetBar )
end

local CreateBar1 = function()
	local Bar1 = ActionBar1

	local Druid, Warrior, Priest, Rogue, Warlock, Monk = '', '', '', '', '', ''

	if( Config['ActionBars']['SwitchBarOnStance'] ) then
		if( Config['ActionBars']['OwnWarriorStanceBar'] ) then
			Warrior = "[stance:1] 7; [stance:2] 8; [stance:3] 9;"
		end

		if( Config['ActionBars']['OwnShadowDanceBar'] ) then
			Rogue = "[stance:2] 10; [bonusbar:1] 7;"
		else
			Rogue = "[bonusbar:1] 7;"
		end

		if( Config['ActionBars']['OwnMetamorphosisBar'] ) then
			Warlock = "[stance:1] 10; "
		end

		Druid = "[bonusbar:1,nostealth] 7; [bonusbar:1,stealth] 8; [bonusbar:2] 8; [bonusbar:3] 9; [bonusbar:4] 10;"
		Priest = "[bonusbar:1] 7;"
		Monk = "[bonusbar:1] 7; [bonusbar:2] 8; [bonusbar:3] 9;"
	end

	Bar1.Page = {
		["DRUID"] = Druid,
		["WARRIOR"] = Warrior,
		["PRIEST"] = Priest,
		["ROGUE"] = Rogue,
		["WARLOCK"] = Warlock,
		["MONK"] = Monk,
		["DEFAULT"] = "[vehicleui:12] 12; [possessbar] 12; [overridebar] 14; [shapeshift] 13; [bar:2] 2; [bar:3] 3; [bar:4] 4; [bar:5] 5; [bar:6] 6;",
	}

	function Bar1:GetBar()
		local Condition = Bar1.Page['DEFAULT']
		local Class = Globals['MyClass']
		local Page = Bar1.Page[Class]

		if( Page ) then
			Condition = Condition .. ' ' .. Page
		end

		Condition = Condition .. ' [form] 1; 1'

		return Condition
	end

	local Button
	for i = 1, NUM_ACTIONBAR_BUTTONS do
		Button = _G['ActionButton' .. i]
		Bar1:SetFrameRef( 'ActionButton' .. i, Button )
	end

	Bar1:Execute( [[
		Button = table.new()
		for i = 1, 12 do
			table.insert( Button, self:GetFrameRef( 'ActionButton' .. i ) )
		end
	]] )

	Bar1:SetAttribute( '_onstate-page', [[
		if( HasTempShapeshiftActionBar() ) then
			newstate = GetTempShapeshiftBarIndex() or newstate
		end

		for i, Button in ipairs( Button ) do
			Button:SetAttribute( 'actionpage', tonumber( newstate ) )
		end
	]] )

	RegisterStateDriver( Bar1, 'page', Bar1:GetBar() )

	Bar1:RegisterEvent( 'PLAYER_ENTERING_WORLD' )
	Bar1:RegisterEvent( 'KNOWN_CURRENCY_TYPES_UPDATE' )
	Bar1:RegisterEvent( 'CURRENCY_DISPLAY_UPDATE' )
	Bar1:RegisterEvent( 'BAG_UPDATE' )
	Bar1:SetScript( 'OnEvent', function( self, event, unit, ... )
		local Button, PreviousButton

		if( event == 'ACTIVE_TALENT_GROUP_CHANGED' ) then
			for i = 1, NUM_ACTIONBAR_BUTTONS do
				Button = _G['ActionButton' .. i]
				self:SetFrameRef( 'ActionButton' .. i, Button )
			end

			self:Execute( [[
				Button = table.new()
				for i = 1, 12 do
					table.insert( Button, self:GetFrameRef( 'ActionButton' .. i ) )
				end
			]] )

			self:SetAttribute( '_onstate-page', [[
				if( HasTempShapeshiftActionBar() ) then
					newstate = GetTempShapeshiftBarIndex() or newstate
				end

				for i, Button in ipairs( Button ) do
					Button:SetAttribute( 'actionpage', tonumber( newstate ) )
				end
			]] )

			RegisterStateDriver( self, 'page', self:GetBar() )
		elseif( event == 'PLAYER_ENTERING_WORLD' ) then
			for i = 1, NUM_ACTIONBAR_BUTTONS do
				Button = _G['ActionButton' .. i]
				PreviousButton = _G['ActionButton' .. i - 1]

				Button:ClearAllPoints()
				Button:SetParent( self )
				Button:SetSize( 27, 27 )
				Button:SetFrameStrata( 'BACKGROUND' )
				Button:SetFrameLevel( 15 )

				if( i == 1 ) then
					if( Config['ActionBars']['SwapMainBars'] ) then
						Button:SetPoint( 'TOPLEFT', Bar1, 'TOPLEFT', 5, -5 )
					else
						Button:SetPoint( 'BOTTOMLEFT', Bar1, 'BOTTOMLEFT', 5, 5 )
					end
				else
					Button:SetPoint( 'LEFT', PreviousButton, 'RIGHT', Config['ActionBars']['SpacingMainButtons'], 0 )
				end
			end
		else
			MainMenuBar_OnEvent( self, event, ... )
		end
	end )
end

local CreateBar2 = function()
	local Bar2 = ActionBar2

	local Button, PreviousButton

	MultiBarBottomLeft:SetParent( Bar2 )

	for i = 1, NUM_ACTIONBAR_BUTTONS do
		Button = _G['MultiBarBottomLeftButton' .. i]
		PreviousButton = _G['MultiBarBottomLeftButton' .. i - 1]

		Button:SetSize( Config['ActionBars']['SizeMainButtons'], Config['ActionBars']['SizeMainButtons'] )
		Button:ClearAllPoints()
		Button:SetFrameStrata( 'BACKGROUND' )
		Button:SetFrameLevel( 15 )

		if( i == 1 ) then
			if( Config['ActionBars']['SwapMainBars'] ) then
				Button:SetPoint( 'TOP', _G['ActionButton1'], 'BOTTOM', 0, -Config['ActionBars']['SpacingMainButtons'] )
			else
				Button:SetPoint( 'BOTTOM', _G['ActionButton1'], 'TOP', 0, Config['ActionBars']['SpacingMainButtons'] )
			end
		else
			Button:SetPoint( 'LEFT', PreviousButton, 'RIGHT', Config['ActionBars']['SpacingMainButtons'], 0 )
		end
	end
end

local CreateBar3 = function()

end

local CreateBar4 = function()
	local Bar4 = ActionBar4

	local Button, PreviousButton

	MultiBarBottomRight:SetParent( Bar4 )

	for i = 1, NUM_ACTIONBAR_BUTTONS do
		Button = _G['MultiBarBottomRightButton' .. i]
		PreviousButton = _G['MultiBarBottomRightButton' .. i - 1]

		Button:SetSize( Config['ActionBars']['SizeRightButtons'], Config['ActionBars']['SizeRightButtons'] )
		Button:ClearAllPoints()
		Button:SetFrameStrata( 'BACKGROUND' )
		Button:SetFrameLevel( 15 )
		if( Config['ActionBars']['VerticalRightBars'] ) then
			Button:SetAttribute( 'flyoutDirection', 'LEFT' )
		else
			Button:SetAttribute( 'flyoutDirection', 'UP' )
		end

		if( i == 1 ) then
			if( Config['ActionBars']['VerticalRightBars'] ) then
				Button:SetPoint( 'TOPRIGHT', _G['MultiBarRightButton1'], 'TOPLEFT', -Config['ActionBars']['SpacingRightButtons'], 0 )
			else
				Button:SetPoint( 'BOTTOMLEFT', _G['MultiBarRightButton1'], 'TOPLEFT', 0, Config['ActionBars']['SpacingRightButtons'] )
			end
		else
			if( Config['ActionBars']['VerticalRightBars'] ) then
				Button:SetPoint( 'TOP', PreviousButton, 'BOTTOM', 0, -Config['ActionBars']['SpacingRightButtons'] )
			else
				Button:SetPoint( 'LEFT', PreviousButton, 'RIGHT', Config['ActionBars']['SpacingRightButtons'], 0 )
			end
		end
	end
end

local CreateSplitBars = function()
	local Button

	for i = 1, NUM_ACTIONBAR_BUTTONS do
		Button = _G['MultiBarLeftButton' .. i]

		if( Config['ActionBars']['SplitBars'] ) then
			Button:SetSize( Config['ActionBars']['SizeSplitButtons'], Config['ActionBars']['SizeSplitButtons'] )
			Button:SetAttribute( 'flyoutDirection', 'UP' )
		else
			Button:SetSize( Config['ActionBars']['SizeRightButtons'], Config['ActionBars']['SizeRightButtons'] )
			if( Config['ActionBars']['VerticalRightBars'] ) then
				Button:SetAttribute( 'flyoutDirection', 'LEFT' )
			else
				Button:SetAttribute( 'flyoutDirection', 'UP' )
			end
		end
		Button:ClearAllPoints()
		Button:SetFrameStrata( 'BACKGROUND' )
		Button:SetFrameLevel( 15 )
	end
end

local CreateRightBar = function()
	local Bar = RightActionBar

	local Button, PreviousButton

	MultiBarRight:SetParent( RightActionBar )

	for i = 1, NUM_ACTIONBAR_BUTTONS do
		Button = _G['MultiBarRightButton' .. i]
		PreviousButton = _G['MultiBarRightButton' .. i - 1]

		Button:SetSize( Config['ActionBars']['SizeRightButtons'], Config['ActionBars']['SizeRightButtons'] )
		Button:ClearAllPoints()
		Button:SetFrameStrata( 'BACKGROUND' )
		Button:SetFrameLevel( 15 )

		if( Config['ActionBars']['VerticalRightBars'] ) then
			Button:SetAttribute( 'flyoutDirection', 'LEFT' )
		else
			Button:SetAttribute( 'flyoutDirection', 'UP' )
		end

		if( i == 1 ) then
			if( Config['ActionBars']['VerticalRightBars'] ) then
				Button:SetPoint( 'TOPRIGHT', RightActionBar, 'TOPRIGHT', -5, -5 )
			else
				Button:SetPoint( 'BOTTOMLEFT', RightActionBar, 'BOTTOMLEFT', 5, 5 )
			end
		else
			if( Config['ActionBars']['VerticalRightBars'] ) then
				Button:SetPoint( 'TOP', PreviousButton, 'BOTTOM', 0, -Config['ActionBars']['SpacingRightButtons'] )
			else
				Button:SetPoint( 'LEFT', PreviousButton, 'RIGHT', Config['ActionBars']['SpacingRightButtons'], 0 )
			end
		end
	end
end

local CreateStanceBar = function()

end

local CreatePetBar = function()
	local PetBar = PetActionBar

	local Button, PreviousButton

	PetActionBarFrame:UnregisterEvent( 'PET_BAR_SHOWGRID' )
	PetActionBarFrame:UnregisterEvent( 'PET_BAR_HIDEGRID' )
	PetActionBarFrame.showgrid = 1

	for i = 1, NUM_PET_ACTION_SLOTS do
		Button = _G['PetActionButton' .. i]
		PreviousButton = _G['PetActionButton' .. ( i - 1 )]

		Button:ClearAllPoints()
		Button:SetParent( PetBar )
		Button:SetSize( Config['ActionBars']['SizePetButtons'], Config['ActionBars']['SizePetButtons'] )
		Button:SetFrameStrata( 'BACKGROUND' )
		Button:SetFrameLevel( 5 )
		Button:Show()

		if( i == 1 ) then
			Button:SetPoint( 'TOPLEFT', 5, -5 )
		else
			if( Config['ActionBars']['VerticalRightBars'] ) then
				Button:SetPoint( 'TOP', PreviousButton, 'BOTTOM', 0, -Config['ActionBars']['SpacingPetButtons'] )
			else
				Button:SetPoint( 'LEFT', PreviousButton, 'RIGHT', Config['ActionBars']['SpacingPetButtons'], 0 )
			end
		end

		PetBar:SetAttribute( 'addchild', Button )
	end

	RegisterStateDriver( PetBar, 'visibility', '[pet,nopetbattle,novehicleui,nooverridebar,nobonusbar:5] show; hide' )

	PetBar:RegisterEvent( 'PLAYER_CONTROL_LOST' )
	PetBar:RegisterEvent( 'PLAYER_CONTROL_GAINED' )
	PetBar:RegisterEvent( 'PLAYER_ENTERING_WORLD' )
	PetBar:RegisterEvent( 'PLAYER_FARSIGHT_FOCUS_CHANGED' )
	PetBar:RegisterEvent( 'PET_BAR_UPDATE' )
	PetBar:RegisterEvent( 'PET_BAR_UPDATE_USABLE' )
	PetBar:RegisterEvent( 'PET_BAR_UPDATE_COOLDOWN' )
	PetBar:RegisterEvent( 'PET_BAR_HIDE' )
	PetBar:RegisterEvent( 'UNIT_PET' )
	PetBar:RegisterEvent( 'UNIT_FLAGS' )
	PetBar:RegisterEvent( 'UNIT_AURA' )
	PetBar:SetScript( 'OnEvent', function( self, event, arg1 )
		if( event == 'PET_BAR_UPDATE' ) or
		  ( event == 'UNIT_PET' and arg1 == 'player' ) or
		  ( event == 'PLAYER_CONTROL_LOST' ) or
		  ( event == 'PLAYER_CONTROL_GAINED' ) or
		  ( event == 'PLAYER_FARSIGHT_FOCUS_CHANGED' ) or
		  ( event == 'UNIT_FLAGS' ) or
		  ( arg1 == 'pet' and ( event == 'UNIT_AURA' ) ) then
			UpdatePetBar()
		elseif( event == 'PET_BAR_UPDATE_COOLDOWN' ) then
			PetActionBar_UpdateCooldowns()
		else
			SkinPetButtons()
		end
	end )

	hooksecurefunc( 'PetActionBar_Update', UpdatePetBar )
end

local CreateExtraBar = function()

end

local CreateVehicleButton = function()

end

local InitMainBars = function()
	local Button
	local ActionBar1 = ActionBar1
	local ActionBar2 = ActionBar2
	local ActionBar3 = ActionBar3
	local SplitBarLeft = SplitBarLeft
	local SplitBarRight = SplitBarRight
	local MultiBarLeft = MultiBarLeft

	if( Config['ActionBars']['NumBottomRows'] == 1 ) then
		ActionBar1:SetHeight( ( Config['ActionBars']['SizeMainButtons'] + Config['ActionBars']['SpacingMainButtons'] * 2 ) + 2 )
		SplitBarLeft:SetHeight( ( Config['ActionBars']['SizeSplitButtons'] + Config['ActionBars']['SpacingSplitButtons'] * 2 ) + 2 )
		SplitBarRight:SetHeight( ( Config['ActionBars']['SizeSplitButtons'] + Config['ActionBars']['SpacingSplitButtons'] * 2 ) + 2 )

		UnregisterStateDriver( ActionBar2, 'visibility' )
		ActionBar2:Hide()

		if( Config['ActionBars']['SplitBars'] ) then
			MultiBarLeft:ClearAllPoints()
			MultiBarLeft:SetParent( SplitBarLeft )

			for i = 7, 12 do
				Button = _G['MultiBarLeftButton' .. i]
				Button:SetAlpha( 1 )
				Button:SetScale( 0.000001 )
			end
		else
			MultiBarLeft:ClearAllPoints()
			MultiBarLeft:SetParent( ActionBar3 )
		end
	elseif( Config['ActionBars']['NumBottomRows'] == 2 ) then
		ActionBar1:SetHeight( ( Config['ActionBars']['SizeMainButtons'] * 2 + Config['ActionBars']['SpacingMainButtons'] * 3 ) + 2 )
		SplitBarLeft:SetHeight( ( Config['ActionBars']['SizeSplitButtons'] * 2 + Config['ActionBars']['SpacingSplitButtons'] * 3 ) + 2 )
		SplitBarRight:SetHeight( ( Config['ActionBars']['SizeSplitButtons'] * 2 + Config['ActionBars']['SpacingSplitButtons'] * 3 ) + 2 )

		RegisterStateDriver( ActionBar2, 'visibility', '[vehicleui][petbattle][overridebar] hide; show' )
		ActionBar2:Show()

		if( Config['ActionBars']['SplitBars'] ) then
			MultiBarLeft:ClearAllPoints()
			MultiBarLeft:SetParent( SplitBarLeft )

			for i = 7, 12 do
				Button = _G['MultiBarLeftButton' .. i]
				Button:SetAlpha( 1 )
				Button:SetScale( 1 )
			end
		else
			MultiBarLeft:ClearAllPoints()
			MultiBarLeft:SetParent( ActionBar3 )
		end
	end
end

local InitRightBars = function()
	local Button, PreviousButton

	local ChatFramesRight = ChatFramesRight

	local ActionBar3 = ActionBar3
	local ActionBar4 = ActionBar4
	local RightActionBar = RightActionBar
	local PetActionBar = PetActionBar
	local MultiBarLeft = MultiBarLeft

	if( Config['ActionBars']['NumRightBars'] >= 1 ) then
		PetActionBar:ClearAllPoints()
		PetActionBar:SetPoint( 'BOTTOMRIGHT', RightActionBar, 'BOTTOMLEFT', -3, 0 )
	else
		PetActionBar:ClearAllPoints()
		PetActionBar:SetPoint( 'RIGHT', UIParent, 'RIGHT', -8, 0 )
	end

	if( Config['ActionBars']['NumRightBars'] == 1 ) then
		RegisterStateDriver( RightActionBar, 'visibility', '[vehicleui][petbattle][overridebar] hide; show' )
		UnregisterStateDriver( ActionBar4, 'visibility' )
		RightActionBar:Show()
		ActionBar4:Hide()

		if( Config['ActionBars']['VerticalRightBars'] == true ) then
			RightActionBar:SetWidth( ( Config['ActionBars']['SizeRightButtons'] + Config['ActionBars']['SpacingRightButtons'] * 2 ) + 2 )
			RightActionBar:SetHeight( ( Config['ActionBars']['SizeRightButtons'] * Config['ActionBars']['NumRightButtons'] + Config['ActionBars']['SpacingRightButtons'] * ( Config['ActionBars']['NumRightButtons'] + 1 ) ) + 2 )
		else
			RightActionBar:SetHeight( ( Config['ActionBars']['SizeRightButtons'] + Config['ActionBars']['SpacingRightButtons'] * 2 ) + 2 )
		end

		if( Config['ActionBars']['SplitBars'] ~= true and ActionBar3:IsShown() ) then
			MultiBarLeft:ClearAllPoints()
			MultiBarLeft:SetParent( ActionBar3 )
			UnregisterStateDriver( ActionBar3, 'visibility' )
			ActionBar3:Hide()
		end
	elseif( Config['ActionBars']['NumRightBars'] == 2 ) then
		RegisterStateDriver( RightActionBar, 'visibility', '[vehicleui][petbattle][overridebar] hide; show' )
		RegisterStateDriver( ActionBar4, 'visibility', '[vehicleui][petbattle][overridebar] hide; show' )
		RightActionBar:Show()
		ActionBar4:Show()

		if( Config['ActionBars']['VerticalRightBars'] ) then
			RightActionBar:SetWidth( ( Config['ActionBars']['SizeRightButtons'] * 2 + Config['ActionBars']['SpacingRightButtons'] * 3 ) + 2 )
			RightActionBar:SetHeight( ( Config['ActionBars']['SizeRightButtons'] * Config['ActionBars']['NumRightButtons'] + Config['ActionBars']['SpacingRightButtons'] * ( Config['ActionBars']['NumRightButtons'] + 1 ) ) + 2 )
		else
			RightActionBar:SetHeight( ( Config['ActionBars']['SizeRightButtons'] * 2 + Config['ActionBars']['SpacingRightButtons'] * 3 ) + 2 )
		end

		if( Config['ActionBars']['SplitBars'] ~= true and ActionBar3:IsShown() ) then
			MultiBarLeft:ClearAllPoints()
			MultiBarLeft:SetParent( ActionBar3 )
			UnregisterStateDriver( ActionBar3, 'visibility' )
			ActionBar3:Hide()
		end
	elseif( Config['ActionBars']['NumRightBars'] == 3 ) then
		RegisterStateDriver( RightActionBar, 'visibility', '[vehicleui][petbattle][overridebar] hide; show' )
		RegisterStateDriver( ActionBar4, 'visibility', '[vehicleui][petbattle][overridebar] hide; show' )
		RightActionBar:Show()
		ActionBar4:Show()

		if( Config['ActionBars']['VerticalRightBars'] ) then
			RightActionBar:SetWidth( ( Config['ActionBars']['SizeRightButtons'] * 3 + Config['ActionBars']['SpacingRightButtons'] * 4 ) + 2 )
			RightActionBar:SetHeight( ( Config['ActionBars']['SizeRightButtons'] * Config['ActionBars']['NumRightButtons'] + Config['ActionBars']['SpacingRightButtons'] * ( Config['ActionBars']['NumRightButtons'] + 1 ) ) + 2 )
		else
			RightActionBar:SetHeight( ( Config['ActionBars']['SizeRightButtons'] * 3 + Config['ActionBars']['SpacingRightButtons'] * 4 ) + 2 )
		end

		if( not Config['ActionBars']['SplitBars'] ) then
			MultiBarLeft:ClearAllPoints()
			MultiBarLeft:SetParent( ActionBar3 )
			RegisterStateDriver( ActionBar3, 'visibility', '[vehicleui][petbattle][overridebar] hide; show' )
			ActionBar3:Show()

			for i = 1, 12 do
				Button = _G['MultiBarLeftButton' .. i]
				PreviousButton = _G['MultiBarLeftButton' .. i - 1]

				Button:SetSize( Config['ActionBars']['SizeRightButtons'], Config['ActionBars']['SizeRightButtons'] )
				Button:ClearAllPoints()

				if( i == 1 ) then
					Button:SetPoint( 'TOPLEFT', RightActionBar, 5, -5 )
				else
					if( not Config['ActionBars']['SplitBars'] and Config['ActionBars']['VerticalRightBars'] == true ) then
						Button:SetPoint( 'TOP', PreviousButton, 'BOTTOM', 0, -Config['ActionBars']['SpacingRightButtons'] )
					else
						Button:SetPoint( 'LEFT', PreviousButton, 'RIGHT', Config['ActionBars']['SpacingRightButtons'], 0 )
					end
				end
			end
		end
	elseif( Config['ActionBars']['RightBars'] == 0 ) then
		UnregisterStateDriver( RightActionBar, 'visibility' )
		UnregisterStateDriver( ActionBar4, 'visibility' )
		RightActionBar:Hide()
		ActionBar4:Hide()

		if( not Config['ActionBars']['SplitBars'] ) then
			MultiBarLeft:ClearAllPoints()
			MultiBarLeft:SetParent( ActionBar3 )
			UnregisterStateDriver( ActionBar3, 'visibility' )
			ActionBar3:Hide()
		end
	end
end

local InitSplitBars = function()
	local Button, PreviousButton

	local ActionBar3 = ActionBar3
	local SplitBarLeft = SplitBarLeft
	local SplitBarRight = SplitBarRight
	local RightActionBar = RightActionBar
	local MultiBarLeft = MultiBarLeft

	if( Config['ActionBars']['SplitBars'] ) then
		MultiBarLeft:ClearAllPoints()
		MultiBarLeft:SetParent( SplitBarLeft )

		for i = 1, 12 do
			Button = _G['MultiBarLeftButton' .. i]
			PreviousButton = _G['MultiBarLeftButton' .. i - 1]

			Button:ClearAllPoints()
			if( i == 1 ) then
				Button:SetPoint( 'BOTTOMLEFT', SplitBarLeft, 'BOTTOMLEFT', 5, 5 )
			else
				if( i == 4 ) then
					Button:SetPoint( 'BOTTOMLEFT', SplitBarRight, 'BOTTOMLEFT', 5, 5 )
				elseif( i == 7 ) then
					Button:SetPoint( 'BOTTOMLEFT', _G['MultiBarLeftButton1'], 'TOPLEFT', 0, Config['ActionBars']['SpacingSplitButtons'] )
				elseif( i == 10 ) then
					Button:SetPoint( 'BOTTOMLEFT', _G['MultiBarLeftButton4'], 'TOPLEFT', 0, Config['ActionBars']['SpacingSplitButtons'] )
				else
					Button:SetPoint( 'LEFT', PreviousButton, 'RIGHT', Config['ActionBars']['SpacingSplitButtons'], 0 )
				end
			end
		end

		if( Config['ActionBars']['NumRightBars'] == 3 ) then
			RegisterStateDriver( RightActionBar, 'visibility', '[vehicleui][petbattle][overridebar] hide; show' )
			RightActionBar:Show()

			if( Config['ActionBars']['VerticalRightBars'] ) then
				RightActionBar:SetWidth( ( Config['ActionBars']['SizeRightButtons'] * 2 + Config['ActionBars']['SpacingRightButtons'] * 3 ) + 2 )
			else
				RightActionBar:SetHeight( ( Config['ActionBars']['SizeRightButtons'] * 2 + Config['ActionBars']['SpacingRightButtons'] * 3 ) + 2 )
			end
		end

		for i = 7, 12 do
			if( Config['ActionBars']['NumBottomRows'] == 1 ) then
				Button = _G['MultiBarLeftButton' .. i]
				Button:SetAlpha( 1 )
				Button:SetScale( 0.000001 )
			elseif( Config['ActionBars']['NumBottomRows'] == 2 ) then
				Button = _G['MultiBarLeftButton' .. i]
				Button:SetAlpha( 1 )
				Button:SetScale( 1 )
			end
		end

		RegisterStateDriver( SplitBarLeft, 'visibility', '[vehicleui][petbattle][overridebar] hide; show' )
		RegisterStateDriver( SplitBarRight, 'visibility', '[vehicleui][petbattle][overridebar] hide; show' )

		SplitBarLeft:Show()
		SplitBarRight:Show()
	elseif( not Config['ActionBars']['SplitBars'] ) then
		MultiBarLeft:ClearAllPoints()
		MultiBarLeft:SetParent( ActionBar3 )

		for i = 1, 12 do
			Button = _G['MultiBarLeftButton' .. i]
			PreviousButton = _G['MultiBarLeftButton' .. i - 1]

			Button:ClearAllPoints()
			if( i == 1 ) then
				Button:SetPoint( 'TOPLEFT', RightActionBar, 5, -5 )
			else
				Button:SetPoint( 'LEFT', PreviousButton, 'RIGHT', Config['ActionBars']['SpacingMainButtons'], 0 )
			end
		end

		BuildRightBars()

		for i = 7, 12 do
			Button = _G['MultiBarLeftButton' .. i]
			Button:SetAlpha( 1 )
			Button:SetScale( 1 )
		end

		UnregisterStateDriver( SplitBarLeft, 'visibility' )
		UnregisterStateDriver( SplitBarRight, 'visibility' )

		SplitBarLeft:Hide()
		SplitBarRight:Hide()
	end
end

local ManageButton = function( Frame, Delete, Add )
	if( Delete ) then
		Frame:SetAlpha( 0 )
		Frame:SetScale( 0.000001 )
	end

	if( Add ) then
		Frame:SetAlpha( 1 )
		Frame:SetScale( 1 )
	end
end

local HandleMainBarButtons = function()
	if( Config['ActionBars']['NumMainButtons'] == 1 ) then
		for i = 1, 1 do
			ManageButton( _G['ActionButton' .. i], false, true )
			ManageButton( _G['MultiBarBottomLeftButton' .. i], false, true )
		end

		for i = 2, 12 do
			ManageButton( _G['ActionButton' .. i], true, false )
			ManageButton( _G['MultiBarBottomLeftButton' .. i], true, false )
		end
	elseif( Config['ActionBars']['NumMainButtons'] == 2 ) then
		for i = 1, 2 do
			ManageButton( _G['ActionButton' .. i], false, true )
			ManageButton( _G['MultiBarBottomLeftButton' .. i], false, true )
		end

		for i = 3, 12 do
			ManageButton( _G['ActionButton' .. i], true, false )
			ManageButton( _G['MultiBarBottomLeftButton' .. i], true, false )
		end
	elseif( Config['ActionBars']['NumMainButtons'] == 3 ) then
		for i = 1, 3 do
			ManageButton( _G['ActionButton' .. i], false, true )
			ManageButton( _G['MultiBarBottomLeftButton' .. i], false, true )
		end

		for i = 4, 12 do
			ManageButton( _G['ActionButton' .. i], true, false )
			ManageButton( _G['MultiBarBottomLeftButton' .. i], true, false )
		end
	elseif( Config['ActionBars']['NumMainButtons'] == 4 ) then
		for i = 1, 4 do
			ManageButton( _G['ActionButton' .. i], false, true )
			ManageButton( _G['MultiBarBottomLeftButton' .. i], false, true )
		end

		for i = 5, 12 do
			ManageButton( _G['ActionButton' .. i], true, false )
			ManageButton( _G['MultiBarBottomLeftButton' .. i], true, false )
		end
	elseif( Config['ActionBars']['NumMainButtons'] == 5 ) then
		for i = 1, 5 do
			ManageButton( _G['ActionButton' .. i], false, true )
			ManageButton( _G['MultiBarBottomLeftButton' .. i], false, true )
		end

		for i = 6, 12 do
			ManageButton( _G['ActionButton' .. i], true, false )
			ManageButton( _G['MultiBarBottomLeftButton' .. i], true, false )
		end
	elseif( Config['ActionBars']['NumMainButtons'] == 6 ) then
		for i = 1, 6 do
			ManageButton( _G['ActionButton' .. i], false, true )
			ManageButton( _G['MultiBarBottomLeftButton' .. i], false, true )
		end

		for i = 7, 12 do
			ManageButton( _G['ActionButton' .. i], true, false )
			ManageButton( _G['MultiBarBottomLeftButton' .. i], true, false )
		end
	elseif( Config['ActionBars']['NumMainButtons'] == 7 ) then
		for i = 1, 7 do
			ManageButton( _G['ActionButton' .. i], false, true )
			ManageButton( _G['MultiBarBottomLeftButton' .. i], false, true )
		end

		for i = 8, 12 do
			ManageButton( _G['ActionButton' .. i], true, false )
			ManageButton( _G['MultiBarBottomLeftButton' .. i], true, false )
		end
	elseif( Config['ActionBars']['NumMainButtons'] == 8 ) then
		for i = 1, 8 do
			ManageButton( _G['ActionButton' .. i], false, true )
			ManageButton( _G['MultiBarBottomLeftButton' .. i], false, true )
		end

		for i = 9, 12 do
			ManageButton( _G['ActionButton' .. i], true, false )
			ManageButton( _G['MultiBarBottomLeftButton' .. i], true, false )
		end
	elseif( Config['ActionBars']['NumMainButtons'] == 9 ) then
		for i = 1, 9 do
			ManageButton( _G['ActionButton' .. i], false, true )
			ManageButton( _G['MultiBarBottomLeftButton' .. i], false, true )
		end

		for i = 10, 12 do
			ManageButton( _G['ActionButton' .. i], true, false )
			ManageButton( _G['MultiBarBottomLeftButton' .. i], true, false )
		end
	elseif( Config['ActionBars']['NumMainButtons'] == 10 ) then
		for i = 1, 10 do
			ManageButton( _G['ActionButton' .. i], false, true )
			ManageButton( _G['MultiBarBottomLeftButton' .. i], false, true )
		end

		for i = 11, 12 do
			ManageButton( _G['ActionButton' .. i], true, false )
			ManageButton( _G['MultiBarBottomLeftButton' .. i], true, false )
		end
	elseif( Config['ActionBars']['NumMainButtons'] == 11 ) then
		for i = 1, 11 do
			ManageButton( _G['ActionButton' .. i], false, true )
			ManageButton( _G['MultiBarBottomLeftButton' .. i], false, true )
		end

		for i = 12, 12 do
			ManageButton( _G['ActionButton' .. i], true, false )
			ManageButton( _G['MultiBarBottomLeftButton' .. i], true, false )
		end
	elseif( Config['ActionBars']['NumMainButtons'] == 12 ) then
		for i = 1, 12 do
			ManageButton( _G['ActionButton' .. i], false, true )
			ManageButton( _G['MultiBarBottomLeftButton' .. i], false, true )
		end
	elseif( Config['ActionBars']['NumMainButtons'] < 1 ) then
		for i = 2, 12 do
			_G['ActionButton1']:SetAlpha( 1 )
			_G['ActionButton1']:SetScale( 1 )

			_G['MultiBarBottomLeftButton1']:SetAlpha( 1 )
			_G['MultiBarBottomLeftButton1']:SetScale( 1 )

			ManageButton( _G['ActionButton' .. i], true, false )
			ManageButton( _G['MultiBarBottomLeftButton' .. i], true, false )
		end
	end
end

local HandleRightBarButtons = function()
	if( Config['ActionBars']['NumRightButtons'] == 1 ) then
		for i = 1, 1 do
			ManageButton( _G['MultiBarRightButton' .. i], false, true )
			ManageButton( _G['MultiBarBottomRightButton' .. i], false, true )

			if( not Config['ActionBars']['SplitBars'] ) then
				ManageButton( _G['MultiBarLeftButton' .. i], false, true )
			end
		end

		for i = 2, 12 do
			ManageButton( _G['MultiBarRightButton' .. i], true, false )
			ManageButton( _G['MultiBarBottomRightButton' .. i], true, false )

			if( not Config['ActionBars']['SplitBars'] ) then
				ManageButton( _G['MultiBarLeftButton' .. i], true, false )
			end
		end
	elseif( Config['ActionBars']['NumRightButtons'] == 2 ) then
		for i = 1, 2 do
			ManageButton( _G['MultiBarRightButton' .. i], false, true )
			ManageButton( _G['MultiBarBottomRightButton' .. i], false, true )

			if( not Config['ActionBars']['SplitBars'] ) then
				ManageButton( _G['MultiBarLeftButton' .. i], false, true )
			end
		end

		for i = 3, 12 do
			ManageButton( _G['MultiBarRightButton' .. i], true, false )
			ManageButton( _G['MultiBarBottomRightButton' .. i], true, false )

			if( not Config['ActionBars']['SplitBars'] ) then
				ManageButton( _G['MultiBarLeftButton' .. i], true, false )
			end
		end
	elseif( Config['ActionBars']['NumRightButtons'] == 3 ) then
		for i = 1, 3 do
			ManageButton( _G['MultiBarRightButton' .. i], false, true )
			ManageButton( _G['MultiBarBottomRightButton' .. i], false, true )

			if( not Config['ActionBars']['SplitBars'] ) then
				ManageButton( _G['MultiBarLeftButton' .. i], false, true )
			end
		end

		for i = 4, 12 do
			ManageButton( _G['MultiBarRightButton' .. i], true, false )
			ManageButton( _G['MultiBarBottomRightButton' .. i], true, false )

			if( not Config['ActionBars']['SplitBars'] ) then
				ManageButton( _G['MultiBarLeftButton' .. i], true, false )
			end
		end
	elseif( Config['ActionBars']['NumRightButtons'] == 4 ) then
		for i = 1, 4 do
			ManageButton( _G['MultiBarRightButton' .. i], false, true )
			ManageButton( _G['MultiBarBottomRightButton' .. i], false, true )

			if( not Config['ActionBars']['SplitBars'] ) then
				ManageButton( _G['MultiBarLeftButton' .. i], false, true )
			end
		end

		for i = 5, 12 do
			ManageButton( _G['MultiBarRightButton' .. i], true, false )
			ManageButton( _G['MultiBarBottomRightButton' .. i], true, false )

			if( not Config['ActionBars']['SplitBars'] ) then
				ManageButton( _G['MultiBarLeftButton' .. i], true, false )
			end
		end
	elseif( Config['ActionBars']['NumRightButtons'] == 5 ) then
		for i = 1, 5 do
			ManageButton( _G['MultiBarRightButton' .. i], false, true )
			ManageButton( _G['MultiBarBottomRightButton' .. i], false, true )

			if( not Config['ActionBars']['SplitBars'] ) then
				ManageButton( _G['MultiBarLeftButton' .. i], false, true )
			end
		end

		for i = 6, 12 do
			ManageButton( _G['MultiBarRightButton' .. i], true, false )
			ManageButton( _G['MultiBarBottomRightButton' .. i], true, false )

			if( not Config['ActionBars']['SplitBars'] ) then
				ManageButton( _G['MultiBarLeftButton' .. i], true, false )
			end
		end
	elseif( Config['ActionBars']['NumRightButtons'] == 6 ) then
		for i = 1, 6 do
			ManageButton( _G['MultiBarRightButton' .. i], false, true )
			ManageButton( _G['MultiBarBottomRightButton' .. i], false, true )

			if( not Config['ActionBars']['SplitBars'] ) then
				ManageButton( _G['MultiBarLeftButton' .. i], false, true )
			end
		end

		for i = 7, 12 do
			ManageButton( _G['MultiBarRightButton' .. i], true, false )
			ManageButton( _G['MultiBarBottomRightButton' .. i], true, false )

			if( not Config['ActionBars']['SplitBars'] ) then
				ManageButton( _G['MultiBarLeftButton' .. i], true, false )
			end
		end
	elseif( Config['ActionBars']['NumRightButtons'] == 7 ) then
		for i = 1, 7 do
			ManageButton( _G['MultiBarRightButton' .. i], false, true )
			ManageButton( _G['MultiBarBottomRightButton' .. i], false, true )

			if( not Config['ActionBars']['SplitBars'] ) then
				ManageButton( _G['MultiBarLeftButton' .. i], false, true )
			end
		end

		for i = 8, 12 do
			ManageButton( _G['MultiBarRightButton' .. i], true, false )
			ManageButton( _G['MultiBarBottomRightButton' .. i], true, false )

			if( not Config['ActionBars']['SplitBars'] ) then
				ManageButton( _G['MultiBarLeftButton' .. i], true, false )
			end
		end
	elseif( Config['ActionBars']['NumRightButtons'] == 8 ) then
		for i = 1, 8 do
			ManageButton( _G['MultiBarRightButton' .. i], false, true )
			ManageButton( _G['MultiBarBottomRightButton' .. i], false, true )

			if( not Config['ActionBars']['SplitBars'] ) then
				ManageButton( _G['MultiBarLeftButton' .. i], false, true )
			end
		end

		for i = 9, 12 do
			ManageButton( _G['MultiBarRightButton' .. i], true, false )
			ManageButton( _G['MultiBarBottomRightButton' .. i], true, false )

			if( not Config['ActionBars']['SplitBars'] ) then
				ManageButton( _G['MultiBarLeftButton' .. i], true, false )
			end
		end
	elseif( Config['ActionBars']['NumRightButtons'] == 9 ) then
		for i = 1, 9 do
			ManageButton( _G['MultiBarRightButton' .. i], false, true )
			ManageButton( _G['MultiBarBottomRightButton' .. i], false, true )

			if( not Config['ActionBars']['SplitBars'] ) then
				ManageButton( _G['MultiBarLeftButton' .. i], false, true )
			end
		end

		for i = 10, 12 do
			ManageButton( _G['MultiBarRightButton' .. i], true, false )
			ManageButton( _G['MultiBarBottomRightButton' .. i], true, false )

			if( not Config['ActionBars']['SplitBars'] ) then
				ManageButton( _G['MultiBarLeftButton' .. i], true, false )
			end
		end
	elseif( Config['ActionBars']['NumRightButtons'] == 10 ) then
		for i = 1, 10 do
			ManageButton( _G['MultiBarRightButton' .. i], false, true )
			ManageButton( _G['MultiBarBottomRightButton' .. i], false, true )

			if( not Config['ActionBars']['SplitBars'] ) then
				ManageButton( _G['MultiBarLeftButton' .. i], false, true )
			end
		end

		for i = 11, 12 do
			ManageButton( _G['MultiBarRightButton' .. i], true, false )
			ManageButton( _G['MultiBarBottomRightButton' .. i], true, false )

			if( not Config['ActionBars']['SplitBars'] ) then
				ManageButton( _G['MultiBarLeftButton' .. i], true, false )
			end
		end
	elseif( Config['ActionBars']['NumRightButtons'] == 11 ) then
		for i = 1, 11 do
			ManageButton( _G['MultiBarRightButton' .. i], false, true )
			ManageButton( _G['MultiBarBottomRightButton' .. i], false, true )

			if( not Config['ActionBars']['SplitBars'] ) then
				ManageButton( _G['MultiBarLeftButton' .. i], false, true )
			end
		end

		for i = 12, 12 do
			ManageButton( _G['MultiBarRightButton' .. i], true, false )
			ManageButton( _G['MultiBarBottomRightButton' .. i], true, false )

			if( not Config['ActionBars']['SplitBars'] ) then
				ManageButton( _G['MultiBarLeftButton' .. i], true, false )
			end
		end
	elseif( Config['ActionBars']['NumRightButtons'] == 12 ) then
		for i = 1, 12 do
			ManageButton( _G['MultiBarRightButton' .. i], false, true )
			ManageButton( _G['MultiBarBottomRightButton' .. i], false, true )

			if( not Config['ActionBars']['SplitBars'] ) then
				ManageButton( _G['MultiBarLeftButton' .. i], false, true )
			end
		end
	elseif( Config['ActionBars']['NumRightButtons'] < 1 ) then
		for i = 2, 12 do
			_G['MultiBarRightButton1']:SetAlpha( 1 )
			_G['MultiBarRightButton1']:SetScale( 1 )
			_G['MultiBarBottomRightButton1']:SetAlpha( 1 )
			_G['MultiBarBottomRightButton1']:SetScale( 1 )

			ManageButton( _G['MultiBarRightButton' .. i], true, false )
			ManageButton( _G['MultiBarBottomRightButton' .. i], true, false )

			if( not Config['ActionBars']['SplitBars'] ) then
				ManageButton( _G['MultiBarLeftButton' .. i], true, false )
				_G['MultiBarLeftButton1']:SetAlpha( 1 )
				_G['MultiBarLeftButton1']:SetScale( 1 )
			end
		end
	end
end

Globals['Init']['ActionBars'] = function()
	DisableBlizzard()

	CreateBackground()

	CreateBar1()
	CreateBar2()
	CreateBar3()
	CreateBar4()
	CreateSplitBars()
	CreateRightBar()
	CreateStanceBar()
	CreatePetBar()
	CreateExtraBar()
	CreateVehicleButton()

	ShowGrid()

	InitMainBars()
	InitRightBars()
	InitSplitBars()

	HandleMainBarButtons()
	HandleRightBarButtons()

	AddHooks()
end
