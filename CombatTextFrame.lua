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

-- **** event handlers ****
local OnCombatLogEventUnfiltered = function( self, timestamp, event, sourceGUID, sourceName, sourceFlags, destGUID, destName, destFlags, ... )
	local unit = self:GetUnit();
	if ( not unit or destGUID ~= UnitGUID( unit ) ) then return; end
	
	local healingSourceUnit = self:GetHealingSourceUnit();
	if ( not healingSourceUnit or sourceGUID ~= UnitGUID( healingSourceUnit ) ) then	
		if ( event == "SPELL_HEAL" or event == "SPELL_PERIODIC_HEAL" ) then
			local spellId, spellName, spellSchool, amount, overhealing, absorbed, critical = ...;
		
			HandleHeal( self, amount, critical );
			return;
		end
	end

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

-- **** ctor ****
local ctor = function( self, baseCtor, unit )
	baseCtor( self );
	
	if ( type( unit ) == "string" ) then
		self.unit = unit;
	else
		self.parent = unit;
		self:SetParent( unit );
	end
	
	self.healColor = { 0, 1, 0, 1 };
	self.damageColor = { 1, 0, 0, 1 };
	
	self.maxSize = 35;
	self.minSize = 10;
	
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
	}, FloatingMessageFrame );