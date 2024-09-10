JCF_ADDITIONAL_POWER_BAR_NAME = "MANA";
JCF_ADDITIONAL_POWER_BAR_INDEX = 0;
JCF_ALT_POWER_BAR_PAIR_DISPLAY_INFO = {
	DRUID = {
		[Enum.PowerType.LunarPower] = { powerType = Enum.PowerType.Mana, powerName = "MANA" },
	},
	PRIEST = {
		[Enum.PowerType.Insanity] = { powerType = Enum.PowerType.Mana, powerName = "MANA" },
	},
	SHAMAN = {
		[Enum.PowerType.Maelstrom] = { powerType = Enum.PowerType.Mana, powerName = "MANA" },
	},
};
function JcfAlternatePowerBar_OnLoad(self)
	JcfAlternatePowerBar_Initialize(self);
	JcfTextStatusBar_Initialize(self);
	self.textLockable = 1;
	self.cvar = "statusText";
	self.cvarLabel = "STATUS_TEXT_PLAYER";
end

function JcfAlternatePowerBar_Initialize(self)
	if ( not self.powerName ) then
		self.powerName = JCF_ADDITIONAL_POWER_BAR_NAME;
		self.powerIndex = JCF_ADDITIONAL_POWER_BAR_INDEX;
	end
	
	self:RegisterEvent("UNIT_POWER_UPDATE");	--"UNIT_"..self.powerName
	self:RegisterEvent("UNIT_MAXPOWER");		--"UNIT_MAX"..self.powerName
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("UNIT_DISPLAYPOWER");
	self.capNumericDisplay = true;
	self.LeftText = _G[self:GetName().."LeftText"];
	self.RightText = _G[self:GetName().."RightText"];
	SetJcfTextStatusBarText(self, _G[self:GetName().."Text"])
	
	local info = PowerBarColor[self.powerName];
	self:SetStatusBarColor(info.r, info.g, info.b);
end

function JcfAlternatePowerBar_OnEvent(self, event, arg1)
	local parent = self:GetParent();
	if ( event == "UNIT_DISPLAYPOWER" ) then
		JcfAlternatePowerBar_UpdatePowerType(self);
	elseif ( event=="PLAYER_ENTERING_WORLD" ) then
		JcfAlternatePowerBar_UpdateMaxValues(self);
		JcfAlternatePowerBar_UpdateValue(self);
		JcfAlternatePowerBar_UpdatePowerType(self);
	elseif( (event == "UNIT_MAXPOWER") ) then
		local parent = self:GetParent();
		if arg1 == parent.unit then
			JcfAlternatePowerBar_UpdateMaxValues(self);
		end
	elseif ( self:IsShown() ) then
		if ( (event == "UNIT_MANA") and (arg1 == parent.unit) ) then
			JcfAlternatePowerBar_UpdateValue(self);
		end
	end
end

function JcfAlternatePowerBar_OnUpdate(self, elapsed)
	JcfAlternatePowerBar_UpdateValue(self);
end

function JcfAlternatePowerBar_UpdateValue(self)
	local currmana = UnitPower(self:GetParent().unit,self.powerIndex);
	self:SetValue(currmana);
	self.value = currmana
	JcfTextStatusBar_OnValueChanged(self, currmana);
	JcfTextStatusBar_UpdateTextString(self);
end

function JcfAlternatePowerBar_UpdateMaxValues(self)
	local maxmana = UnitPowerMax(self:GetParent().unit,self.powerIndex);
	self:SetMinMaxValues(0,maxmana);
	JcfTextStatusBar_UpdateTextString(self);
end

function JcfAlternatePowerBar_UpdatePowerType(self)
	local _,class = UnitClass('player')
	if ( JCF_ALT_POWER_BAR_PAIR_DISPLAY_INFO[class] and
		(UnitPowerType(self:GetParent().unit) ~= self.powerIndex) and
		(UnitPowerMax(self:GetParent().unit,self.powerIndex) ~= 0) ) then
		self.pauseUpdates = false;
		self:Show();
	else
		self.pauseUpdates = true;
		self:Hide();
	end
end