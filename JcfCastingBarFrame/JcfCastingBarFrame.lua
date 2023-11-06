JCF_CASTING_BAR_ALPHA_STEP = 0.05;
JCF_CASTING_BAR_FLASH_STEP = 0.2;
JCF_CASTING_BAR_HOLD_TIME = 1;
JCF_CASTING_BAR_PLACEHOLDER_FILE_ID = 136235;

function JcfCastingBarFrame_OnLoad(self, unit, showTradeSkills, showShield)
	JcfCastingBarFrame_SetStartCastColor(self, 1.0, 0.7, 0.0, 1);
	JcfCastingBarFrame_SetStartChannelColor(self, 0.0, 1.0, 0.0, 1);
	JcfCastingBarFrame_SetFinishedCastColor(self, 0.0, 1.0, 0.0, 1);
	JcfCastingBarFrame_SetFailedCastColor(self, 1.0, 0.0, 0.0, 1);

	--classic cast bars should flash green when finished casting
	--JcfCastingBarFrame_SetUseStartColorForFinished(self, true);
	JcfCastingBarFrame_SetUseStartColorForFlash(self, true);

	JcfCastingBarFrame_SetUnit(self, unit, showTradeSkills, showShield);

	self.showCastbar = true;
	self.notInterruptible = false;

	local point, relativeTo, relativePoint, offsetX, offsetY = self.Spark:GetPoint();
	if ( point == "CENTER" ) then
		self.Spark.offsetY = offsetY;
	end
end

function JcfCastingBarFrame_SetStartCastColor(self, r, g, b, a)
	self.startCastColor = CreateColor(r, g, b, a);
end

function JcfCastingBarFrame_SetStartChannelColor(self, r, g, b, a)
	self.startChannelColor = CreateColor(r, g, b, a);
end

function JcfCastingBarFrame_SetFinishedCastColor(self, r, g, b, a)
	self.finishedCastColor = CreateColor(r, g, b, a);
end

function JcfCastingBarFrame_SetFailedCastColor(self, r, g, b, a)
	self.failedCastColor = CreateColor(r, g, b, a);
end

function JcfCastingBarFrame_SetUseStartColorForFinished(self, finishedColorSameAsStart)
	self.finishedColorSameAsStart = finishedColorSameAsStart;
end

function JcfCastingBarFrame_SetUseStartColorForFlash(self, flashColorSameAsStart)
	self.flashColorSameAsStart = flashColorSameAsStart;
end

-- Fades additional widgets along with the cast bar, in case these widgets are not parented or use ignoreParentAlpha
function JcfCastingBarFrame_AddWidgetForFade(self, widget)
	if not self.additionalFadeWidgets then
		self.additionalFadeWidgets = {};
	end
	self.additionalFadeWidgets[widget] = true;
end

function JcfCastingBarFrame_SetUnit(self, unit, showTradeSkills, showShield)
	if self.unit ~= unit then
		self.unit = unit;
		self.showTradeSkills = showTradeSkills;
		self.showShield = showShield;

		self.casting = nil;
		self.channeling = nil;
		self.holdTime = 0;
		self.fadeOut = nil;

		if unit then
			self:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED");
			self:RegisterEvent("UNIT_SPELLCAST_DELAYED");
			self:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START");
			self:RegisterEvent("UNIT_SPELLCAST_CHANNEL_UPDATE");
			self:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP");
			self:RegisterEvent("UNIT_SPELLCAST_EMPOWER_START");
			self:RegisterEvent("UNIT_SPELLCAST_EMPOWER_UPDATE");
			self:RegisterEvent("UNIT_SPELLCAST_EMPOWER_STOP");
			self:RegisterEvent("PLAYER_ENTERING_WORLD");
			self:RegisterUnitEvent("UNIT_SPELLCAST_START", unit);
			self:RegisterUnitEvent("UNIT_SPELLCAST_STOP", unit);
			self:RegisterUnitEvent("UNIT_SPELLCAST_FAILED", unit);

			JcfCastingBarFrame_OnEvent(self, "PLAYER_ENTERING_WORLD")
		else
			self:UnregisterEvent("UNIT_SPELLCAST_INTERRUPTED");
			self:UnregisterEvent("UNIT_SPELLCAST_DELAYED");
			self:UnregisterEvent("UNIT_SPELLCAST_CHANNEL_START");
			self:UnregisterEvent("UNIT_SPELLCAST_CHANNEL_UPDATE");
			self:UnregisterEvent("UNIT_SPELLCAST_CHANNEL_STOP");
			self:RegisterEvent("UNIT_SPELLCAST_EMPOWER_START");
			self:RegisterEvent("UNIT_SPELLCAST_EMPOWER_UPDATE");
			self:RegisterEvent("UNIT_SPELLCAST_EMPOWER_STOP");
			self:UnregisterEvent("PLAYER_ENTERING_WORLD");
			self:UnregisterEvent("UNIT_SPELLCAST_START");
			self:UnregisterEvent("UNIT_SPELLCAST_STOP");
			self:UnregisterEvent("UNIT_SPELLCAST_FAILED");

			self:Hide();
		end
	end
end

function JcfCastingBarFrame_OnShow(self)
	if ( self.unit ) then
		if ( self.casting ) then
			local _, _, _, startTime = UnitCastingInfo(self.unit);
			if ( startTime ) then
				self.value = (GetTime() - (startTime / 1000));
			end
		else
			local _, _, _, _, endTime = UnitChannelInfo(self.unit);
			if ( endTime ) then
				self.value = ((endTime / 1000) - GetTime());
			end
		end
	end
end

function JcfCastingBarFrame_GetEffectiveStartColor(self, isChannel)
	return isChannel and self.startChannelColor or self.startCastColor;
end

function JcfCastingBarFrame_OnEvent(self, event, ...)
	local arg1 = ...;
	
	local unit = self.unit;
	if ( event == "PLAYER_ENTERING_WORLD" ) then
		local nameChannel = UnitChannelInfo(unit);
		local nameSpell = UnitCastingInfo(unit);
		if ( nameChannel ) then
			event = "UNIT_SPELLCAST_CHANNEL_START";
			arg1 = unit;
		elseif ( nameSpell ) then
			event = "UNIT_SPELLCAST_START";
			arg1 = unit;
		else
		    JcfCastingBarFrame_FinishSpell(self);
		end
	end

	if ( arg1 ~= unit ) then
		return;
	end
	
	if ( event == "UNIT_SPELLCAST_START" ) then
		local name, text, texture, startTime, endTime, isTradeSkill, castID, notInterruptible = UnitCastingInfo(unit);
		self.notInterruptible = notInterruptible;

		if( notInterruptible ) then
			JcfCastingBarFrame_SetUseStartColorForFinished(self, false);
		end

		if ( not name or (not self.showTradeSkills and isTradeSkill)) then
			self:Hide();
			return;
		end

		local startColor = JcfCastingBarFrame_GetEffectiveStartColor(self, false);
		self:SetStatusBarColor(startColor:GetRGBA());
		if self.flashColorSameAsStart then
			self.Flash:SetVertexColor(startColor:GetRGBA());
		else
			self.Flash:SetVertexColor(1, 1, 1);
		end
		JcfCastingBarFrame_ClearStages(self)

		if ( self.Spark ) then
			self.Spark:Show();
		end
		self.value = (GetTime() - (startTime / 1000));
		self.maxValue = (endTime - startTime) / 1000;
		self:SetMinMaxValues(0, self.maxValue);
		self:SetValue(self.value);
		if ( self.Text ) then
			self.Text:SetText(text);
		end
		if ( self.Icon ) then
			JcfCastingBarFrame_SetIcon(self, texture);
			if ( self.iconWhenNoninterruptible ) then
				self.Icon:SetShown(not notInterruptible);
			end
		end
		JcfCastingBarFrame_ApplyAlpha(self, 1.0);
		self.holdTime = 0;
		self.casting = true;
		self.castID = castID;
		self.channeling = nil;
		self.fadeOut = nil;

		if ( self.BorderShield ) then
			if ( self.showShield and notInterruptible ) then
				self.BorderShield:Show();
				if ( self.BarBorder ) then
					self.BarBorder:Hide();
				end
			else
				self.BorderShield:Hide();
				if ( self.BarBorder ) then
					self.BarBorder:Show();
				end
			end
		end
		if ( self.showCastbar ) then
			self:Show();
		end

	elseif ( event == "UNIT_SPELLCAST_STOP" or event == "UNIT_SPELLCAST_CHANNEL_STOP"  or event == "UNIT_SPELLCAST_EMPOWER_STOP") then
		if ( not self:IsVisible() ) then
			self:Hide();
		end
		if ( (self.casting and event == "UNIT_SPELLCAST_STOP" and select(2, ...) == self.castID) or
		     (self.channeling and event == "UNIT_SPELLCAST_CHANNEL_STOP" or event == "UNIT_SPELLCAST_EMPOWER_STOP") ) then
			if ( self.Spark ) then
				self.Spark:Hide();
			end
			if ( self.Flash ) then
				self.Flash:SetAlpha(0.0);
				self.Flash:Show();
			end
			self:SetValue(self.maxValue);
			if ( event == "UNIT_SPELLCAST_STOP" ) then
				self.casting = nil;
				if not self.finishedColorSameAsStart then
					self:SetStatusBarColor(self.finishedCastColor:GetRGBA());
				end
			else
				self.channeling = nil;
				if (self.reverseChanneling) then
					self.casting = nil;
				end
				self.reverseChanneling = nil;
			end
			self.flash = true;
			self.fadeOut = true;
			self.holdTime = 0;
		end
	elseif ( event == "UNIT_SPELLCAST_FAILED" or event == "UNIT_SPELLCAST_INTERRUPTED" ) then
		if ( self:IsShown() and
		     (self.casting and select(2, ...) == self.castID) and not self.fadeOut ) then
			self:SetValue(self.maxValue);
			self:SetStatusBarColor(self.failedCastColor:GetRGBA());
			if ( self.Spark ) then
				self.Spark:Hide();
			end
			if ( self.Text ) then
				if ( event == "UNIT_SPELLCAST_FAILED" ) then
					self.Text:SetText(FAILED);
				else
					self.Text:SetText(INTERRUPTED);
				end
			end
			self.casting = nil;
			self.channeling = nil;
			self.fadeOut = true;
			self.holdTime = GetTime() + JCF_CASTING_BAR_HOLD_TIME;
		end
	elseif ( event == "UNIT_SPELLCAST_DELAYED" ) then
		if ( self:IsShown() ) then
			local name, text, texture, startTime, endTime, isTradeSkill, castID, notInterruptible = UnitCastingInfo(unit);
			self.notInterruptible = notInterruptible;

			if ( not name or (not self.showTradeSkills and isTradeSkill)) then
				-- if there is no name, there is no bar
				self:Hide();
				return;
			end
			self.value = (GetTime() - (startTime / 1000));
			self.maxValue = (endTime - startTime) / 1000;
			self:SetMinMaxValues(0, self.maxValue);
			if ( not self.casting ) then
				self:SetStatusBarColor(JcfCastingBarFrame_GetEffectiveStartColor(self, false):GetRGBA());
				JcfCastingBarFrame_ClearStages(self)
				if ( self.Spark ) then
					self.Spark:Show();
				end
				if ( self.Flash ) then
					self.Flash:SetAlpha(0.0);
					self.Flash:Hide();
				end
				self.casting = true;
				self.channeling = nil;
				self.flash = nil;
				self.fadeOut = nil;
			end
		end
	elseif ( event == "UNIT_SPELLCAST_CHANNEL_START" or event == "UNIT_SPELLCAST_EMPOWER_START") then
		local name, text, texture, startTime, endTime, isTradeSkill, notInterruptible, spellID, _, numStages = UnitChannelInfo(unit);
		self.notInterruptible = notInterruptible;

		if ( not name or (not self.showTradeSkills and isTradeSkill)) then
			-- if there is no name, there is no bar
			self:Hide();
			return;
		end

		local isChargeSpell = numStages > 0;
		if isChargeSpell then
			endTime = endTime + GetUnitEmpowerHoldAtMaxTime(self.unit);
		end

		local startColor = JcfCastingBarFrame_GetEffectiveStartColor(self, true);
		if self.flashColorSameAsStart then
			self.Flash:SetVertexColor(startColor:GetRGBA());
		else
			self.Flash:SetVertexColor(1, 1, 1);
		end
		if (isChargeSpell) then
			self:SetStatusBarColor(0, 0, 0, 0)
		else
			self:SetStatusBarColor(startColor:GetRGBA());
		end
		self.maxValue = (endTime - startTime) / 1000;

		JcfCastingBarFrame_ClearStages(self)

		if (isChargeSpell) then
			self.value = GetTime() - (startTime / 1000);
		else
			self.value = (endTime / 1000) - GetTime();
		end

		self:SetMinMaxValues(0, self.maxValue);
		self:SetValue(self.value);
		if ( self.Text ) then
			self.Text:SetText(isChargeSpell and "" or text);
		end
		if ( self.Icon ) then
			JcfCastingBarFrame_SetIcon(self, texture);
		end
		if ( self.Spark ) then
			if (isChargeSpell) then
				self.Spark:Show();
			else
				self.Spark:Hide();
			end
		end
		JcfCastingBarFrame_ApplyAlpha(self, 1.0);
		self.holdTime = 0;
		self.fadeOut = nil;

		if (isChargeSpell) then
			self.reverseChanneling = true;
			self.casting = true;
			self.channeling = false;
		else
			self.reverseChanneling = nil;
			self.casting = nil;
			self.channeling = true;
		end

		if ( self.BorderShield ) then
			if ( self.showShield and notInterruptible ) then
				self.BorderShield:Show();
				if ( self.BarBorder ) then
					self.BarBorder:Hide();
				end
			else
				self.BorderShield:Hide();
				if ( self.BarBorder ) then
					self.BarBorder:Show();
				end
			end
		end
		if ( self.showCastbar ) then
			self:Show();
		end

		if (isChargeSpell) then
			JcfCastingBarFrame_AddStages(self, numStages, spellID);
		end

	elseif ( event == "UNIT_SPELLCAST_CHANNEL_UPDATE" or event == "UNIT_SPELLCAST_EMPOWER_UPDATE"  ) then
		if ( self:IsShown() ) then
			local name, text, texture, startTime, endTime, isTradeSkill = UnitChannelInfo(unit);
			if ( not name or (not self.showTradeSkills and isTradeSkill)) then
				-- if there is no name, there is no bar
				self:Hide();
				return;
			end
			self.value = ((endTime / 1000) - GetTime());
			self.maxValue = (endTime - startTime) / 1000;
			self:SetMinMaxValues(0, self.maxValue);
			self:SetValue(self.value);
		end
	elseif ( event == "UNIT_SPELLCAST_INTERRUPTIBLE" or event == "UNIT_SPELLCAST_NOT_INTERRUPTIBLE" ) then
		JcfCastingBarFrame_UpdateInterruptibleState(self, event == "UNIT_SPELLCAST_NOT_INTERRUPTIBLE");
	end
end

function JcfCastingBarFrame_UpdateInterruptibleState(self, notInterruptible)
	if ( self.casting or self.channeling ) then
		local startColor = JcfCastingBarFrame_GetEffectiveStartColor(self, self.channeling);
		self:SetStatusBarColor(startColor:GetRGBA());

		if self.flashColorSameAsStart then
			self.Flash:SetVertexColor(startColor:GetRGBA());
		end

		if ( self.BorderShield ) then
			if ( self.showShield and notInterruptible ) then
				self.BorderShield:Show();
				if ( self.BarBorder ) then
					self.BarBorder:Hide();
				end
			else
				self.BorderShield:Hide();
				if ( self.BarBorder ) then
					self.BarBorder:Show();
				end
			end
		end

		if ( self.Icon and self.iconWhenNoninterruptible ) then
			self.Icon:SetShown(not notInterruptible);
		end
	end
end

function JcfCastingBarFrame_OnUpdate(self, elapsed)
	if (not self.isInEditMode) then
		if ( self.casting or self.reverseChanneling) then
			self.value = self.value + elapsed;
			if(self.reverseChanneling and self.NumStages > 0) then
				JcfCastingBarFrame_UpdateStage(self);
			end
			if ( self.value >= self.maxValue ) then
				self:SetValue(self.maxValue);
				if (not self.reverseChanneling) then
					JcfCastingBarFrame_FinishSpell(self, self.Spark, self.Flash);
				end
				return;
			end
			self:SetValue(self.value);
			if ( self.Flash ) then
				self.Flash:Hide();
			end
			if ( self.Spark ) then
				local sparkPosition = (self.value / self.maxValue) * self:GetWidth();
				self.Spark:SetPoint("CENTER", self, "LEFT", sparkPosition, self.Spark.offsetY or 2);
			end
		elseif ( self.channeling ) then
			self.value = self.value - elapsed;
			if ( self.value <= 0 ) then
				JcfCastingBarFrame_FinishSpell(self, self.Spark, self.Flash);
				return;
			end
			self:SetValue(self.value);
			if ( self.Flash ) then
				self.Flash:Hide();
			end
		elseif ( GetTime() < self.holdTime ) then
			return;
		elseif ( self.flash ) then
			local alpha = 0;
			if ( self.Flash ) then
				alpha = self.Flash:GetAlpha() + JCF_CASTING_BAR_FLASH_STEP;
			end
			if ( alpha < 1 ) then
				if ( self.Flash ) then
					self.Flash:SetAlpha(alpha);
				end
			else
				if ( self.Flash ) then
					self.Flash:SetAlpha(1.0);
				end
				self.flash = nil;
			end
		elseif ( self.fadeOut ) then
			local alpha = self:GetAlpha() - JCF_CASTING_BAR_ALPHA_STEP;
			if ( alpha > 0 ) then
				JcfCastingBarFrame_ApplyAlpha(self, alpha);
			else
				self.fadeOut = nil;
				self:Hide();
			end
		end
	else
		self:SetMinMaxValues(0, 10);
		self:SetValue(5)
		self:Show()
	end
end

function JcfCastingBarFrame_ApplyAlpha(self, alpha)
	self:SetAlpha(alpha);
	if self.additionalFadeWidgets then
		for widget in pairs(self.additionalFadeWidgets) do
			widget:SetAlpha(alpha);
		end
	end
end

function JcfCastingBarFrame_FinishSpell(self)
	if not self.finishedColorSameAsStart then
		self:SetStatusBarColor(self.finishedCastColor:GetRGBA());
	end
	if ( self.Spark ) then
		self.Spark:Hide();
	end
	if ( self.Flash ) then
		self.Flash:SetAlpha(0.0);
		self.Flash:Show();
	end
	self.flash = true;
	self.fadeOut = true;
	self.casting = nil;
	self.channeling = nil;
end

function JcfCastingBarFrame_UpdateIsShown(self)
	if ( self.casting and self.showCastbar ) then
		JcfCastingBarFrame_OnEvent(self, "PLAYER_ENTERING_WORLD")
	else
		self:Hide();
	end
end

function JcfCastingBarFrame_SetLook(self, look)
	if ( look == "CLASSIC" ) then
		self:SetWidth(195);
		self:SetHeight(13);
		-- border
		self.Border:ClearAllPoints();
		self.Border:SetTexture("Interface\\CastingBar\\UI-CastingBar-Border");
		self.Border:SetWidth(256);
		self.Border:SetHeight(64);
		self.Border:SetPoint("TOP", 0, 28);
		-- bordershield
		self.BorderShield:ClearAllPoints();
		self.BorderShield:SetWidth(256);
		self.BorderShield:SetHeight(64);
		self.BorderShield:SetPoint("TOP", 0, 28);
		-- text
		self.Text:ClearAllPoints();
		self.Text:SetWidth(185);
		self.Text:SetHeight(16);
		self.Text:SetPoint("TOP", 0, 5);
		self.Text:SetFontObject("GameFontHighlight");
		-- icon
		self.Icon:Hide();
		-- bar spark
		self.Spark.offsetY = 2;
		-- bar flash
		self.Flash:ClearAllPoints();
		self.Flash:SetTexture("Interface\\CastingBar\\UI-CastingBar-Flash");
		self.Flash:SetWidth(256);
		self.Flash:SetHeight(64);
		self.Flash:SetPoint("TOP", 0, 28);
	elseif ( look == "UNITFRAME" ) then
		self:SetWidth(150);
		self:SetHeight(10);
		-- border
		self.Border:ClearAllPoints();
		self.Border:SetTexture("Interface\\CastingBar\\UI-CastingBar-Border-Small");
		self.Border:SetWidth(0);
		self.Border:SetHeight(49);
		self.Border:SetPoint("TOPLEFT", -23, 20);
		self.Border:SetPoint("TOPRIGHT", 23, 20);
		-- bordershield
		self.BorderShield:ClearAllPoints();
		self.BorderShield:SetWidth(0);
		self.BorderShield:SetHeight(49);
		self.BorderShield:SetPoint("TOPLEFT", -28, 20);
		self.BorderShield:SetPoint("TOPRIGHT", 18, 20);
		-- text
		self.Text:ClearAllPoints();
		self.Text:SetWidth(0);
		self.Text:SetHeight(16);
		self.Text:SetPoint("TOPLEFT", 0, 4);
		self.Text:SetPoint("TOPRIGHT", 0, 4);
		self.Text:SetFontObject("SystemFont_Shadow_Small");
		-- icon
		self.Icon:Show();
		-- bar spark
		self.Spark.offsetY = 0;
		-- bar flash
		self.Flash:ClearAllPoints();
		self.Flash:SetTexture("Interface\\CastingBar\\UI-CastingBar-Flash-Small");
		self.Flash:SetWidth(0);
		self.Flash:SetHeight(49);
		self.Flash:SetPoint("TOPLEFT", -23, 20);
		self.Flash:SetPoint("TOPRIGHT", 23, 20);
	end
end

function JcfCastingBarFrame_SetIcon(self, icon)
	if (self.Icon) then
		if (icon == JCF_CASTING_BAR_PLACEHOLDER_FILE_ID) then
			icon = 0;
		end
		self.Icon:SetTexture(icon);
	end
end

local JCF_CASTBAR_STAGE_INVALID = -1;
local JCF_CASTBAR_STAGE_DURATION_INVALID = -1;

function JcfCastingBarFrame_AddStages(self, numStages, spellID)
	self.CurrSpellStage = JCF_CASTBAR_STAGE_INVALID;
	self.NumStages = numStages + 1;
	self.SpellID = spellID;
	local sumDuration = 0;
	self.StagePoints = {};
	self.StagePips = {};
	self.StageTiers = {};
	local hasFX = self.StandardFinish ~= nil;
	local stageMaxValue = self.maxValue * 1000;

	local getStageDuration = function(stage)
		if stage == self.NumStages then	
			return GetUnitEmpowerHoldAtMaxTime(self.unit);
		else
			return GetUnitEmpowerStageDuration(self.unit, stage-1);
		end
	end;

	local castBarLeft = self:GetLeft();
	local castBarRight = self:GetRight();

	if not castBarLeft or not castBarRight then
		return;
	end

	local castBarWidth = castBarRight - castBarLeft;

	-- create starting left stage
	local stagePipName = "StagePip" .. 0;
	local stagePip = self[stagePipName];
	if not stagePip then
		stagePip = CreateFrame("FRAME", nil, self, hasFX and "JcfCastingBarFrameStagePipFXTemplate" or "JcfCastingBarFrameStagePipTemplate");
		self[stagePipName] = stagePip;
	end

	if stagePip then
		table.insert(self.StagePips, 0, stagePip);
		stagePip:ClearAllPoints();
		stagePip:SetPoint("TOP", self, "TOPLEFT", 0, -1);
		stagePip:SetPoint("BOTTOM", self, "BOTTOMLEFT", 0, 1);
		stagePip:Show();
		stagePip.BasePip:SetShown(true);
	end

	for i = 1,self.NumStages-1,1 do
		local duration = getStageDuration(i);
		if(duration > JCF_CASTBAR_STAGE_DURATION_INVALID) then
			sumDuration = sumDuration + duration;
			local portion = sumDuration / stageMaxValue;
			local offset = castBarWidth * portion;
			self.StagePoints[i] = sumDuration;

			local stagePipName = "StagePip" .. i;
			local stagePip = self[stagePipName];
			if not stagePip then
				stagePip = CreateFrame("FRAME", nil, self, hasFX and "JcfCastingBarFrameStagePipFXTemplate" or "JcfCastingBarFrameStagePipTemplate");
				self[stagePipName] = stagePip;
			end

			if stagePip then
				table.insert(self.StagePips, stagePip);
				stagePip:ClearAllPoints();
				stagePip:SetPoint("TOP", self, "TOPLEFT", offset, -1);
				stagePip:SetPoint("BOTTOM", self, "BOTTOMLEFT", offset, 1);
				stagePip:Show();
				stagePip.BasePip:SetShown(i ~= self.NumStages);
			end
		end
	end

	for i = 0,self.NumStages-1,1 do
		local chargeTierName = "ChargeTier" .. i;
		local chargeTier = self[chargeTierName];
		if not chargeTier then
			chargeTier = CreateFrame("FRAME", nil, self, "JcfCastingBarFrameStageTierTemplate");
			self[chargeTierName] = chargeTier;
		end

		if chargeTier then
			local leftStagePip = self.StagePips[i];
			local rightStagePip = self.StagePips[i+1];

			if leftStagePip then
				chargeTier:SetPoint("TOPLEFT", leftStagePip, "TOP", 0, 0);
			end
			if rightStagePip then
				chargeTier:SetPoint("BOTTOMRIGHT", rightStagePip, "BOTTOM", 0, 0);
			else
				chargeTier:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, 1);
			end

			local chargeTierLeft = chargeTier:GetLeft();
			local chargeTierRight = chargeTier:GetRight();

			local left = (chargeTierLeft - castBarLeft) / castBarWidth;
			local right = 1.0 - ((castBarRight - chargeTierRight) / castBarWidth);

			chargeTier.FlashAnim:Stop();
			chargeTier.FinishAnim:Stop();

			local ix = (i==0) and self.NumStages-1 or i
			chargeTier.Normal:SetAtlas(("ui-castingbar-tier%d-empower"):format(ix));
			chargeTier.Disabled:SetAtlas(("ui-castingbar-disabled-tier%d-empower"):format(ix));
			chargeTier.Glow:SetAtlas(("ui-castingbar-glow-tier%d-empower"):format(ix));

			chargeTier.Normal:SetTexCoord(left, right, 0, 1);
			chargeTier.Disabled:SetTexCoord(left, right, 0, 1);
			chargeTier.Glow:SetTexCoord(left, right, 0, 1);

			chargeTier.Normal:SetShown(false);
			chargeTier.Disabled:SetShown(true);
			chargeTier.Glow:SetAlpha(0);

			chargeTier:Show();
			table.insert(self.StageTiers, chargeTier);
		end
	end	
end

function JcfCastingBarFrame_ClearStages(self)

	if self.ChargeGlow then
		self.ChargeGlow:SetShown(false);
	end
	if self.ChargeFlash then
		self.ChargeFlash:SetAlpha(0);
	end

	if (self.StagePips) then		
		for _, stagePip in pairs(self.StagePips) do
			local maxStage = self.NumStages;
			for i = 1, maxStage do
				local stageAnimName = "Stage" .. i;
				local stageAnim = stagePip[stageAnimName];
				if stageAnim then
					stageAnim:Stop();
				end
			end
			stagePip:Hide();
		end
	end

	if (self.StageTiers) then		
		for _, stageTier in pairs(self.StageTiers) do
			stageTier:Hide();
		end
	end

	self.NumStages = 0;
	if (self.StagePoints) then table.wipe(self.StagePoints); end
	if (self.StageTiers) then table.wipe(self.StageTiers); end
end

function JcfCastingBarFrame_UpdateStage(self)
	local maxStage = 0;
	local stageValue = self.value*1000;
	for i = 1, self.NumStages do
		if self.StagePoints[i] then
			if stageValue > self.StagePoints[i] then
				maxStage = i;
			else
				break;
			end
		end
	end

	if (maxStage ~= self.CurrSpellStage and maxStage > JCF_CASTBAR_STAGE_INVALID and maxStage <= self.NumStages) then
		self.CurrSpellStage = maxStage;
		if maxStage < self.NumStages then
			local stagePip = self.StagePips[maxStage];
			if stagePip and stagePip.StageAnim then
				stagePip.StageAnim:Play();
			end
		end

		if self.playCastFX then
			if maxStage == self.NumStages - 1 then
				if self.StageFinish then
					self.StageFinish:Play();
				end
			elseif maxStage > 0 then
				if self.StageFlash then
					self.StageFlash:Play();
				end
			end
		end
		
		local chargeTierName = "ChargeTier" .. self.CurrSpellStage;
		local chargeTier = self[chargeTierName];
		if chargeTier then
			chargeTier.Normal:SetShown(true);
			chargeTier.Disabled:SetShown(false);
			chargeTier.FlashAnim:Play();
		end
	end
end

function JcfCastingBarFrame_HideSpark(self)
end

function JcfCastingBarAnim_OnInterruptSparkAnimFinish(self)

end

function JcfCastingBarAnim_OnFadeOutFinish()
	
end