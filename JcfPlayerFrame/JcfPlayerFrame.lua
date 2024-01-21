JCF_REQUIRED_REST_HOURS = 5;

function JcfPlayerFrame_OnLoad(self)
	JcfPlayerFrameHealthBar.LeftText = JcfPlayerFrameHealthBarTextLeft;
	JcfPlayerFrameHealthBar.RightText = JcfPlayerFrameHealthBarTextRight;
	JcfPlayerFrameManaBar.LeftText = JcfPlayerFrameManaBarTextLeft;
	JcfPlayerFrameManaBar.RightText = JcfPlayerFrameManaBarTextRight;
	local healthBar = JcfPlayerFrameHealthBar;
	local manaBar = JcfPlayerFrameManaBar;

	JcfUnitFrame_Initialize(self, "player", JcfPlayerName,
                         JcfPlayerPortrait,
						 JcfPlayerFrameHealthBar, JcfPlayerFrameHealthBarText,
						 JcfPlayerFrameManaBar, JcfPlayerFrameManaBarText,
						 nil, nil, nil,
						 healthBar.MyHealPredictionBar,
						 healthBar.OtherHealPredictionBar,
						 healthBar.TotalAbsorbBar,
						 healthBar.TotalAbsorbBarOverlay,
						 healthBar.OverAbsorbGlow,
						 healthBar.OverHealAbsorbGlow,
						 healthBar.HealAbsorbBar,
						 healthBar.HealAbsorbBarLeftShadow,
						 healthBar.HealAbsorbBarRightShadow, 
						 manaBar.ManaCostPredictionBar);

	self.statusCounter = 0;
	self.statusSign = -1;

	local healthBarTexture = healthBar:GetStatusBarTexture();
	healthBarTexture:AddMaskTexture(healthBar.HealthBarMask);
	healthBarTexture:SetTexelSnappingBias(0);
	healthBarTexture:SetSnapToPixelGrid(false);

	manaBar.FeedbackFrame:AddMaskTexture(manaBar.ManaBarMask);
	local manaBarTexture = manaBar:GetStatusBarTexture();
	manaBarTexture:AddMaskTexture(manaBar.ManaBarMask);
	manaBarTexture:SetTexelSnappingBias(0);
	manaBarTexture:SetSnapToPixelGrid(false);

	CombatFeedback_Initialize(self, JcfPlayerHitIndicator, 30);
	JcfPlayerFrame_Update();
	self:RegisterEvent("UNIT_LEVEL");
	self:RegisterEvent("UNIT_FACTION");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("PLAYER_ENTER_COMBAT");
	self:RegisterEvent("PLAYER_LEAVE_COMBAT");
	self:RegisterEvent("PLAYER_REGEN_DISABLED");
	self:RegisterEvent("PLAYER_REGEN_ENABLED");
	self:RegisterEvent("PLAYER_UPDATE_RESTING");
	self:RegisterEvent("PARTY_LEADER_CHANGED");
	self:RegisterEvent("GROUP_ROSTER_UPDATE");
	self:RegisterEvent("READY_CHECK");
	self:RegisterEvent("READY_CHECK_CONFIRM");
	self:RegisterEvent("READY_CHECK_FINISHED");
	self:RegisterEvent("UNIT_ENTERED_VEHICLE");
	self:RegisterEvent("UNIT_ENTERING_VEHICLE");
	self:RegisterEvent("UNIT_EXITING_VEHICLE");
	self:RegisterEvent("UNIT_EXITED_VEHICLE");
	self:RegisterEvent("VARIABLES_LOADED");
	self:RegisterUnitEvent("UNIT_COMBAT", "player", "vehicle");
	self:RegisterUnitEvent("UNIT_MAXPOWER", "player", "vehicle");
	self:RegisterUnitEvent("UNIT_PORTRAIT_UPDATE", "player", "vehicle")

	-- Chinese playtime stuff
	self:RegisterEvent("PLAYTIME_CHANGED");

	-- Clicks
	-- self:RegisterForClicks("AnyUp")
	-- self:SetAttribute("*type1", "target")
	-- self:SetAttribute("*type2", "togglemenu")

	JcfPlayerAttackBackground:SetVertexColor(0.8, 0.1, 0.1);
	JcfPlayerAttackBackground:SetAlpha(0.4);

	self:SetClampRectInsets(20, 0, 0, 0);
	JcfUIParent_UpdateTopFramePositions();

	JcfPlayerFramePortraitCooldown:SetSwipeTexture("Interface\\CHARACTERFRAME\\TempPortraitAlphaMaskSmall")
end

--This is overwritten in LocalizationPost for different languages.
function JcfPlayerFrame_UpdateLevelTextAnchor(level)
	if ( level >= 100 ) then
		JcfPlayerLevelText:SetPoint("CENTER", JcfPlayerFrameTexture, "CENTER", -64, -16);
	else
		JcfPlayerLevelText:SetPoint("CENTER", JcfPlayerFrameTexture, "CENTER", -62, -16);
	end
end

function JcfPlayerFrame_Update ()
	if ( UnitExists("player") ) then
		local level = UnitLevel(JcfPlayerFrame.unit);
		JcfPlayerLevelText:SetVertexColor(1.0, 0.82, 0.0, 1.0);
		JcfPlayerFrame_UpdateLevelTextAnchor(level);
		JcfPlayerLevelText:SetText(level);
		JcfPlayerFrame_UpdatePartyLeader();
		JcfPlayerFrame_UpdatePvPStatus();
		JcfPlayerFrame_UpdateStatus();
		JcfPlayerFrame_UpdatePlaytime();
		JcfPlayerFrame_UpdateLayout();
	end
end

function JcfPlayerFrame_UpdatePartyLeader()
	if ( UnitIsGroupLeader("player") ) then
		JcfPlayerLeaderIcon:Show()
		JcfPlayerGuideIcon:Hide();
	else
		JcfPlayerLeaderIcon:Hide();
		JcfPlayerGuideIcon:Hide();
	end

	local lootMethod, lootMaster = GetLootMethod();
	if ( lootMaster == 0 and IsInGroup() ) then
		JcfPlayerMasterIcon:Show();
	else
		JcfPlayerMasterIcon:Hide();
	end
end

function JcfPlayerFrame_UpdatePvPStatus()
	local factionGroup, factionName = UnitFactionGroup("player");
	if ( UnitIsPVPFreeForAll("player") ) then
		if ( not JcfPlayerPVPIcon:IsShown() ) then
			PlaySound(SOUNDKIT.IG_PVP_UPDATE);
		end
		JcfPlayerPrestigePortrait:Hide();
		JcfPlayerPrestigeBadge:Hide();
		JcfPlayerPVPIcon:SetTexture("Interface\\TargetingFrame\\UI-PVP-FFA");
		JcfPlayerPVPIcon:Show();
		

		-- Setup newbie tooltip
		JcfPlayerPVPIconHitArea.tooltipTitle = PVPFFA;
		JcfPlayerPVPIconHitArea.tooltipText = NEWBIE_TOOLTIP_PVPFFA;
		JcfPlayerPVPIconHitArea:Show();
	elseif ( factionGroup and factionGroup ~= "Neutral" and UnitIsPVP("player") ) then
		if ( not JcfPlayerPVPIcon:IsShown() ) then
			PlaySound(SOUNDKIT.IG_PVP_UPDATE);
		end

		
		JcfPlayerPrestigePortrait:Hide();
		JcfPlayerPrestigeBadge:Hide();
		JcfPlayerPVPIcon:SetTexture("Interface\\TargetingFrame\\UI-PVP-"..factionGroup);

		JcfPlayerPVPIcon:Show();

		-- Setup newbie tooltip
		JcfPlayerPVPIconHitArea.tooltipTitle = factionName;
		JcfPlayerPVPIconHitArea.tooltipText = _G["NEWBIE_TOOLTIP_"..strupper(factionGroup)];
		JcfPlayerPVPIconHitArea:Show();
	else
		JcfPlayerPrestigePortrait:Hide();
		JcfPlayerPrestigeBadge:Hide();
		JcfPlayerPVPIcon:Hide();
		JcfPlayerPVPIconHitArea:Hide();
	end
end

function JcfPlayerFrame_OnEvent(self, event, ...)
	JcfUnitFrame_OnEvent(self, event, ...);

	local arg1, arg2, arg3, arg4, arg5 = ...;
	if ( event == "UNIT_LEVEL" ) then
		if ( arg1 == "player" ) then
			JcfPlayerFrame_Update();
		end
	elseif ( event == "UNIT_COMBAT" ) then
		if ( arg1 == self.unit ) then
			CombatFeedback_OnCombatEvent(self, arg2, arg3, arg4, arg5);
		end
	elseif ( event == "UNIT_FACTION" ) then
		if ( arg1 == "player" ) then
			JcfPlayerFrame_UpdatePvPStatus();
		end
	elseif ( event == "PLAYER_ENTERING_WORLD" ) then
		JcfPlayerFrame_ResetPosition(self);
		JcfPlayerFrame_ToPlayerArt(self);
		JcfUnitFrame_SetUnit(self, "player", JcfPlayerFrameHealthBar, JcfPlayerFrameManaBar);
		self.inCombat = nil;
		self.onHateList = nil;
		JcfPlayerFrame_Update();
		JcfPlayerFrame_UpdateStatus();
	elseif ( event == "PLAYER_ENTER_COMBAT" ) then
		self.inCombat = 1;
		JcfPlayerFrame_UpdateStatus();
	elseif ( event == "PLAYER_LEAVE_COMBAT" ) then
		self.inCombat = nil;
		JcfPlayerFrame_UpdateStatus();
	elseif ( event == "PLAYER_REGEN_DISABLED" ) then
		self.onHateList = 1;
		JcfPlayerFrame_UpdateStatus();
	elseif ( event == "PLAYER_REGEN_ENABLED" ) then
		self.onHateList = nil;
		JcfPlayerFrame_UpdateStatus();
	elseif ( event == "PLAYER_UPDATE_RESTING" ) then
		JcfPlayerFrame_UpdateStatus();
	elseif ( event == "PARTY_LEADER_CHANGED" or event == "GROUP_ROSTER_UPDATE" ) then
		JcfPlayerFrame_UpdateGroupIndicator();
		JcfPlayerFrame_UpdatePartyLeader();
		JcfPlayerFrame_UpdateReadyCheck();
	elseif ( event == "PLAYTIME_CHANGED" ) then
		JcfPlayerFrame_UpdatePlaytime();
	elseif ( event == "READY_CHECK" or event == "READY_CHECK_CONFIRM" ) then
		JcfPlayerFrame_UpdateReadyCheck();
	elseif ( event == "READY_CHECK_FINISHED" ) then
		ReadyCheck_Finish(JcfPlayerFrameReadyCheck, DEFAULT_READY_CHECK_STAY_TIME);
	elseif ( event == "UNIT_RUNIC_POWER" and arg1 == "player" ) then
		JcfPlayerFrame_SetRunicPower(UnitPower("player"));
	elseif ( event == "UNIT_ENTERING_VEHICLE" ) then
		if ( arg1 == "player" ) then
			if ( arg2 ) then
				JcfPlayerFrame_AnimateOut(self);
			else
				if ( JcfPlayerFrame.state == "vehicle" ) then
					JcfPlayerFrame_AnimateOut(self);
				end
			end
		end
	elseif ( event == "UNIT_ENTERED_VEHICLE" ) then
		if ( arg1 == "player" ) then
			self.inSeat = true;
			if (UnitInVehicleHidesPetFrame("player")) then
				self.vehicleHidesPet = true;
			end
			JcfPlayerFrame_UpdateArt(self);
		end
	elseif ( event == "UNIT_EXITING_VEHICLE" ) then
		if ( arg1 == "player" ) then
			if ( self.state == "vehicle" ) then
				JcfPlayerFrame_AnimateOut(self);
			else
				self.updatePetFrame = true;
			end
			self.vehicleHidesPet = false;
		end
	elseif ( event == "UNIT_EXITED_VEHICLE" ) then
		if ( arg1 == "player" ) then
			self.inSeat = true;
			JcfPlayerFrame_UpdateArt(self);
		end
	elseif (event == "UNIT_PORTRAIT_UPDATE") then
		if (arg1 == "player") then
			JcfPlayerFrame_UpdateArt(self);
		end
	elseif ( event == "VARIABLES_LOADED" ) then
		JcfPlayerFrame_SetLocked(not PLAYER_FRAME_UNLOCKED);
		if ( JCF_PLAYER_FRAME_CASTBARS_SHOWN ) then
			JcfPlayerFrame_AttachCastBar();
		end
	end
end

local function JcfPlayerFrame_AnimPos(self, fraction)
	return "TOPLEFT", UIParent, "TOPLEFT", -19, fraction*140-4;
end

function JcfPlayerFrame_ResetPosition(self)
	CancelAnimations(JcfPlayerFrame);
	self.isAnimatedOut = false;
	JcfUIParent_UpdateTopFramePositions();
	self.inSequence = false;
	if JcfPetFrame then
		JcfPetFrame_Update(JcfPetFrame);
	end
end

local JcfPlayerFrameAnimTable = {
	totalTime = 0.3,
	updateFunc = "SetPoint",
	getPosFunc = JcfPlayerFrame_AnimPos,
	}
function JcfPlayerFrame_AnimateOut(self)
	self.inSeat = false;
	self.animFinished = false;
	self.inSequence = true;
	self.isAnimatedOut = true;
	if ( self:IsUserPlaced() ) then
		JcfPlayerFrame_AnimFinished(JcfPlayerFrame);
	else
		SetUpAnimation(JcfPlayerFrame, JcfPlayerFrameAnimTable, JcfPlayerFrame_AnimFinished, false)
	end
end

function JcfPlayerFrame_AnimFinished(self)
	self.animFinished = true;
	JcfPlayerFrame_UpdateArt(self);
end

function JcfPlayerFrame_IsAnimatedOut(self)
	return self.isAnimatedOut;
end

function JcfPlayerFrame_UpdateArt(self)
	if ( self.inSeat ) then
		if ( self:IsUserPlaced() ) then
			JcfPlayerFrame_SequenceFinished(PlayerFrame);
		elseif ( self.animFinished and self.inSequence ) then
			SetUpAnimation(PlayerFrame, JcfPlayerFrameAnimTable, JcfPlayerFrame_SequenceFinished, true)
		end
		if ( UnitHasVehiclePlayerFrameUI("player") ) then
			JcfPlayerFrame_ToVehicleArt(self, UnitVehicleSkinType("player"));
		else
            JcfPlayerFrame_ToPlayerArt(self);
		end
	elseif ( self.updatePetFrame ) then
		-- leaving a vehicle that didn't change player art
		self.updatePetFrame = false;
		if (JcfPetFrame) then
			JcfPetFrame_Update(JcfPetFrame);
		end
	end
end

function JcfPlayerFrame_SequenceFinished(self)
	self.isAnimatedOut = false;
	self.inSequence = false;
	if (JcfPetFrame) then
		JcfPetFrame_Update(JcfPetFrame);
	end
end

function JcfPlayerFrame_ToVehicleArt(self, vehicleType)
	--Swap frame

	JcfPlayerFrame.state = "vehicle";

	JcfUnitFrame_SetUnit(self, "vehicle", JcfPlayerFrameHealthBar, JcfPlayerFrameManaBar);
	JcfPlayerFrame_Update();

	JcfPlayerFrameTexture:Hide();
	if ( vehicleType == "Natural" ) then
		JcfPlayerFrameVehicleTexture:SetTexture("Interface\\Vehicles\\UI-Vehicle-Frame-Organic");
		JcfPlayerFrameFlash:SetTexture("Interface\\Vehicles\\UI-Vehicle-Frame-Organic-Flash");
		JcfPlayerFrameFlash:SetTexCoord(-0.02, 1, 0.07, 0.86);
		JcfPlayerFrameHealthBar:SetWidth(103);
		JcfPlayerFrameHealthBar:SetPoint("TOPLEFT",116,-41);
		JcfPlayerFrameManaBar:SetWidth(103);
		JcfPlayerFrameManaBar:SetPoint("TOPLEFT",116,-52);
	else
		JcfPlayerFrameVehicleTexture:SetTexture("Interface\\Vehicles\\UI-Vehicle-Frame");
		JcfPlayerFrameFlash:SetTexture("Interface\\Vehicles\\UI-Vehicle-Frame-Flash");
		JcfPlayerFrameFlash:SetTexCoord(-0.02, 1, 0.07, 0.86);
		JcfPlayerFrameHealthBar:SetWidth(100);
		JcfPlayerFrameHealthBar:SetPoint("TOPLEFT",119,-41);
		JcfPlayerFrameManaBar:SetWidth(100);
		JcfPlayerFrameManaBar:SetPoint("TOPLEFT",119,-52);
	end
	JcfPlayerFrame_ShowVehicleTexture();

	JcfPlayerName:SetPoint("CENTER",50,23);
	JcfPlayerLeaderIcon:SetPoint("TOPLEFT",44,-10);
	JcfPlayerFrameGroupIndicator:SetPoint("BOTTOMLEFT", PlayerFrame, "TOPLEFT", 97, -13);

	JcfPlayerFrameBackground:SetWidth(114);
	JcfPlayerLevelText:Hide();
end

function JcfPlayerFrame_ToPlayerArt(self)
	--Unswap frame

	JcfPlayerFrame.state = "player";

	JcfUnitFrame_SetUnit(self, "player", JcfPlayerFrameHealthBar, JcfPlayerFrameManaBar);
	JcfPlayerFrame_Update();

	JcfPlayerFrameTexture:Show();
	JcfPlayerFrame_HideVehicleTexture();
	JcfPlayerName:SetPoint("CENTER",50,19);
	JcfPlayerLeaderIcon:SetPoint("TOPLEFT",44,-10);
	JcfPlayerFrameGroupIndicator:SetPoint("BOTTOMLEFT", JcfPlayerFrame, "TOPLEFT", 97, -20);
	JcfPlayerFrameHealthBar:SetWidth(119);
	JcfPlayerFrameHealthBar:SetPoint("TOPLEFT",106,-41);
	JcfPlayerFrameManaBar:SetWidth(119);
	JcfPlayerFrameManaBar:SetPoint("TOPLEFT",106,-52);
	JcfPlayerFrameBackground:SetWidth(119);
	JcfPlayerLevelText:Show();
end

function JcfPlayerFrame_UpdateVoiceStatus (status)
	JcfPlayerSpeakerFrame:Hide();
end

function JcfPlayerFrame_UpdateReadyCheck ()
	local readyCheckStatus = GetReadyCheckStatus("player");
	if ( readyCheckStatus ) then
		if ( readyCheckStatus == "ready" ) then
			ReadyCheck_Confirm(JcfPlayerFrameReadyCheck, 1);
		elseif ( readyCheckStatus == "notready" ) then
			ReadyCheck_Confirm(JcfPlayerFrameReadyCheck, 0);
		else -- "waiting"
			ReadyCheck_Start(JcfPlayerFrameReadyCheck);
		end
	else
		JcfPlayerFrameReadyCheck:Hide();
	end
end

function JcfPlayerFrame_OnUpdate (self, elapsed)
	if ( JcfPlayerStatusTexture:IsShown() ) then
		local alpha = 255;
		local counter = self.statusCounter + elapsed;
		local sign    = self.statusSign;

		if ( counter > 0.5 ) then
			sign = -sign;
			self.statusSign = sign;
		end
		counter = mod(counter, 0.5);
		self.statusCounter = counter;

		if ( sign == 1 ) then
			alpha = (55  + (counter * 400)) / 255;
		else
			alpha = (255 - (counter * 400)) / 255;
		end
		JcfPlayerStatusTexture:SetAlpha(alpha);
		JcfPlayerStatusGlow:SetAlpha(alpha);
	end
	--CombatFeedback_OnUpdate(self, elapsed);
end

function JcfPlayerFrame_OnReceiveDrag ()
	-- if ( CursorHasItem() ) then
	-- 	AutoEquipCursorItem();
	-- end
end

function JcfPlayerFrame_UpdateStatus()
	if ( UnitHasVehiclePlayerFrameUI("player") ) then
		JcfPlayerStatusTexture:Hide()
		JcfPlayerRestIcon:Hide()
		JcfPlayerAttackIcon:Hide()
		JcfPlayerRestGlow:Hide()
		JcfPlayerAttackGlow:Hide()
		JcfPlayerStatusGlow:Hide()
		JcfPlayerAttackBackground:Hide()
	elseif ( IsResting() ) then
		JcfPlayerStatusTexture:SetVertexColor(1.0, 0.88, 0.25, 1.0);
		JcfPlayerStatusTexture:Show();
		JcfPlayerRestIcon:Show();
		JcfPlayerAttackIcon:Hide();
		JcfPlayerRestGlow:Show();
		JcfPlayerAttackGlow:Hide();
		JcfPlayerStatusGlow:Show();
		JcfPlayerAttackBackground:Hide();
	elseif ( JcfPlayerFrame.inCombat ) then
		JcfPlayerStatusTexture:SetVertexColor(1.0, 0.0, 0.0, 1.0);
		JcfPlayerStatusTexture:Show();
		JcfPlayerAttackIcon:Show();
		JcfPlayerRestIcon:Hide();
		JcfPlayerAttackGlow:Show();
		JcfPlayerRestGlow:Hide();
		JcfPlayerStatusGlow:Show();
		JcfPlayerAttackBackground:Show();
	elseif ( JcfPlayerFrame.onHateList ) then
		JcfPlayerAttackIcon:Show();
		JcfPlayerRestIcon:Hide();
		JcfPlayerStatusGlow:Hide();
		JcfPlayerAttackBackground:Hide();
	else
		JcfPlayerStatusTexture:Hide();
		JcfPlayerRestIcon:Hide();
		JcfPlayerAttackIcon:Hide();
		JcfPlayerStatusGlow:Hide();
		JcfPlayerAttackBackground:Hide();
	end
end

function JcfPlayerFrame_UpdateGroupIndicator()
	JcfPlayerFrameGroupIndicator:Hide();
	local name, rank, subgroup;
	if ( not IsInRaid() ) then
		JcfPlayerFrameGroupIndicator:Hide();
		return;
	end
	local numGroupMembers = GetNumGroupMembers();
	for i=1, MAX_RAID_MEMBERS do
		if ( i <= numGroupMembers ) then
			name, rank, subgroup = GetRaidRosterInfo(i);
			-- Set the player's group number indicator
			if ( name == UnitName("player") ) then
				JcfPlayerFrameGroupIndicatorText:SetText(GROUP.." "..subgroup);
				JcfPlayerFrameGroupIndicator:SetWidth(JcfPlayerFrameGroupIndicatorText:GetWidth()+40);
				JcfPlayerFrameGroupIndicator:Show();
			end
		end
	end
end

function JcfPlayerFrame_UpdatePlaytime()
	if ( PartialPlayTime() ) then
		JcfPlayerPlayTimeIcon:SetTexture("Interface\\CharacterFrame\\UI-Player-PlayTimeTired");
		JcfPlayerPlayTime.tooltip = format(PLAYTIME_TIRED, JCF_REQUIRED_REST_HOURS - floor(GetBillingTimeRested()/60));
		JcfPlayerPlayTime:Show();
	elseif ( NoPlayTime() ) then
		JcfPlayerPlayTimeIcon:SetTexture("Interface\\CharacterFrame\\UI-Player-PlayTimeUnhealthy");
		JcfPlayerPlayTime.tooltip = format(PLAYTIME_UNHEALTHY, JCF_REQUIRED_REST_HOURS - floor(GetBillingTimeRested()/60));
		JcfPlayerPlayTime:Show();
	else
		JcfPlayerPlayTime:Hide();
	end
end

function JcfPlayerFrame_SetupDeathKnightLayout ()
	JcfPlayerFrame:SetHitRectInsets(0,0,0,33);
end

function JcfPlayerFrameMultiGroupFrame_OnLoad(self)
	self:RegisterEvent("GROUP_ROSTER_UPDATE");
	self:RegisterEvent("UPDATE_CHAT_COLOR");
	self:RegisterForClicks("LeftButtonUp", "RightButtonUp");
end

function JcfPlayerFrameMultiGroupFrame_OnEvent(self, event, ...)
	if ( event == "GROUP_ROSTER_UPDATE" ) then
		if ( IsInGroup(LE_PARTY_CATEGORY_HOME) and IsInGroup(LE_PARTY_CATEGORY_INSTANCE) ) then
			self:Show();
		else
			self:Hide();
		end
	elseif ( event == "UPDATE_CHAT_COLOR" ) then
		local public = ChatTypeInfo["INSTANCE_CHAT"];
		local private = ChatTypeInfo["PARTY"];
		--self.HomePartyIcon:SetVertexColor(private.r, private.g, private.b);
		--self.InstancePartyIcon:SetVertexColor(public.r, public.g, public.b);
	end
end

function JcfPlayerFrameMultiGroupframe_OnEnter(self)
	GameTooltip_SetDefaultAnchor(GameTooltip, self);
	self.homePlayers = GetHomePartyInfo(self.homePlayers);

	if ( IsInRaid(LE_PARTY_CATEGORY_HOME) ) then
		GameTooltip:SetText(PLAYER_IN_MULTI_GROUP_RAID_MESSAGE, nil, nil, nil, nil, true);
		GameTooltip:AddLine(format(MEMBER_COUNT_IN_RAID_LIST, #self.homePlayers + 1), 1, 1, 1, true);
	else
		GameTooltip:AddLine(PLAYER_IN_MULTI_GROUP_PARTY_MESSAGE, 1, 1, 1, true);
		local playerList = self.homePlayers[1] or "";
		for i=2, #self.homePlayers do
			playerList = playerList..PLAYER_LIST_DELIMITER..self.homePlayers[i];
		end
		GameTooltip:AddLine(format(MEMBERS_IN_PARTY_LIST, playerList));
	end
	GameTooltip:Show();
end

JCF_CustomClassLayouts = {
	["DEATHKNIGHT"] = PlayerFrame_SetupDeathKnightLayout,
}

local layoutUpdated = false;

function JcfPlayerFrame_UpdateLayout ()
	if ( layoutUpdated ) then
		return;
	end
	layoutUpdated = true;

	local _, class = UnitClass("player");

	if ( JCF_CustomClassLayouts[class] ) then
		JCF_CustomClassLayouts[class]();
	end
end

local RUNICPOWERBARHEIGHT = 63;
local RUNICPOWERBARWIDTH = 64;

local RUNICGLOW_FADEALPHA = .050
local RUNICGLOW_MINALPHA = .40
local RUNICGLOW_MAXALPHA = .80
local RUNICGLOW_THROBINTERVAL = .8;

JCF_RUNICGLOW_FINISHTHROBANDHIDE = false;
local RUNICGLOW_THROBSTART = 0;

function JcfPlayerFrame_SetRunicPower (runicPower)
	JcfPlayerFrameRunicPowerBar:SetHeight(RUNICPOWERBARHEIGHT * (runicPower / 100));
	JcfPlayerFrameRunicPowerBar:SetTexCoord(0, 1, (1 - (runicPower / 100)), 1);

	if ( runicPower >= 90 ) then
		-- Oh,  God help us for these function and variable names.
		JCF_RUNICGLOW_FINISHTHROBANDHIDE = false;
		if ( not JcfPlayerFrameRunicPowerGlow:IsShown() ) then
			JcfPlayerFrameRunicPowerGlow:Show();
		end
		JcfPlayerFrameRunicPowerGlow:GetParent():SetScript("OnUpdate", JcfDeathKnniggetThrobFunction);
	elseif ( JcfPlayerFrameRunicPowerGlow:GetParent():GetScript("OnUpdate") ) then
		JCF_RUNICGLOW_FINISHTHROBANDHIDE = true;
	else
		JcfPlayerFrameRunicPowerGlow:Hide();
	end
end

local firstFadeIn = true;
function JcfDeathKnniggetThrobFunction (self, elapsed)
	if ( RUNICGLOW_THROBSTART == 0 ) then
		RUNICGLOW_THROBSTART = GetTime();
	elseif ( not JCF_RUNICGLOW_FINISHTHROBANDHIDE ) then
		local interval = RUNICGLOW_THROBINTERVAL - math.abs( .9 - (UnitPower("player") / 100));
		local animTime = GetTime() - RUNICGLOW_THROBSTART;
		if ( animTime >= interval ) then
			-- Fading out
			JcfPlayerFrameRunicPowerGlow:SetAlpha(math.max(RUNICGLOW_MINALPHA, math.min(RUNICGLOW_MAXALPHA, RUNICGLOW_MAXALPHA * interval/animTime)));
			if ( animTime >= interval * 2 ) then
				self.timeSinceThrob = 0;
				RUNICGLOW_THROBSTART = GetTime();
			end
			firstFadeIn = false;
		else
			-- Fading in
			if ( firstFadeIn ) then
				JcfPlayerFrameRunicPowerGlow:SetAlpha(math.max(RUNICGLOW_FADEALPHA, math.min(RUNICGLOW_MAXALPHA, RUNICGLOW_MAXALPHA * animTime/interval)));
			else
				JcfPlayerFrameRunicPowerGlow:SetAlpha(math.max(RUNICGLOW_MINALPHA, math.min(RUNICGLOW_MAXALPHA, RUNICGLOW_MAXALPHA * animTime/interval)));
			end
		end
	elseif ( JCF_RUNICGLOW_FINISHTHROBANDHIDE ) then
		local currentAlpha = JcfPlayerFrameRunicPowerGlow:GetAlpha();
		local animTime = GetTime() - RUNICGLOW_THROBSTART;
		local interval = RUNICGLOW_THROBINTERVAL;
		firstFadeIn = true;

		if ( animTime >= interval ) then
			-- Already fading out, just keep fading out.
			local alpha = math.min(JcfPlayerFrameRunicPowerGlow:GetAlpha(), RUNICGLOW_MAXALPHA * (interval/(animTime*(animTime/2))));

			JcfPlayerFrameRunicPowerGlow:SetAlpha(alpha);
			if ( alpha <= RUNICGLOW_FADEALPHA ) then
				self.timeSinceThrob = 0;
				RUNICGLOW_THROBSTART = 0;
				JcfPlayerFrameRunicPowerGlow:Hide();
				self:SetScript("OnUpdate", nil);
				JCF_RUNICGLOW_FINISHTHROBANDHIDE = false;
				return;
			end
		else
			-- Was fading in, start fading out
			animTime = interval;
		end
	end
end



function JcfPlayerFrame_ShowVehicleTexture()
	JcfPlayerFrameVehicleTexture:Show();

	local _, class = UnitClass("player");
	if ( JcfPlayerFrame.classPowerBar ) then
		JcfPlayerFrame.classPowerBar:Hide();
	elseif ( class == "SHAMAN" ) then
		JcfTotemFrame:Hide();
	elseif ( class == "DEATHKNIGHT" ) then
		JcfRuneFrame:Hide();
	elseif ( class == "PRIEST" and JcfPriestBarFrame) then
		JcfPriestBarFrame:Hide();
	end
end


function JcfPlayerFrame_HideVehicleTexture()
	JcfPlayerFrameVehicleTexture:Hide();

	local _, class = UnitClass("player");
	if ( JcfPlayerFrame.classPowerBar ) then
		JcfPlayerFrame.classPowerBar:Setup();
	elseif ( class == "SHAMAN" ) then
		JcfTotemFrame:Show();
	elseif ( class == "DEATHKNIGHT" ) then
		JcfRuneFrame:Show();
	elseif ( class == "PRIEST" and JcfPriestBarFrame) then
		JcfPriestBarFrame_CheckAndShow();
	end
end

function JcfPlayerFrame_OnDragStart(self)
	self:StartMoving();
	self:SetUserPlaced(true);
	self:SetClampedToScreen(true);
end

function JcfPlayerFrame_OnDragStop(self)
	self:StopMovingOrSizing();
end

function JcfPlayerFrame_SetLocked(locked)
	PLAYER_FRAME_UNLOCKED = not locked;
	if ( locked ) then
		JcfPlayerFrame:RegisterForDrag();	--Unregister all buttons.
	else
		JcfPlayerFrame:RegisterForDrag("LeftButton");
	end
end

function JcfPlayerFrame_ResetUserPlacedPosition()
	JcfPlayerFrame:ClearAllPoints();
	JcfPlayerFrame:SetUserPlaced(false);
	JcfPlayerFrame:SetClampedToScreen(false);
	JcfPlayerFrame_SetLocked(true);
	JcfUIParent_UpdateTopFramePositions();
end

--
-- Functions for having the cast bar underneath the player frame
--

function JcfPlayerFrame_AttachCastBar()
	local castBar = JcfCastingBarFrame;
	local petCastBar = PetCastingBarFrame;
	-- player
	castBar.ignoreFramePositionManager = true;
	castBar:SetAttribute("ignoreFramePositionManager", true);
	castBar:SetLook("UNITFRAME");
	castBar:ClearAllPoints();
	castBar:SetPoint("LEFT", JcfPlayerFrame, 78, 0);
	-- pet
	petCastBar:SetLook("UNITFRAME");
	petCastBar:SetWidth(150);
	petCastBar:SetHeight(10);
	petCastBar:ClearAllPoints();
	petCastBar:SetPoint("TOP", castBar, "TOP", 0, 0);

	JcfPlayerFrame_AdjustAttachments();
	-- UIParent_ManageFramePositions();
end

function JcfPlayerFrame_DetachCastBar()
	local castBar = JcfCastingBarFrame;
	local petCastBar = PetCastingBarFrame;
	-- player
	castBar.ignoreFramePositionManager = nil;
	castBar:SetAttribute("ignoreFramePositionManager", false);
	castBar:SetLook("CLASSIC");
	castBar:ClearAllPoints();
	-- pet
	petCastBar:SetLook("CLASSIC");
	petCastBar:SetWidth(195);
	petCastBar:SetHeight(13);
	petCastBar:ClearAllPoints();
	petCastBar:SetPoint("BOTTOM", castBar, "TOP", 0, 12);

	-- UIParent_ManageFramePositions();
end

function JcfPlayerFrame_AdjustAttachments()
	if ( not JCF_PLAYER_FRAME_CASTBARS_SHOWN ) then
		return;
	end
	if ( JcfPetFrame and JcfPetFrame:IsShown() ) then
		JcfCastingBarFrame:SetPoint("TOP", JcfPetFrame, "BOTTOM", 0, -4);
	elseif ( JcfTotemFrame and JcfTotemFrame:IsShown() ) then
		JcfCastingBarFrame:SetPoint("TOP", JcfTotemFrame, "BOTTOM", 0, 2);
	else
		local _, class = UnitClass("player");
		if ( class == "PALADIN" ) then
			JcfCastingBarFrame:SetPoint("TOP", JcfPlayerFrame, "BOTTOM", 0, -6);
		elseif ( class == "DRUID" ) then
            JcfCastingBarFrame:SetPoint("TOP", JcfPlayerFrame, "BOTTOM", 0, 10);
		elseif ( class == "PRIEST" and JcfPriestBarFrame and JcfPriestBarFrame:IsShown() ) then
			JcfCastingBarFrame:SetPoint("TOP", JcfPlayerFrame, "BOTTOM", 0, -2);
		elseif ( class == "DEATHKNIGHT" or class == "WARLOCK" ) then
			JcfCastingBarFrame:SetPoint("TOP", JcfPlayerFrame, "BOTTOM", 0, 4);
		elseif ( class == "MONK" ) then
			JcfCastingBarFrame:SetPoint("TOP", JcfPlayerFrame, "BOTTOM", 0, -1);
		else
			JcfCastingBarFrame:SetPoint("TOP", JcfPlayerFrame, "BOTTOM", 0, 10);
		end
	end
end

JcfPlayerFrameBottomManagedFramesContainerMixin = {};

function JcfPlayerFrameBottomManagedFramesContainerMixin:Layout()
	LayoutMixin.Layout(self);
	JcfPlayerFrame_AdjustAttachments();
end
