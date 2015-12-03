local AddOn, NameSpace = ...

local Globals = {}

Globals['Colors'] = {
	['General'] = {
		['Backdrop'] = { 0, 0, 0, 1 },
		['Border'] = { 0.125, 0.125, 0.125, 1 },
		['Value'] = { 0.4, 0.4, 0.5, 1 },
		['PrimaryDataText'] = { 1, 1, 1, 1 },
		['SecondaryDataText'] = { 0.4, 0.4, 0.5, 1 },
		['Alpha'] = 0.7,
	},

	['Power'] = {
		['MANA'] = { 0.31, 0.45, 0.63 },
		['RAGE'] = { 0.69, 0.31, 0.31 },
		['FOCUS'] = { 0.71, 0.43, 0.27 },
		['ENERGY'] = { 0.65, 0.63, 0.35 },
		['CHI'] = { 0.71, 1, 0.92 },
		['RUNES'] = { 0.55, 0.57, 0.61 },
		['RUNIC_POWER'] = { 0, 0.82, 1 },
		['SOUL_SHARDS'] = { 0.50, 0.32, 0.55 },
		['HOLY_POWER'] = { 0.95, 0.90, 0.60 },
		['FUEL'] = { 0, 0.55, 0.5 },
	},

	['Totems'] = {
		[1] = { 0.58, 0.23, 0.10 },
		[2] = { 0.23, 0.45, 0.13 },
		[3] = { 0.19, 0.48, 0.60 },
		[4] = { 0.42, 0.18, 0.74 },
	},

	['Class'] = {
		['DEATHKNIGHT'] = { 0.77, 0.12, 0.23 },
		['DRUID'] = { 1, 0.49, 0.04 },
		['HUNTER'] = { 0.67, 0.83, 0.45 },
		['MAGE'] = { 0.41, 0.80, 0.94  },
		['MONK'] = { 0.33, 0.54, 0.52 },
		['PALADIN'] = { 0.96, 0.55, 0.73 },
		['PRIEST'] = { 1, 1, 1 },
		['ROGUE'] = { 1, 0.96, 0.41  },
		['SHAMAN'] = { 0.0, 0.44, 0.87 },
		['WARLOCK'] = { 0.58, 0.51, 0.79 },
		['WARRIOR'] = { 0.78, 0.61, 0.43  },
	},
}

Globals['Textures'] = {
	['Blank'] = 'Interface\\AddOns\\HypocrisyUI\\Medias\\Textures\\Blank',
	['Border'] = 'Interface\\AddOns\\HypocrisyUI\\Medias\\Textures\\Border',
	['Gloss'] = 'Interface\\AddOns\\HypocrisyUI\\Medias\\Textures\\Gloss',
	['Glow'] = 'Interface\\AddOns\\HypocrisyUI\\Medias\\Textures\\Glow',
	['Inverted'] = 'Interface\\AddOns\\HypocrisyUI\\Medias\\Textures\\Inverted',
	['StatusBar'] = 'Interface\\AddOns\\HypocrisyUI\\Medias\\Textures\\StatusBar',
}

Globals['Fonts'] = {
	['Font'] = 'Interface\\AddOns\\HypocrisyUI\\Medias\\Fonts\\Font.ttf',
	['Size'] = 10,
	['Style'] = 'OUTLINE',
}

Globals['Backdrop'] = {
	['bgFile'] = [[Interface\AddOns\HypocrisyUI\Medias\Textures\Blank]],
	['edgeFile'] = [[Interface\AddOns\HypocrisyUI\Medias\Textures\Blank]],
	['tile'] = false,
	['tileSize'] = 0,
	['edgeSize'] = 1,
	['insets'] = {
		['left'] = -1,
		['right'] = -1,
		['top'] = -1,
		['bottom'] = -1
	},

}

----------------------------------------
-- Player Informations
----------------------------------------
Globals['MyName'] = UnitName( 'player' )
Globals['MyLevel'] = UnitLevel( 'player' )
Globals['MyClass'] = select( 2, UnitClass( 'player' ) )
Globals['MyRace'] = select( 2, UnitRace( 'player' ) )
Globals['MyFaction'] = UnitFactionGroup( 'player' )
Globals['MyRealm'] = GetRealmName()
Globals['MySpec'] = GetSpecialization()

Globals['Dummy'] = function()
	return
end

Globals['TextureCoords'] = { 0.08, 0.92, 0.08, 0.92 }

Globals['FontString'] = function( Parent, Layer, Type, Size, Style, JustifyH, Shadow )
	local FontString = Parent:CreateFontString( nil, Layer or 'OVERLAY' )
	FontString:SetFont( Type, Size or 10, Style or nil )
	FontString:SetJustifyH( JustifyH or 'CENTER' )

	if( Shadow ) then
		FontString:SetShadowColor( 0, 0, 0 )
		FontString:SetShadowOffset( 1.25, -1.25 )
	end

	return FontString
end

Globals['StatusBar'] = function( Name, Parent, Texture, Color )
	local StatusBar = CreateFrame( 'StatusBar', Name or nil, Parent or UIParent )
	StatusBar:SetStatusBarTexture( Texture or Globals['Textures']['StatusBar'] )
	StatusBar:GetStatusBarTexture():SetHorizTile( false )

	if( Color ) then
		StatusBar:SetStatusBarColor( unpack( Color ) )
	end

	return StatusBar
end

----------------------------------------
-- Frames
----------------------------------------
Globals['Init'] = {}

Globals['HiddenFrame'] = CreateFrame( 'Frame', 'HiddenFrame', UIParent )
Globals['HiddenFrame']:Hide()

Globals['PetUIFrame'] = CreateFrame( 'Frame', 'PetUIFrame', UIParent, 'SecureHandlerStateTemplate' )
Globals['PetUIFrame']:SetAllPoints()
RegisterStateDriver( Globals['PetUIFrame'], 'visibility', '[petbattle] hide;show' )

NameSpace['Globals'] = Globals
