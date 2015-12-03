local AddOn, NameSpace = ...

local Globals = NameSpace['Globals']

local EventFrame = CreateFrame( 'Frame' )
EventFrame:RegisterEvent( 'PLAYER_LOGIN' )
EventFrame:SetScript( 'OnEvent', function( self, event, ... )
	self[event]( self, ... )
end )

function EventFrame:PLAYER_LOGIN()
	Globals['Init']['ActionBars']()
	Globals['Init']['ExperienceBar']()
	Globals['Init']['ReputationBar']()
end
