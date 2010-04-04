local _, Internals = ...; 

-- **** imports ****
local CombatTextFrame = Internals.CombatTextFrame;
local MiniCombatTextFrame = Internals.MiniCombatTextFrame;

-- **** main ****

local highlightFrame = CombatTextFrame( "player" );
highlightFrame:SetWidth( 120 );
highlightFrame:SetHeight( 200 );
highlightFrame:SetPoint( "CENTER", UIParent, "CENTER", 0, 0 );
highlightFrame:SetSpeed( 35 );
highlightFrame:SetMaxSize( 25 );
highlightFrame:DisableDamage();
highlightFrame:DisableHealing();
highlightFrame:EnableCombat();
highlightFrame:EnableDispels();

-- player
local playerFrame = CombatTextFrame( "player" );
playerFrame:SetParent( UIParent );
playerFrame:SetWidth( 180 );
playerFrame:SetHeight( 170 );
playerFrame:SetPoint( "BOTTOMLEFT", UIParent, "BOTTOMLEFT", 420, 12 );

-- target
local targetFrame = CombatTextFrame( "target" );
targetFrame:SetParent( UIParent );
targetFrame:SetWidth( 180 );
targetFrame:SetHeight( 170 );
targetFrame:SetPoint( "BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -420, 12 );
targetFrame:SetDamageSourceUnit( "player" );