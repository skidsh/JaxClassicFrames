
JcfPowerBarColor = {};
JcfPowerBarColor["MANA"] = { r = 0.00, g = 0.00, b = 1.00 };
JcfPowerBarColor["RAGE"] = { r = 1.00, g = 0.00, b = 0.00, fullPowerAnim=true };
JcfPowerBarColor["FOCUS"] = { r = 1.00, g = 0.50, b = 0.25, fullPowerAnim=true };
JcfPowerBarColor["ENERGY"] = { r = 1.00, g = 1.00, b = 0.00, fullPowerAnim=true };
JcfPowerBarColor["HAPPINESS"] = { r = 1.00, g = 0.41, b = 0.96 };
JcfPowerBarColor["RUNIC_POWER"] = { r = 0.00, g = 0.82, b = 1.00 };
JcfPowerBarColor["SOUL_SHARDS"] = { r = 0.50, g = 0.32, b = 0.55 };
JcfPowerBarColor["LUNAR_POWER"] = { r = 0.30, g = 0.52, b = 0.90, atlas="_Druid-LunarBar" };
JcfPowerBarColor["HOLY_POWER"] = { r = 0.95, g = 0.90, b = 0.60 };
JcfPowerBarColor["MAELSTROM"] = { r = 0.00, g = 0.50, b = 1.00, atlas = "_Shaman-MaelstromBar", fullPowerAnim=true };
JcfPowerBarColor["INSANITY"] = { r = 0.40, g = 0, b = 0.80, atlas = "_Priest-InsanityBar"};
JcfPowerBarColor["COMBO_POINTS"] = { r = 1.00, g = 0.96, b = 0.41 };
JcfPowerBarColor["CHI"] = { r = 0.71, g = 1.0, b = 0.92 };
JcfPowerBarColor["ARCANE_CHARGES"] = { r = 0.1, g = 0.1, b = 0.98 };
JcfPowerBarColor["FURY"] = { r = 0.788, g = 0.259, b = 0.992, atlas = "_DemonHunter-DemonicFuryBar", fullPowerAnim=true };
JcfPowerBarColor["PAIN"] = { r = 255/255, g = 156/255, b = 0, atlas = "_DemonHunter-DemonicPainBar", fullPowerAnim=true };
-- vehicle colors
JcfPowerBarColor["AMMOSLOT"] = { r = 0.80, g = 0.60, b = 0.00 };
JcfPowerBarColor["FUEL"] = { r = 0.0, g = 0.55, b = 0.5 };
JcfPowerBarColor["STAGGER"] = { {r = 0.52, g = 1.0, b = 0.52}, {r = 1.0, g = 0.98, b = 0.72}, {r = 1.0, g = 0.42, b = 0.42},};

-- these are mostly needed for a fallback case (in case the code tries to index a power token that is missing from the table,
-- it will try to index by power type instead)
JcfPowerBarColor[0] = JcfPowerBarColor["MANA"];
JcfPowerBarColor[1] = JcfPowerBarColor["RAGE"];
JcfPowerBarColor[2] = JcfPowerBarColor["FOCUS"];
JcfPowerBarColor[3] = JcfPowerBarColor["ENERGY"];
JcfPowerBarColor[4] = JcfPowerBarColor["CHI"];
JcfPowerBarColor[6] = JcfPowerBarColor["RUNIC_POWER"];
JcfPowerBarColor[7] = JcfPowerBarColor["SOUL_SHARDS"];
JcfPowerBarColor[8] = JcfPowerBarColor["LUNAR_POWER"];
JcfPowerBarColor[9] = JcfPowerBarColor["HOLY_POWER"];
JcfPowerBarColor[11] = JcfPowerBarColor["MAELSTROM"];
JcfPowerBarColor[13] = JcfPowerBarColor["INSANITY"];
JcfPowerBarColor[17] = JcfPowerBarColor["FURY"];
JcfPowerBarColor[18] = JcfPowerBarColor["PAIN"];

-- Threat Display
MAX_DISPLAYED_THREAT_PERCENT = 999;

function JcfGetJcfPowerBarColor(powerType)
	return JcfPowerBarColor[powerType];
end

--[[
	This system uses "update" functions as OnUpdate, and OnEvent handlers.
	This "Initialize" function Jcfregisters the events to handle.
	The "update" function Jcfis set as the OnEvent handler (although they do not parse the event),
	as well as run from the parent's update handler.

	TT: I had to make the spellbar system differ from the norm.
	I needed a seperate OnUpdate and OnEvent handlers. And needed to parse the event.
]]--

function JcfUnitFrame_Initialize (self, unit, name, portrait, healthbar, healthtext, manabar, manatext, threatIndicator, threatFeedbackUnit, threatNumericIndicator,
		myHealPredictionBar, otherHealPredictionBar, totalAbsorbBar, totalAbsorbBarOverlay, overAbsorbGlow, overHealAbsorbGlow, healAbsorbBar, healAbsorbBarLeftShadow,
		healAbsorbBarRightShadow, myManaCostPredictionBar)
	self.unit = unit;
	self.name = name;
	self.portrait = portrait;
	self.healthbar = healthbar;
	self.manabar = manabar;
	self.threatIndicator = threatIndicator;
	self.threatNumericIndicator = threatNumericIndicator;
	self.myHealPredictionBar = myHealPredictionBar;
	self.otherHealPredictionBar = otherHealPredictionBar
	self.totalAbsorbBar = totalAbsorbBar;
	self.totalAbsorbBarOverlay = totalAbsorbBarOverlay;
	self.overAbsorbGlow = overAbsorbGlow;
	self.overHealAbsorbGlow = overHealAbsorbGlow;
	self.healAbsorbBar = healAbsorbBar;
	self.healAbsorbBarLeftShadow = healAbsorbBarLeftShadow;
	self.healAbsorbBarRightShadow = healAbsorbBarRightShadow;
	self.myManaCostPredictionBar = myManaCostPredictionBar;
	if ( self.myHealPredictionBar ) then
		self.myHealPredictionBar:ClearAllPoints();
	end
	if ( self.otherHealPredictionBar ) then
		self.otherHealPredictionBar:ClearAllPoints();
	end
	if ( self.totalAbsorbBar ) then
		self.totalAbsorbBar:ClearAllPoints();
	end
	if ( self.myManaCostPredictionBar ) then
		self.myManaCostPredictionBar:ClearAllPoints();
	end

	if ( self.totalAbsorbBarOverlay ) then
		self.totalAbsorbBar.overlay = self.totalAbsorbBarOverlay;
		self.totalAbsorbBarOverlay:SetAllPoints(self.totalAbsorbBar);
		self.totalAbsorbBarOverlay.tileSize = 32;
	end
	if ( self.overAbsorbGlow ) then
		self.overAbsorbGlow:ClearAllPoints();
		self.overAbsorbGlow:SetPoint("TOPLEFT", self.healthbar, "TOPRIGHT", -7, 0);
		self.overAbsorbGlow:SetPoint("BOTTOMLEFT", self.healthbar, "BOTTOMRIGHT", -7, 0);
	end
	if ( self.healAbsorbBar ) then
		self.healAbsorbBar:ClearAllPoints();
		self.healAbsorbBar:SetTexture("Interface\\RaidFrame\\Absorb-Fill", true, true);
	end
	if ( self.overHealAbsorbGlow ) then
		self.overHealAbsorbGlow:ClearAllPoints();
		self.overHealAbsorbGlow:SetPoint("BOTTOMRIGHT", self.healthbar, "BOTTOMLEFT", 7, 0);
		self.overHealAbsorbGlow:SetPoint("TOPRIGHT", self.healthbar, "TOPLEFT", 7, 0);
	end
	if ( healAbsorbBarLeftShadow ) then
		self.healAbsorbBarLeftShadow:ClearAllPoints();
	end
	if ( healAbsorbBarRightShadow ) then
		self.healAbsorbBarRightShadow:ClearAllPoints();
	end
	if (self.healthbar) then
		self.healthbar.capNumericDisplay = true;
	end
	if (self.manabar) then
		self.manabar.capNumericDisplay = true;
	end
	JcfUnitFrameHealthBar_Initialize(unit, healthbar, healthtext, true);
	JcfUnitFrameManaBar_Initialize(unit, manabar, manatext, (unit == "player" or unit == "pet" or unit == "vehicle" or unit == "target" or unit == "focus"));
	JcfUnitFrameThreatIndicator_Initialize(unit, self, threatFeedbackUnit);
	JcfUnitFrame_Update(self);
	self:RegisterForClicks("LeftButtonUp", "RightButtonUp");
	self:RegisterEvent("UNIT_NAME_UPDATE");
	self:RegisterEvent("UNIT_DISPLAYPOWER");
	self:RegisterEvent("UNIT_PORTRAIT_UPDATE")
	self:RegisterEvent("PORTRAITS_UPDATED");
	if ( self.healAbsorbBar ) then
		self:RegisterUnitEvent("UNIT_HEAL_ABSORB_AMOUNT_CHANGED", unit);
	end
	if ( self.myHealPredictionBar ) then
		self:RegisterUnitEvent("UNIT_MAXHEALTH", unit);
		self:RegisterUnitEvent("UNIT_HEAL_PREDICTION", unit);
	end
	if ( self.totalAbsorbBar ) then
		self:RegisterUnitEvent("UNIT_ABSORB_AMOUNT_CHANGED", unit);
	end
	if ( self.myManaCostPredictionBar ) then
		self:RegisterUnitEvent("UNIT_SPELLCAST_START", unit);
		self:RegisterUnitEvent("UNIT_SPELLCAST_STOP", unit);
		self:RegisterUnitEvent("UNIT_SPELLCAST_FAILED", unit);
		self:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", unit);
	end
end

function JcfUnitFrame_SetUnit (self, unit, healthbar, manabar)
	-- update unit events if unit changes
	if ( self.unit ~= unit ) then
		if ( self.myHealPredictionBar ) then
			self:RegisterUnitEvent("UNIT_MAXHEALTH", unit);
			self:RegisterUnitEvent("UNIT_HEAL_PREDICTION", unit);
		end
		if ( self.totalAbsorbBar ) then
			self:RegisterUnitEvent("UNIT_ABSORB_AMOUNT_CHANGED", unit);
		end
		if ( not healthbar.frequentUpdates ) then
			healthbar:RegisterUnitEvent("UNIT_HEALTH", unit);
		end
		if ( manabar and not manabar.frequentUpdates ) then
			UnitFrameManaBar_RegisterDefaultEvents(manabar);
		end
		healthbar:RegisterUnitEvent("UNIT_MAXHEALTH", unit);
		
		if ( self.PlayerFrameHealthBarAnimatedLoss ) then
			self.PlayerFrameHealthBarAnimatedLoss:SetUnitHealthBar(unit, healthbar);
		end
	end

	self.unit = unit;
	healthbar.unit = unit;
	if ( manabar ) then	--Party Pet frames don't have a mana bar.
		manabar.unit = unit;
	end
	self:SetAttribute("unit", unit);
	securecall("JcfUnitFrame_Update", self);
end

function JcfUnitFrame_Update (self, isParty)
	if (self.name) then
		local name;
		if ( self.overrideName ) then
			name = self.overrideName;
		else
			name = self.unit;
		end
		if (isParty) then
			self.name:SetText(JcfGetUnitName(name, true));
		else
			self.name:SetText(JcfGetUnitName(name));
		end
	end
	self.healthbar.unitFrame = self
	JcfUnitFramePortrait_Update(self);
	JcfUnitFrameHealthBar_Update(self.healthbar, self.unit);
	JcfUnitFrameManaBar_Update(self.manabar, self.unit);
	JcfUnitFrameHealPredictionBars_UpdateMax(self);
	JcfUnitFrameHealPredictionBars_Update(self);
	JcfUnitFrameManaCostPredictionBars_Update(self);
end

function JcfUnitFramePortrait_Update (self)
	if ( self.portrait ) then
		SetPortraitTexture(self.portrait, self.unit);
	end
end

function JcfUnitFrame_OnEvent(self, event, ...)
	local eventUnit = ...

	local unit = self.unit;
	if ( eventUnit == unit ) then
		if ( event == "UNIT_NAME_UPDATE" ) then
			self.name:SetText(GetUnitName(unit));
		elseif ( event == "UNIT_PORTRAIT_UPDATE" ) then
			JcfUnitFramePortrait_Update(self);
		elseif ( event == "UNIT_DISPLAYPOWER" ) then
			if ( self.manabar ) then
				JcfUnitFrameManaBar_UpdateType(self.manabar);
			end
		elseif ( event == "UNIT_MAXHEALTH" ) then
			JcfUnitFrameHealPredictionBars_UpdateMax(self);
			JcfUnitFrameHealPredictionBars_Update(self);
		elseif ( event == "UNIT_HEAL_PREDICTION" ) then
			JcfUnitFrameHealPredictionBars_Update(self);
		elseif ( event == "UNIT_ABSORB_AMOUNT_CHANGED" ) then
			JcfUnitFrameHealPredictionBars_Update(self);
		elseif ( event == "UNIT_HEAL_ABSORB_AMOUNT_CHANGED" ) then
			JcfUnitFrameHealPredictionBars_Update(self);
		elseif ( event == "UNIT_SPELLCAST_START" or event == "UNIT_SPELLCAST_STOP" or event == "UNIT_SPELLCAST_FAILED" or event == "UNIT_SPELLCAST_SUCCEEDED" ) then
			local name, text, texture, startTime, endTime, isTradeSkill, castID, notInterruptible, spellID = UnitCastingInfo(unit);
			JcfUnitFrameManaCostPredictionBars_Update(self, event == "UNIT_SPELLCAST_START", startTime, endTime, spellID);
		end
	elseif ( event == "PORTRAITS_UPDATED" ) then
		JcfUnitFramePortrait_Update(self);
	end
end

function JcfUnitFrameManaCostPredictionBars_Update(frame, isStarting, startTime, endTime, spellID)
	if (not frame.manabar or not frame.myManaCostPredictionBar) then
		return;
	end

	local cost = 0;
	if (not isStarting or startTime == endTime) then
        local currentSpellID = select(9, UnitCastingInfo(frame.unit));
        if(currentSpellID and frame.predictedPowerCost) then --if we're currently casting something with a power cost, then whatever cast
		    cost = frame.predictedPowerCost;                 --just finished was allowed while casting, don't reset the original cast
        else
            frame.predictedPowerCost = nil;
        end
	else
		local costTable = GetSpellPowerCost(spellID);
		for _, costInfo in pairs(costTable) do
			if (costInfo.type == frame.manabar.powerType) then
				cost = costInfo.cost;
				break;
			end
		end
		frame.predictedPowerCost = cost;
	end
	local manaBarTexture = frame.manabar:GetStatusBarTexture();
	JcfUnitFrameManaBar_Update(frame.manabar, frame.unit);
	JcfUnitFrameUtil_UpdateManaFillBar(frame, manaBarTexture, frame.myManaCostPredictionBar, cost);
end

--WARNING: This function is very similar to the function CompactUnitFrameUtil_UpdateFillBar in CompactUnitFrame.lua.
--If you are making changes here, it is possible you may want to make changes there as well.
function JcfUnitFrameUtil_UpdateFillBarBase(frame, realbar, previousTexture, bar, amount, barOffsetXPercent)
	if ( amount == 0 ) then
		bar:Hide();
		if ( bar.overlay ) then
			bar.overlay:Hide();
		end
		return previousTexture;
	end

	local barOffsetX = 0;
	if ( barOffsetXPercent ) then
		local realbarSizeX = realbar:GetWidth();
		barOffsetX = realbarSizeX * barOffsetXPercent;
	end

	bar:SetPoint("TOPLEFT", previousTexture, "TOPRIGHT", barOffsetX, 0);
	bar:SetPoint("BOTTOMLEFT", previousTexture, "BOTTOMRIGHT", barOffsetX, 0);

	local totalWidth, totalHeight = realbar:GetSize();
	local _, totalMax = realbar:GetMinMaxValues();

	local barSize = (amount / totalMax) * totalWidth;
	bar:SetWidth(barSize);
	bar:Show();
	if ( bar.overlay ) then
		bar.overlay:SetTexCoord(0, barSize / bar.overlay.tileSize, 0, totalHeight / bar.overlay.tileSize);
		bar.overlay:Show();
	end
	return bar;
end

function JcfUnitFrameUtil_UpdateFillBar(frame, previousTexture, bar, amount, barOffsetXPercent)
	return JcfUnitFrameUtil_UpdateFillBarBase(frame, frame.healthbar, previousTexture, bar, amount, barOffsetXPercent);
end

function JcfUnitFrameUtil_UpdateManaFillBar(frame, previousTexture, bar, amount, barOffsetXPercent)
	return JcfUnitFrameUtil_UpdateFillBarBase(frame, frame.manabar, previousTexture, bar, amount, barOffsetXPercent);
end
function JcfUnitFrame_OnEnter (self)
	-- If showing newbie tips then only show the explanation
	if ( GetCVar("showNewbieTips") == "1" ) then
		if ( self == JcfPlayerFrame ) then
			GameTooltip_SetDefaultAnchor(GameTooltip, self);
			GameTooltip_AddNewbieTip(self, PARTY_OPTIONS_LABEL, 1.0, 1.0, 1.0, NEWBIE_TOOLTIP_PARTYOPTIONS);
			return;
		elseif ( self == JcfTargetFrame and UnitPlayerControlled("target") and not UnitIsUnit("target", "player") and not UnitIsUnit("target", "pet") ) then
			GameTooltip_SetDefaultAnchor(GameTooltip, self);
			GameTooltip_AddNewbieTip(self, PLAYER_OPTIONS_LABEL, 1.0, 1.0, 1.0, NEWBIE_TOOLTIP_PLAYEROPTIONS);
			return;
		end
	end
	JcfUnitFrame_UpdateTooltip(self);
end

function JcfUnitFrame_OnLeave (self)
	self.UpdateTooltip = nil;
	if ( GetCVar("showNewbieTips") == "1" ) then
		GameTooltip:Hide();
	else
		GameTooltip:FadeOut();
	end
end

function JcfUnitFrame_UpdateTooltip (self)
	GameTooltip_SetDefaultAnchor(GameTooltip, self);
	if ( GameTooltip:SetUnit(self.unit, self.hideStatusOnTooltip) ) then
		self.UpdateTooltip = JcfUnitFrame_UpdateTooltip;
	else
		self.UpdateTooltip = nil;
	end

	local r, g, b = GameTooltip_UnitColor(self.unit);
	GameTooltipTextLeft1:SetTextColor(r, g, b);
end

function JcfUnitFrameManaBar_UpdateType (manaBar)
	if ( not manaBar ) then
		return;
	end
	local unitFrame = manaBar:GetParent();
	local powerType, powerToken, altR, altG, altB = UnitPowerType(manaBar.unit);
	local prefix = _G[powerToken];
	local info = JcfPowerBarColor[powerToken];
	if ( info ) then
		if ( not manaBar.lockColor ) then
			local playerDeadOrGhost = manaBar.unit == "player" and (UnitIsDead("player") or UnitIsGhost("player")) and not UnitIsFeignDeath("player");
			if ( info.atlas ) then
				manaBar:SetStatusBarTexture(info.atlas);
				manaBar:SetStatusBarColor(1, 1, 1);
				manaBar:GetStatusBarTexture():SetDesaturated(playerDeadOrGhost);
				manaBar:GetStatusBarTexture():SetAlpha(playerDeadOrGhost and 0.5 or 1);
			else
				manaBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar");
				if ( playerDeadOrGhost ) then
					manaBar:SetStatusBarColor(0.6, 0.6, 0.6, 0.5);
				else
					manaBar:SetStatusBarColor(info.r, info.g, info.b, 1);
				end
			end

			if ( manaBar.FeedbackFrame ) then
				manaBar.FeedbackFrame:Initialize(info, manaBar.unit, powerType);
			end

			if ( manaBar.FullPowerFrame ) then
				manaBar.FullPowerFrame:Initialize(info.fullPowerAnim);
			end
		end
	else
		if ( not altR) then
			-- couldn't find a power token entry...default to indexing by power type or just mana if we don't have that either
			info = JcfPowerBarColor[powerType] or JcfPowerBarColor["MANA"];
		else
			if ( not manaBar.lockColor ) then
				manaBar:SetStatusBarColor(altR, altG, altB);
			end
		end
	end
	if ( manaBar.powerType ~= powerType or manaBar.powerType ~= powerType ) then
		manaBar.powerType = powerType;
		manaBar.powerToken = powerToken;
		if ( manaBar.FullPowerFrame ) then
			manaBar.FullPowerFrame:RemoveAnims();
		end
		manaBar.currValue = UnitPower("player", powerType);
	end

	-- Update the manabar text
	if ( not unitFrame.noTextPrefix ) then
		SetTextStatusBarTextPrefix(manaBar, prefix);
	end
	TextStatusBar_UpdateTextString(manaBar);

	-- Setup newbie tooltip
	if ( manaBar.unit ~= "pet") then
	    if ( unitFrame:GetName() == "JcfPlayerFrame" ) then
		    manaBar.tooltipTitle = prefix;
		    manaBar.tooltipText = _G["NEWBIE_TOOLTIP_MANABAR"..powerType];
	    else
		    manaBar.tooltipTitle = nil;
		    manaBar.tooltipText = nil;
	    end
	end
end
function JcfUnitFrameHealthBar_Initialize (unit, statusbar, statustext, frequentUpdates)
	if ( not statusbar ) then
		return;
	end

	statusbar.unit = unit;
	SetTextStatusBarText(statusbar, statustext);

	statusbar.frequentUpdates = frequentUpdates;
	if ( frequentUpdates ) then
		statusbar:RegisterEvent("VARIABLES_LOADED");
	end
	if ( GetCVarBool("predictedHealth") and frequentUpdates ) then
		statusbar:SetScript("OnUpdate", JcfUnitFrameHealthBar_OnUpdate);
	else
		statusbar:RegisterUnitEvent("UNIT_HEALTH", unit);
	end
	statusbar:RegisterUnitEvent("UNIT_MAXHEALTH", unit);
	statusbar:SetScript("OnEvent", JcfUnitFrameHealthBar_OnEvent);

	-- Setup newbie tooltip
	if ( statusbar and (statusbar:GetParent() == JcfPlayerFrame) ) then
		statusbar.tooltipTitle = HEALTH;
		statusbar.tooltipText = NEWBIE_TOOLTIP_HEALTHBAR;
	else
		statusbar.tooltipTitle = nil;
		statusbar.tooltipText = nil;
	end
end

function JcfUnitFrameHealthBar_OnEvent(self, event, ...)
	if ( event == "CVAR_UPDATE" ) then
		TextStatusBar_OnEvent(self, event, ...);
	elseif ( event == "VARIABLES_LOADED" ) then
		self:UnregisterEvent("VARIABLES_LOADED");
		if ( GetCVarBool("predictedHealth") and self.frequentUpdates ) then
			self:SetScript("OnUpdate", JcfUnitFrameHealthBar_OnUpdate);
			self:UnregisterEvent("UNIT_HEALTH");
		else
			self:RegisterUnitEvent("UNIT_HEALTH", self.unit);
			self:SetScript("OnUpdate", nil);
		end
	else
		if ( not self.ignoreNoUnit or UnitGUID(self.unit) ) then
			JcfUnitFrameHealthBar_Update(self, ...);
		end
	end
end

JcfAnimatedHealthLossMixin = {};

function JcfAnimatedHealthLossMixin:OnLoad()
	self:SetStatusBarColor(1, 0, 0, 1);
	self:SetDuration(.25);
	self:SetStartDelay(.1);
	self:SetPauseDelay(.05);
	self:SetPostponeDelay(.05);
end

function JcfAnimatedHealthLossMixin:SetDuration(duration)
	self.animationDuration = duration or 0;
end

function JcfAnimatedHealthLossMixin:SetStartDelay(delay)
	self.animationStartDelay = delay or 0;
end

function JcfAnimatedHealthLossMixin:SetPauseDelay(delay)
	self.animationPauseDelay = delay or 0;
end

function JcfAnimatedHealthLossMixin:SetPostponeDelay(delay)
	self.animationPostponeDelay = delay or 0;
end

function JcfAnimatedHealthLossMixin:SetUnitHealthBar(unit, healthBar)
	if self.unit ~= unit then
		healthBar.AnimatedLossBar = self;

		self.unit = unit;
		self:SetAllPoints(healthBar);
		self:UpdateHealthMinMax();
	end
end

function JcfAnimatedHealthLossMixin:UpdateHealthMinMax()
	local maxValue = UnitHealthMax(self.unit);
	self:SetMinMaxValues(0, maxValue);
end

function JcfAnimatedHealthLossMixin:GetHealthLossAnimationData(currentHealth, previousHealth)
	if self.animationStartTime then
		local totalElapsedTime = GetTime() - self.animationStartTime;
		if totalElapsedTime > 0 then
			local animCompletePercent = totalElapsedTime / self.animationDuration;
			if animCompletePercent < 1 and previousHealth > currentHealth then
				local healthDelta = previousHealth - currentHealth;
				local animatedLossAmount = previousHealth - (animCompletePercent * healthDelta);
				return animatedLossAmount, animCompletePercent;
			end
		else
			return previousHealth, 0;
		end
	end
	return 0, 1; -- Animated loss amount is 0, and the animation is fully complete.
end

function JcfAnimatedHealthLossMixin:CancelAnimation()
	self:Hide();
	self.animationStartTime = nil;
	self.animationCompletePercent = nil;
end

function JcfAnimatedHealthLossMixin:BeginAnimation(value)
	self.animationStartValue = value;
	self.animationStartTime = GetTime() + self.animationStartDelay;
	self.animationCompletePercent = 0;
	self:Show();
	self:SetValue(self.animationStartValue);
end

function JcfAnimatedHealthLossMixin:PostponeStartTime()
	self.animationStartTime = self.animationStartTime + self.animationPostponeDelay;
end

function JcfAnimatedHealthLossMixin:UpdateHealth(currentHealth, previousHealth)
	local delta = currentHealth - previousHealth;
	local hasLoss = delta < 0;
	local hasBegun = self.animationStartTime ~= nil;
	local isAnimating = hasBegun and self.animationCompletePercent > 0;

	if hasLoss and not hasBegun then
		self:BeginAnimation(previousHealth);
	elseif hasLoss and hasBegun and not isAnimating then
		self:PostponeStartTime();
	elseif hasLoss and isAnimating then
		-- Reset the starting value of the health to what the animated loss bar was when the new incoming damage happened
		-- and pause briefly when new damage occurs.
		self.animationStartValue = self:GetHealthLossAnimationData(previousHealth, self.animationStartValue);
		self.animationStartTime = GetTime() + self.animationPauseDelay;
	elseif not hasLoss and hasBegun and currentHealth >= self.animationStartValue then
		self:CancelAnimation();
	end
end

function JcfAnimatedHealthLossMixin:UpdateLossAnimation(currentHealth)
	local totalAbsorb = UnitGetTotalAbsorbs(self.unit) or 0;
	if totalAbsorb > 0 then
		self:CancelAnimation();
	end

	if self.animationStartTime then
		local animationValue, animationCompletePercent = self:GetHealthLossAnimationData(currentHealth, self.animationStartValue);
		self.animationCompletePercent = animationCompletePercent;
		if animationCompletePercent >= 1 then
			self:CancelAnimation();
		else
			self:SetValue(animationValue);
		end
	end
end

function JcfUnitFrameHealthBar_OnUpdate(self)
	if ( not self.disconnected and not self.lockValues) then
		local currValue = UnitHealth(self.unit);
		local animatedLossBar = self.AnimatedLossBar;

		if ( currValue ~= self.currValue ) then
			if ( not self.ignoreNoUnit or UnitGUID(self.unit) ) then

				if animatedLossBar then
					animatedLossBar:UpdateHealth(currValue, self.currValue);
				end

				self:SetValue(currValue);
				self.currValue = currValue;
				TextStatusBar_UpdateTextString(self);
				JcfUnitFrameHealPredictionBars_Update(self.unitFrame);
			end
		end

		if animatedLossBar then
			animatedLossBar:UpdateLossAnimation(currValue);
		end
	end
end

function JcfUnitFrameHealthBar_Update(statusbar, unit)
	if ( not statusbar or statusbar.lockValues ) then
		return;
	end

	if ( unit == statusbar.unit ) then
		local maxValue = UnitHealthMax(unit);

		-- Safety check to make sure we never get an empty bar.
		statusbar.forceHideText = false;
		if ( maxValue == 0 ) then
			maxValue = 1;
			statusbar.forceHideText = true;
		end
		statusbar:SetMinMaxValues(0, maxValue);

		if statusbar.AnimatedLossBar then
			statusbar.AnimatedLossBar:UpdateHealthMinMax();
		end

		statusbar.disconnected = not UnitIsConnected(unit);
		if ( statusbar.disconnected ) then
			if ( not statusbar.lockColor ) then
				statusbar:SetStatusBarColor(0.5, 0.5, 0.5);
			end
			statusbar:SetValue(maxValue);
			statusbar.currValue = maxValue;
		else
			local currValue = UnitHealth(unit);
			if ( not statusbar.lockColor ) then
				statusbar:SetStatusBarColor(0.0, 1.0, 0.0);
			end
			statusbar:SetValue(currValue);
			statusbar.currValue = currValue;
		end
	end
	TextStatusBar_UpdateTextString(statusbar);
	JcfUnitFrameHealPredictionBars_Update(statusbar.unitFrame);
end

function JcfUnitFrameHealthBar_OnValueChanged(self, value)
	TextStatusBar_OnValueChanged(self, value);
	HealthBar_OnValueChanged(self, value);
end

function JcfUnitFrameManaBar_UnregisterDefaultEvents(self)
	self:UnregisterEvent("UNIT_POWER_UPDATE");
end

function JcfUnitFrameManaBar_RegisterDefaultEvents(self)
	self:RegisterUnitEvent("UNIT_POWER_UPDATE", self.unit);
end

function JcfUnitFrameManaBar_Initialize (unit, statusbar, statustext, frequentUpdates)
	if ( not statusbar ) then
		return;
	end
	statusbar.unit = unit;
	statusbar.texture = statusbar:GetStatusBarTexture();
	SetTextStatusBarText(statusbar, statustext);

	statusbar.frequentUpdates = frequentUpdates;
	if ( frequentUpdates ) then
		statusbar:RegisterEvent("VARIABLES_LOADED");
	end
	if ( frequentUpdates ) then
		statusbar:SetScript("OnUpdate", JcfUnitFrameManaBar_OnUpdate);
	else
		JcfUnitFrameManaBar_RegisterDefaultEvents(statusbar);
	end
	statusbar:RegisterEvent("UNIT_DISPLAYPOWER");
	statusbar:RegisterUnitEvent("UNIT_MAXPOWER", unit);
	if ( statusbar.unit == "player" ) then
		statusbar:RegisterEvent("PLAYER_DEAD");
		statusbar:RegisterEvent("PLAYER_ALIVE");
		statusbar:RegisterEvent("PLAYER_UNGHOST");
	end
	statusbar:SetScript("OnEvent", JcfUnitFrameManaBar_OnEvent);
end

function JcfUnitFrameManaBar_OnEvent(self, event, ...)
	if ( event == "CVAR_UPDATE" ) then
		TextStatusBar_OnEvent(self, event, ...);
	elseif ( event == "VARIABLES_LOADED" ) then
		self:UnregisterEvent("VARIABLES_LOADED");
		if ( self.frequentUpdates ) then
			self:SetScript("OnUpdate", JcfUnitFrameManaBar_OnUpdate);
			JcfUnitFrameManaBar_UnregisterDefaultEvents(self);
		else
			JcfUnitFrameManaBar_RegisterDefaultEvents(self);
			self:SetScript("OnUpdate", nil);
		end
	elseif ( event == "PLAYER_ALIVE"  or event == "PLAYER_DEAD" or event == "PLAYER_UNGHOST" ) then
		JcfUnitFrameManaBar_UpdateType(self);
	else
		if ( not self.ignoreNoUnit or UnitGUID(self.unit) ) then
			JcfUnitFrameManaBar_Update(self, ...);
		end
	end
end

function JcfUnitFrameManaBar_OnUpdate(self)
	if ( not self.disconnected and not self.lockValues ) then
		local predictedCost = self:GetParent().predictedPowerCost;
		local currValue = UnitPower(self.unit, self.powerType);
		if (predictedCost) then
			currValue = currValue - predictedCost;
		end
		if ( currValue ~= self.currValue or self.forceUpdate ) then
			self.forceUpdate = nil;
			if ( not self.ignoreNoUnit or UnitGUID(self.unit) ) then
				if ( self.FeedbackFrame ) then
					-- Only show anim if change is more than 10%
					local oldValue = self.currValue or 0;
					if ( self.FeedbackFrame.maxValue ~= 0 and math.abs(currValue - oldValue) / self.FeedbackFrame.maxValue > 0.1 ) then
						self.FeedbackFrame:StartFeedbackAnim(oldValue, currValue);
					end
				end
				if ( self.FullPowerFrame and self.FullPowerFrame.active ) then
					self.FullPowerFrame:StartAnimIfFull(self.currValue or 0, currValue);
				end
				self:SetValue(currValue);
				self.currValue = currValue;
				TextStatusBar_UpdateTextString(self);
			end
		end
	end
end

function JcfUnitFrameManaBar_Update(statusbar, unit)
	if ( not statusbar or statusbar.lockValues ) then
		return;
	end

	if ( unit == statusbar.unit ) then
		-- be sure to update the power type before grabbing the max power!
		JcfUnitFrameManaBar_UpdateType(statusbar);

		local maxValue = UnitPowerMax(unit, statusbar.powerType);

		statusbar:SetMinMaxValues(0, maxValue);

		statusbar.disconnected = not UnitIsConnected(unit);
		if ( statusbar.disconnected ) then
			statusbar:SetValue(maxValue);
			statusbar.currValue = maxValue;
			if ( not statusbar.lockColor ) then
				statusbar:SetStatusBarColor(0.5, 0.5, 0.5);
			end
		else
			local predictedCost = statusbar:GetParent().predictedPowerCost;
			local currValue = UnitPower(unit, statusbar.powerType);
			if (predictedCost) then
				currValue = currValue - predictedCost;
			end
			if ( statusbar.FullPowerFrame ) then
				statusbar.FullPowerFrame:SetMaxValue(maxValue);
			end

			statusbar:SetValue(currValue);
			statusbar.forceUpdate = true;
		end
	end
	TextStatusBar_UpdateTextString(statusbar);
end

function JcfUnitFrameThreatIndicator_Initialize(unit, unitFrame, feedbackUnit)
	local indicator = unitFrame.threatIndicator;
	if ( not indicator ) then
		return;
	end

	indicator.unit = unit;
	indicator.feedbackUnit = feedbackUnit or unit;

	unitFrame:RegisterEvent("UNIT_THREAT_SITUATION_UPDATE");
	if ( unitFrame.OnEvent == nil ) then
		unitFrame.OnEvent = unitFrame:GetScript("OnEvent") or false;
	end
	unitFrame:SetScript("OnEvent", JcfUnitFrameThreatIndicator_OnEvent);
end

function JcfUnitFrameThreatIndicator_OnEvent(self, event, ...)
	if ( self.OnEvent ) then
		self.OnEvent(self, event, ...);
	end
	if ( event == "UNIT_THREAT_SITUATION_UPDATE" ) then
		JcfUnitFrame_UpdateThreatIndicator(self.threatIndicator, self.threatNumericIndicator,...);
	end
end

function JcfUnitFrame_UpdateThreatIndicator(indicator, numericIndicator, unit)
	if ( not indicator ) then
		return;
	end

	if ( not unit or unit == indicator.feedbackUnit ) then
		local status;
		if ( indicator.feedbackUnit ~= indicator.unit ) then
			status = UnitThreatSituation(indicator.feedbackUnit, indicator.unit);
		else
			status = UnitThreatSituation(indicator.feedbackUnit);
		end

		if ( IsThreatWarningEnabled() ) then
			if (status and status > 0) then
				indicator:SetVertexColor(GetThreatStatusColor(status));
				indicator:Show();
			else
				indicator:Hide();
			end

			if ( numericIndicator ) then
				if ( ShowNumericThreat() and not (UnitClassification(indicator.unit) == "minus") ) then
					local isTanking, status, percentage, rawPercentage = UnitDetailedThreatSituation(indicator.feedbackUnit, indicator.unit);
					local display = rawPercentage;
					if ( isTanking ) then
						display = UnitThreatPercentageOfLead(indicator.feedbackUnit, indicator.unit);
					end

					if ( display and display ~= 0 ) then
						display = min(display, MAX_DISPLAYED_THREAT_PERCENT);
						numericIndicator.text:SetText(format("%1.0f", display).."%");
						numericIndicator.bg:SetVertexColor(GetThreatStatusColor(status));
						numericIndicator:Show();
					else
						numericIndicator:Hide();
					end
				else
					numericIndicator:Hide();
				end
			end
		else
			indicator:Hide();
			if ( numericIndicator ) then
				numericIndicator:Hide();
			end
		end
	end
end

function JcfGetUnitName(unit, showServerName)
	local name, server = UnitName(unit);
	local relationship = UnitRealmRelationship(unit);
	if ( server and server ~= "" ) then
		if ( showServerName ) then
			return name.."-"..server;
		else
			if (relationship == LE_REALM_RELATION_VIRTUAL) then
				return name;
			else
				return name..FOREIGN_SERVER_LABEL;
			end
		end
	else
		return name;
	end
end

function JcfShowNumericThreat()
	if ( GetCVar("threatShowNumeric") == "1" ) then
		return true;
	else
		return false;
	end
end

function JcfUnitFrameHealPredictionBars_UpdateMax(self)
	if ( not self.myHealPredictionBar ) then
		return;
	end

	JcfUnitFrameHealPredictionBars_Update(self);
end

function JcfUnitFrameHealPredictionBars_UpdateSize(self)
	if ( not self.myHealPredictionBar or not self.otherHealPredictionBar ) then
		return;
	end

	JcfUnitFrameHealPredictionBars_Update(self);
end

--WARNING: This function is very similar to the function CompactUnitFrame_UpdateHealPrediction in CompactUnitFrame.lua.
--If you are making changes here, it is possible you may want to make changes there as well.
local MAX_INCOMING_HEAL_OVERFLOW = 1.0;
function JcfUnitFrameHealPredictionBars_Update(frame)
	if (not frame or not frame.myHealPredictionBar ) then
		return;
	end

	local _, maxHealth = frame.healthbar:GetMinMaxValues();
	local health = frame.healthbar:GetValue();
	if ( maxHealth <= 0 ) then
		return;
	end

	local myIncomingHeal = UnitGetIncomingHeals(frame.unit, "player") or 0;
	local allIncomingHeal = UnitGetIncomingHeals(frame.unit) or 0;
	local totalAbsorb = UnitGetTotalAbsorbs(frame.unit) or 0;

	local myCurrentHealAbsorb = 0;
	if ( frame.healAbsorbBar ) then
		myCurrentHealAbsorb = UnitGetTotalHealAbsorbs(frame.unit) or 0;

		--We don't fill outside the health bar with healAbsorbs.  Instead, an overHealAbsorbGlow is shown.
		if ( health < myCurrentHealAbsorb ) then
			frame.overHealAbsorbGlow:Show();
			myCurrentHealAbsorb = health;
		else
			frame.overHealAbsorbGlow:Hide();
		end
	end

	--See how far we're going over the health bar and make sure we don't go too far out of the frame.
	if ( health - myCurrentHealAbsorb + allIncomingHeal > maxHealth * MAX_INCOMING_HEAL_OVERFLOW ) then
		allIncomingHeal = maxHealth * MAX_INCOMING_HEAL_OVERFLOW - health + myCurrentHealAbsorb;
	end

	local otherIncomingHeal = 0;

	--Split up incoming heals.
	if ( allIncomingHeal >= myIncomingHeal ) then
		otherIncomingHeal = allIncomingHeal - myIncomingHeal;
	else
		myIncomingHeal = allIncomingHeal;
	end

	--We don't fill outside the the health bar with absorbs.  Instead, an overAbsorbGlow is shown.
	local overAbsorb = false;
	if ( health - myCurrentHealAbsorb + allIncomingHeal + totalAbsorb >= maxHealth or health + totalAbsorb >= maxHealth ) then
		if ( totalAbsorb > 0 ) then
			overAbsorb = true;
		end

		if ( allIncomingHeal > myCurrentHealAbsorb ) then
			totalAbsorb = max(0,maxHealth - (health - myCurrentHealAbsorb + allIncomingHeal));
		else
			totalAbsorb = max(0,maxHealth - health);
		end
	end

	if ( overAbsorb ) then
		frame.overAbsorbGlow:Show();
	else
		frame.overAbsorbGlow:Hide();
	end

	local healthTexture = frame.healthbar:GetStatusBarTexture();
	local myCurrentHealAbsorbPercent = 0;
	local healAbsorbTexture = nil;

	if ( frame.healAbsorbBar ) then
		myCurrentHealAbsorbPercent = myCurrentHealAbsorb / maxHealth;

		--If allIncomingHeal is greater than myCurrentHealAbsorb, then the current
		--heal absorb will be completely overlayed by the incoming heals so we don't show it.
		if ( myCurrentHealAbsorb > allIncomingHeal ) then
			local shownHealAbsorb = myCurrentHealAbsorb - allIncomingHeal;
			local shownHealAbsorbPercent = shownHealAbsorb / maxHealth;

			healAbsorbTexture =  JcfUnitFrameUtil_UpdateFillBar(frame, healthTexture, frame.healAbsorbBar, shownHealAbsorb, -shownHealAbsorbPercent);

			--If there are incoming heals the left shadow would be overlayed by the incoming heals
			--so it isn't shown.
			if ( allIncomingHeal > 0 ) then
				frame.healAbsorbBarLeftShadow:Hide();
			else
				frame.healAbsorbBarLeftShadow:SetPoint("TOPLEFT", healAbsorbTexture, "TOPLEFT", 0, 0);
				frame.healAbsorbBarLeftShadow:SetPoint("BOTTOMLEFT", healAbsorbTexture, "BOTTOMLEFT", 0, 0);
				frame.healAbsorbBarLeftShadow:Show();
			end

			-- The right shadow is only shown if there are absorbs on the health bar.
			if ( totalAbsorb > 0 ) then
				frame.healAbsorbBarRightShadow:SetPoint("TOPLEFT", healAbsorbTexture, "TOPRIGHT", -8, 0);
				frame.healAbsorbBarRightShadow:SetPoint("BOTTOMLEFT", healAbsorbTexture, "BOTTOMRIGHT", -8, 0);
				frame.healAbsorbBarRightShadow:Show();
			else
				frame.healAbsorbBarRightShadow:Hide();
			end
		else
			frame.healAbsorbBar:Hide();
			frame.healAbsorbBarLeftShadow:Hide();
			frame.healAbsorbBarRightShadow:Hide();
		end
	end

	--Show myIncomingHeal on the health bar.
	local incomingHealTexture = JcfUnitFrameUtil_UpdateFillBar(frame, healthTexture, frame.myHealPredictionBar, myIncomingHeal, -myCurrentHealAbsorbPercent);

	--Append otherIncomingHeal on the health bar
	if (myIncomingHeal > 0) then
		incomingHealTexture = JcfUnitFrameUtil_UpdateFillBar(frame, incomingHealTexture, frame.otherHealPredictionBar, otherIncomingHeal);
	else
		incomingHealTexture = JcfUnitFrameUtil_UpdateFillBar(frame, healthTexture, frame.otherHealPredictionBar, otherIncomingHeal, -myCurrentHealAbsorbPercent);
	end

	--Append absorbs to the correct section of the health bar.
	local appendTexture = nil;
	if ( healAbsorbTexture ) then
		--If there is a healAbsorb part shown, append the absorb to the end of that.
		appendTexture = healAbsorbTexture;
	else
		--Otherwise, append the absorb to the end of the the incomingHeals part;
		appendTexture = incomingHealTexture;
	end
	JcfUnitFrameUtil_UpdateFillBar(frame, appendTexture, frame.totalAbsorbBar, totalAbsorb)
end