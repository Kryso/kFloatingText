local _, Internals = ...; 

-- **** imports ****
local kCore = kCore;
local kWidgets = kWidgets;

local FloatingMessageFrame = kWidgets.FloatingMessageFrame;

-- **** private ****
local Base;

local GetFontSize = function( self, amount, coeff )
	local minSize = self.minSize;
	local maxSize = self.maxSize;
	
	local size = minSize + math.min( amount / coeff, maxSize - minSize );
	local level = math.ceil( size / maxSize * 4 );

	return size, level;
end

local HandleDamage = function( self, amount, critical )
	local text = tostring( amount );
	if ( critical ) then
		text = "!" .. text .. "!";
	end

	local size, level = GetFontSize( self, amount, 200 );
	
	self:Add( text, size, self.damageColor, level );
end

local HandleHeal = function( self, amount, critical )
	local text = tostring( amount );
	if ( critical ) then
		text = "!" .. text .. "!";
	end

	local size, level = GetFontSize( self, amount, 400 );
	
	self:Add( text, size, self.healColor, level );
end

local HandleCombat = function( self, inCombat )
	self:Add( inCombat and "+ COMBAT +" or "- COMBAT -", self.maxSize, self.combatColor, 4 );
end

local HandleDispel = function( self, auraName, event )
	local message = "";
	if ( event == "SPELL_STOLEN" ) then
		message = "|cff00ff00Stolen:|r ";
	elseif ( event == "SPELL_DISPEL" ) then
		message = "|cff00ff00Removed:|r ";
	elseif ( event == "SPELL_DISPEL_FAILED" ) then
		message = "|cffff0000Failed:|r ";
	else
		error( "Unhandled event '" .. event .. "'" );
	end

	self:Add( message .. auraName, self.maxSize, self.dispelColor, 4 );
end

-- **** event handlers ****
local OnCombatLogEventUnfiltered = function( self, timestamp, event, sourceGUID, sourceName, sourceFlags, destGUID, destName, destFlags, ... )
	local unit = self:GetUnit();
	if ( not unit ) then return; end	
	
	if ( self.showDispels and sourceGUID == UnitGUID( unit ) ) then
		if ( event == "SPELL_STOLEN" or event == "SPELL_DISPEL" ) then
			local spellId, spellName, spellSchool, extraSpellID, extraSpellName, extraSchool, auraType = ...;
			
			HandleDispel( self, extraSpellName, event );
		elseif ( event == "SPELL_DISPEL_FAILED" ) then
			local spellId, spellName, spellSchool, extraSpellID, extraSpellName, extraSchool = ...;

			HandleDispel( self, extraSpellName, event );
		end
	end
	
	if ( destGUID ~= UnitGUID( unit ) ) then return; end
	
	if ( self.showHealing ) then
		local healingSourceUnit = self:GetHealingSourceUnit();
		if ( not healingSourceUnit or sourceGUID ~= UnitGUID( healingSourceUnit ) ) then	
			if ( event == "SPELL_HEAL" or event == "SPELL_PERIODIC_HEAL" ) then
				local spellId, spellName, spellSchool, amount, overhealing, absorbed, critical = ...;
			
				HandleHeal( self, amount, critical );
				return;
			end
		end
	end

	if ( self.showDamage ) then
		local damageSourceUnit = self:GetDamageSourceUnit();
		if ( not damageSourceUnit or sourceGUID == UnitGUID( damageSourceUnit ) ) then	
			if ( event == "SWING_DAMAGE" ) then
				local amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing = ...;
				
				HandleDamage( self, amount, critical );
			elseif ( event == "RANGE_DAMAGE" or event == "SPELL_DAMAGE" or event == "SPELL_PERIODIC_DAMAGE" ) then
				local spellId, spellName, spellSchool, amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing = ...;
				
				HandleDamage( self, amount, critical );
			elseif ( event == "ENVIRONMENTAL_DAMAGE" ) then
				local environmentalType, amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing = ...;
				
				HandleDamage( self, amount, critical );
			end	
		end
	end
end

local OnPlayerRegenDisabled = function( self )
	local unit = self:GetUnit();
	if ( not unit or UnitGUID( unit ) ~= UnitGUID( "player" ) ) then return; end
	
	HandleCombat( self, true );
end

local OnPlayerRegenEnabled = function( self )
	local unit = self:GetUnit();
	if ( not unit or UnitGUID( unit ) ~= UnitGUID( "player" ) ) then return; end
	
	HandleCombat( self, false );
end

-- **** public ****
local GetUnit = function( self )
	return self.unit or self.parent:GetAttribute( "unit" );
end

local GetHealingSourceUnit = function( self )
	return self.healingSourceUnit;
end

local SetHealingSourceUnit = function( self, value )
	self.healingSourceUnit = value;
end

local GetDamageSourceUnit = function( self )
	return self.damageSourceUnit;
end

local SetDamageSourceUnit = function( self, value )
	self.damageSourceUnit = value;
end

local GetMinSize = function( self )
	return self.minSize;
end

local SetMinSize = function( self, value )
	self.minSize = value;
end

local GetMaxSize = function( self )
	return self.maxSize;
end

local SetMaxSize = function( self, value )
	self.maxSize = value;
end

local EnableDamage = function( self )
	self.showDamage = true;
end

local DisableDamage = function( self )
	self.showDamage = false;
end

local EnableHealing = function( self )
	self.showHealing = true;
end

local DisableHealing = function( self )
	self.showHealing = false;
end

local EnableCombat = function( self )
	if ( not self.showCombat ) then	
		self.combatEvent1 = self:RegisterEvent( "PLAYER_REGEN_DISABLED", OnPlayerRegenDisabled );
		self.combatEvent2 = self:RegisterEvent( "PLAYER_REGEN_ENABLED", OnPlayerRegenEnabled );
		
		self.showCombat = true;
	end
end

local DisableCombat = function( self )
	if ( self.showCombat ) then
		self:UnregisterEvent( self.combatEvent1 );
		self:UnregisterEvent( self.combatEvent2 );
		
		self.showCombat = false;		
	end
end

local EnableDispels = function( self )
	self.showDispels = true;
end

local DisableDispels = function( self )
	self.showDispels = false;
end

-- **** ctor ****
local ctor = function( self, baseCtor, unit )
	baseCtor( self );
	
	if ( type( unit ) == "string" ) then
		self.unit = unit;
	else
		self.parent = unit;
		self:SetParent( unit );
	end
	
	--[[local background = kWidgets.Texture( self );
	background:SetAllPoints( self );
	background:SetTexture( 1, 1, 1, 1 );]]
	
	self.healColor = { 0, 1, 0, 1 };
	self.damageColor = { 1, 0, 0, 1 };
	self.combatColor = { 1, 1, 0, 1 };
	self.dispelColor = { 0, .5, 1, 1 };
	
	self.maxSize = 35;
	self.minSize = 10;
	
	self.showHealing = true;
	self.showDamage = true;
	self.showCombat = false;
	self.showDispels = false;
	
	self:RegisterEvent( "COMBAT_LOG_EVENT_UNFILTERED", OnCombatLogEventUnfiltered );
end

-- **** main ****
Internals.CombatTextFrame, Base = kCore.CreateClass( ctor, { 
		GetUnit = GetUnit,
		
		GetMinSize = GetMinSize,
		SetMinSize = SetMinSize,
		
		GetMaxSize = GetMaxSize,
		SetMaxSize = SetMaxSize,
		
		GetHealingSourceUnit = GetHealingSourceUnit,
		SetHealingSourceUnit = SetHealingSourceUnit,
		
		GetDamageSourceUnit = GetDamageSourceUnit,
		SetDamageSourceUnit = SetDamageSourceUnit,
		
		EnableDamage = EnableDamage,
		DisableDamage = DisableDamage,
		
		EnableHealing = EnableHealing,
		DisableHealing = DisableHealing,

		EnableCombat = EnableCombat,
		DisableCombat = DisableCombat,
		
		EnableDispels = EnableDispels,
		DisableDispels = DisableDispels,
	}, FloatingMessageFrame );