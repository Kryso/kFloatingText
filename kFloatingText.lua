local _, Internals = ...; 

-- **** imports ****
local CombatTextFrame = Internals.CombatTextFrame;
local MiniCombatTextFrame = Internals.MiniCombatTextFrame;

-- **** main ****

-- player
local playerFrame = CombatTextFrame( "player" );
playerFrame:SetParent( UIParent );
playerFrame:SetWidth( 180 );
playerFrame:SetHeight( 184 );
playerFrame:SetPoint( "BOTTOMLEFT", UIParent, "BOTTOMLEFT", 435, 12 );

-- target
local targetFrame = CombatTextFrame( "target" );
targetFrame:SetParent( UIParent );
targetFrame:SetWidth( 180 );
targetFrame:SetHeight( 184 );
targetFrame:SetPoint( "BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -435, 12 );
targetFrame:SetDamageSourceUnit( "player" );

-- arena
--[==[
for index = 1, 5 do
	local parent = _G[ "oUF_Arena" .. tostring( index ) ]
	if ( not parent ) then break; end
	
	local size = parent:GetHeight() + 10;
	
	local frame = CombatTextFrame( parent );
	frame:SetWidth( size );
	frame:SetHeight( size );
	frame:SetMinSize( 9 );
	frame:SetMaxSize( 20 );
	frame:SetSpeed( 8 );
	frame:SetPoint( "RIGHT", parent, "LEFT", -5, 0 );
	frame:SetFrameStrata( "HIGH" );
end

-- party pets
for index = 1, 5 do
	local parent = _G[ "oUF_PartyPet" .. tostring( index ) ]
	if ( not parent ) then break; end

	local size = parent:GetHeight() + 10;
	
	local frame = CombatTextFrame( parent );
	frame:SetWidth( size );
	frame:SetHeight( size );
	frame:SetMinSize( 9 );
	frame:SetMaxSize( 20 );
	frame:SetSpeed( 8 );
	frame:SetPoint( "LEFT", parent, "RIGHT", 5, 0 );
	frame:SetFrameStrata( "HIGH" );
end

-- party
do
	local event;
	local partyFramesCreated = 1;
	local OnPartyMembersChanged = function( self )
		for index = partyFramesCreated, 5 do
			local parent = _G[ "oUF_GroupUnitButton" .. tostring( index ) ];
			if ( not parent ) then
				break;
			end
			
			local size = parent:GetHeight() + 10;
			
			local frame = CombatTextFrame( parent );
			frame:SetWidth( size );
			frame:SetHeight( size );
			frame:SetMinSize( 9 );
			frame:SetMaxSize( 20 );
			frame:SetSpeed( 8 );
			frame:SetPoint( "LEFT", parent, "RIGHT", 5, 0 );
			frame:SetFrameStrata( "HIGH" );
			
			partyFramesCreated = partyFramesCreated + 1
		end
		
		if ( partyFramesCreated > 5 ) then
			kEvents.UnregisterEvent( event );
		end
	end
	event = kEvents.RegisterEvent( "PARTY_MEMBERS_CHANGED", OnPartyMembersChanged );
end
]==]--