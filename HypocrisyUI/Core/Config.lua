local AddOn, NameSpace = ...

local Config = {}

Config['ActionBars'] = {
	['Enable'] = true,

	['SwapMainBars'] = false,
	['ShowMacroText'] = true,
	['ShowHotKeyText'] = true,
	['InvertedTextures'] = true,
	['GlossTextures'] = false,


	-- Main BottomBars
	['NumBottomRows'] = 2,
	['NumMainButtons'] = 12,
	['SizeMainButtons'] = 27,
	['SpacingMainButtons'] = 4,

	-- Right Bars
	['VerticalRightBars'] = true,
	['NumRightBars'] = 2,
	['NumRightButtons'] = 12,
	['SizeRightButtons'] = 27,
	['SpacingRightButtons'] = 4,

	-- SplitBars
	['SplitBars'] = true,
	['SizeSplitButtons'] = 27,
	['SpacingSplitButtons'] = 4,

	['OwnShadowDanceBar'] = false,
	['OwnMetamorphosisBar'] = true,
	['OwnWarriorStanceBar'] = false,

	-- StanceBars
	['VerticalStanceBars'] = true,
	['SizeStanceButtons'] = 27,
	['SpacingStanceButtons'] = 4,

	-- PetBar
	['SizePetButtons'] = 27,
	['SpacingPetButtons'] = 4,
}

Config['ExperienceBar'] = {
	['Enable'] = true,

	['Position'] = { 'BOTTOM', UIParent, 'BOTTOM', 0, 2 },
	['Height'] = 14,
	['Width'] = 368,
}

Config['ReputationBar'] = {
	['Enable'] = true,

	['Position'] = { 'BOTTOM', UIParent, 'BOTTOM', 0, 2 },
	['Height'] = 14,
	['Width'] = 368,
}

NameSpace['Config'] = Config
