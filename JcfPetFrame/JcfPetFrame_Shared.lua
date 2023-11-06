function JcfPetFrame_AdjustPoint(self)

end

function JcfPetFrame_OnLoad (self)
	self.noTextPrefix = true;

	JcfPetFrameHealthBar.LeftText = JcfPetFrameHealthBarTextLeft;
	JcfPetFrameHealthBar.RightText = JcfPetFrameHealthBarTextRight;
	JcfPetFrameManaBar.LeftText = JcfPetFrameManaBarTextLeft;
	JcfPetFrameManaBar.RightText = JcfPetFrameManaBarTextRight;

	JcfUnitFrame_Initialize(self, "pet", JcfPetName, JcfPetPortrait,
	JcfPetFrameHealthBar, JcfPetFrameHealthBarText, 
	JcfPetFrameManaBar, JcfPetFrameManaBarText,
	JcfPetFrameFlash, nil, nil,
	JcfPetFrameMyHealPredictionBar, JcfPetFrameOtherHealPredictionBar,
	JcfPetFrameTotalAbsorbBar, JcfPetFrameTotalAbsorbBarOverlay, 
	JcfPetFrameOverAbsorbGlow, JcfPetFrameOverHealAbsorbGlow, JcfPetFrameHealAbsorbBar,
	JcfPetFrameHealAbsorbBarLeftShadow, JcfPetFrameHealAbsorbBarRightShadow);
	self.attackModeCounter = 0;
	self.attackModeSign = -1;
	--self.flashState = 1;
	--self.flashTimer = 0;
	CombatFeedback_Initialize(self, JcfPetHitIndicator, 30);
	JcfPetFrame_Update(self);
	self:RegisterUnitEvent("UNIT_PET", "player");
	self:RegisterEvent("PET_ATTACK_START");
	self:RegisterEvent("PET_ATTACK_STOP");
	self:RegisterEvent("PET_UI_UPDATE");
	self:RegisterEvent("UNIT_MAXPOWER");
	self:RegisterUnitEvent("UNIT_COMBAT", "pet", "player");
	self:RegisterUnitEvent("UNIT_AURA", "pet", "player");
	
	-- self:RegisterForClicks("AnyUp")
	-- self:SetAttribute("*type1", "target")
	-- self:SetAttribute("*type2", "togglemenu")

	if( JcfPetFrame_AdjustPoint ) then
		JcfPetFrame_AdjustPoint(self);
	end

	self:HookScript("OnShow", function()
		JcfUnitFrame_Update(self);
		JcfPetFrame_Update(self);
		JcfPlayerFrame_AdjustAttachments();
	end)

	self:HookScript("OnHide", function()	
		JcfPlayerFrame_AdjustAttachments();
	end)
end

function JcfPetFrame_Update (self, override)
	if ( (not JcfPlayerFrame.animating) or (override) ) then
		if ( UnitIsVisible(self.unit) and PetUsesPetFrame() and not JcfPlayerFrame.vehicleHidesPet ) then
			if ( self:IsShown() ) then
				JcfUnitFrame_Update(self);
			else
				self:Show();
			end
			--self.flashState = 1;
			--self.flashTimer = PET_FLASH_ON_TIME;
			if ( UnitPowerMax(self.unit) == 0 ) then
				JcfPetFrameTexture:SetTexture("Interface\\TargetingFrame\\UI-SmallTargetingFrame-NoMana");
				JcfPetFrameManaBarText:Hide();
			else
				JcfPetFrameTexture:SetTexture("Interface\\TargetingFrame\\UI-SmallTargetingFrame");
			end
			JcfPetAttackModeTexture:Hide();
			JcfRefreshBuffs(self, self.unit, nil, nil, true);
		else
			self:Hide();
		end
	end
end

function JcfPetFrame_OnEvent (self, event, ...)
	JcfUnitFrame_OnEvent(self, event, ...);
	local arg1, arg2, arg3, arg4, arg5 = ...;
	if ( event == "UNIT_PET" or event == "UNIT_EXITED_VEHICLE" or event == "PET_UI_UPDATE" ) then
		JcfUnitFrame_SetUnit(self, "pet", JcfPetFrameHealthBar, JcfPetFrameManaBar);
		JcfPetFrame_Update(self);
	elseif ( event == "UNIT_COMBAT" ) then
		if ( arg1 == self.unit ) then
			CombatFeedback_OnCombatEvent(self, arg2, arg3, arg4, arg5);
		end
	elseif ( event == "UNIT_AURA" ) then
		if ( arg1 == self.unit ) then
			JcfRefreshBuffs(self, self.unit, nil, nil, true);
		end
	elseif ( event == "PET_ATTACK_START" ) then
		JcfPetAttackModeTexture:SetVertexColor(1.0, 1.0, 1.0, 1.0);
		JcfPetAttackModeTexture:Show();
	elseif ( event == "PET_ATTACK_STOP" ) then
		JcfPetAttackModeTexture:Hide();
	elseif (event == "UNIT_MAXPOWER" ) then
		JcfPetFrame_Update(self);
	end
end

function JcfPetFrame_OnUpdate (self, elapsed)
	if ( JcfPetAttackModeTexture:IsShown() ) then
		local alpha = 255;
		local counter = self.attackModeCounter + elapsed;
		local sign    = self.attackModeSign;

		if ( counter > 0.5 ) then
			sign = -sign;
			self.attackModeSign = sign;
		end
		counter = mod(counter, 0.5);
		self.attackModeCounter = counter;

		if ( sign == 1 ) then
			alpha = (55  + (counter * 400)) / 255;
		else
			alpha = (255 - (counter * 400)) / 255;
		end
		JcfPetAttackModeTexture:SetVertexColor(1.0, 1.0, 1.0, alpha);
	end
	--CombatFeedback_OnUpdate(self, elapsed);
	-- Expiration flash stuff
	--local petTimeRemaining = nil;
	--if ( GetPetTimeRemaining() ) then
	---	if ( self.flashState == 1 ) then
	--		self:SetAlpha(this.flashTimer/PET_FLASH_ON_TIME);
	--	else
	--		self:SetAlpha((PET_FLASH_OFF_TIME - this.flashTimer)/PET_FLASH_OFF_TIME);
	--	end
	--	petTimeRemaining = GetPetTimeRemaining() / 1000;
	--end
	--if ( petTimeRemaining and (petTimeRemaining < PET_WARNING_TIME) ) then
	--	PetFrame.flashTimer = PetFrame.flashTimer - elapsed;
	--	if ( PetFrame.flashTimer <= 0 ) then
	--		if ( PetFrame.flashState == 1 ) then
	--			PetFrame.flashState = 0;
	--			PetFrame.flashTimer = PET_FLASH_OFF_TIME;
	--		else
	--			PetFrame.flashState = 1;
	--			PetFrame.flashTimer = PET_FLASH_ON_TIME;
	--		end
	--	end
	--end
	
end

function JcfPetCastingBarFrame_OnLoad (self)
	--CastingBarFrame_OnLoad(self, "pet", false, false);
	self.Icon:Hide();

	self:RegisterEvent("UNIT_PET");

	self.showCastbar = UnitIsPossessed("pet");
end

function JcfPetCastingBarFrame_OnEvent (self, event, ...)
	local arg1 = ...;
	if ( event == "UNIT_PET" ) then
		if ( arg1 == "player" ) then
			self.showCastbar = UnitIsPossessed("pet");

			if ( not self.showCastbar ) then
				self:Hide();
			elseif ( self.casting or self.channeling ) then
				self:Show();
			end
		end
		return;
	end
	--CastingBarFrame_OnEvent(self, event, ...);
end