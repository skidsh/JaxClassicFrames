JCF_MAX_COMBO_POINTS = 5;
JCF_MAX_TARGET_DEBUFFS = 16;
JCF_MAX_TARGET_BUFFS = 32;
JCF_MAX_BOSS_FRAMES = 5;

-- aura positioning constants
local AURA_START_X = 5;
local AURA_START_Y = 32;
local AURA_OFFSET_Y = 1;
local LARGE_AURA_SIZE = 21;
local SMALL_AURA_SIZE = 17;
local AURA_ROW_WIDTH = 122;
local TOT_AURA_ROW_WIDTH = 101;
local NUM_TOT_AURA_ROWS = 2;	-- TODO: replace with TOT_AURA_ROW_HEIGHT functionality if this becomes a problem

-- focus frame scales
local LARGE_FOCUS_SCALE = 1;
local SMALL_FOCUS_SCALE = 0.75;
local SMALL_FOCUS_UPSCALE = 1.333;

local PLAYER_UNITS = {
	player = true,
	vehicle = true,
	pet = true,
};

function JcfTargetFrame_OnLoad(self, unit, menuFunc)
	self.HealthBar.LeftText = self.textureFrame.HealthBarTextLeft;
	self.HealthBar.RightText = self.textureFrame.HealthBarTextRight;
	self.PowerBar.LeftText = self.textureFrame.ManaBarTextLeft;
	self.PowerBar.RightText = self.textureFrame.ManaBarTextRight;

	self.statusCounter = 0;
	self.statusSign = -1;
	self.unitHPPercent = 1;

	local thisName = self:GetName();
	self.borderTexture = _G[thisName.."TextureFrameTexture"];
	self.highLevelTexture = _G[thisName.."TextureFrameHighLevelTexture"];
	self.pvpIcon = _G[thisName.."TextureFramePVPIcon"];
	self.prestigePortrait = _G[thisName.."TextureFramePrestigePortrait"];
	self.prestigeBadge = _G[thisName.."TextureFramePrestigeBadge"];
	self.leaderIcon = _G[thisName.."TextureFrameLeaderIcon"];
	self.raidTargetIcon = _G[thisName.."TextureFrameRaidTargetIcon"];
	self.questIcon = _G[thisName.."TextureFrameQuestIcon"];
	self.levelText = _G[thisName.."TextureFrameLevelText"];
	self.deadText = _G[thisName.."TextureFrameDeadText"];
	self.unconsciousText = _G[thisName.."TextureFrameUnconsciousText"];
	self.petBattleIcon = _G[thisName.."TextureFramePetBattleIcon"];
	self.TOT_AURA_ROW_WIDTH = TOT_AURA_ROW_WIDTH;
	-- set simple frame
	if ( not self.showLevel ) then
		self.highLevelTexture:Hide();
		self.levelText:Hide();
	end
	-- set threat frame
	local threatFrame;
	if ( self.showThreat ) then
		threatFrame = _G[thisName.."Flash"];
	end
	-- set portrait frame
	local portraitFrame;
	if ( self.showPortrait ) then
		portraitFrame = _G[thisName.."Portrait"];
	end
	local healthBar = self.HealthBar;
	local manaBar = self.PowerBar;

	JcfUnitFrame_Initialize(self, unit, self.textureFrame.Name, portraitFrame,
						self.HealthBar, self.textureFrame.HealthBarText,
						self.PowerBar, self.textureFrame.ManaBarText,
	                     threatFrame, "player", _G[thisName.."NumericalThreat"],
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

	JcfTargetFrame_Update(self);
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("UNIT_HEALTH");
	if ( self.showLevel ) then
		self:RegisterEvent("UNIT_LEVEL");
	end
	self:RegisterEvent("UNIT_FACTION");
	if ( self.showClassification ) then
		self:RegisterEvent("UNIT_CLASSIFICATION_CHANGED");
	end
	if ( self.showLeader ) then
		self:RegisterEvent("PLAYER_FLAGS_CHANGED");
	end
	self:RegisterEvent("GROUP_ROSTER_UPDATE");
	self:RegisterEvent("RAID_TARGET_UPDATE");
	self:RegisterUnitEvent("UNIT_AURA", unit);

	-- Clicks
	-- self:RegisterForClicks("AnyUp")
	-- self:SetAttribute("unit", unit)
	-- self:SetAttribute("*type2", "togglemenu")
	_G[thisName.."PortraitCooldown"]:SetSwipeTexture("Interface\\CHARACTERFRAME\\TempPortraitAlphaMaskSmall")
end

function JcfTargetFrame_Update (self)
	-- This check is here so the frame will hide when the target goes away
	-- even if some of the functions below are hooked by addons.
	if (not UnitExists(self.unit) and not ShowBossFrameWhenUninteractable(self.unit)) then
		self:Hide()
	else
		if (self.unit == "target") then
			if (JCFTargetSettings:GetClassColorHealthEnabled()) then
				local _, classKey = UnitClass("target")
				local r,g,b,_ = GetClassColor(classKey)
				self.HealthBar.lockColor = true
				self.HealthBar:SetStatusBarColor(r, g, b);				
			else
				self.HealthBar.lockColor = false
				self.HealthBar:SetStatusBarColor(0, 1, 0);
			end
		end
		if (self.unit == "focus") then
			if (JCFFocusSettings:GetClassColorHealthEnabled()) then
				local _, classKey = UnitClass("focus")
				local r,g,b,_ = GetClassColor(classKey)
				self.HealthBar.lockColor = true
				self.HealthBar:SetStatusBarColor(r, g, b);
			else
				self.HealthBar.lockColor = false
				self.HealthBar:SetStatusBarColor(0, 1, 0);
			end
		end

		self:Show()

		-- Moved here to avoid taint from functions below
		if ( self.totFrame ) then
			JcfTargetofTarget_Update(self.totFrame);
		end

		JcfUnitFrame_Update(self);
		if ( self.showLevel ) then
			JcfTargetFrame_CheckLevel(self);
		end
		JcfTargetFrame_CheckFaction(self);
		if ( self.showClassification ) then
			JcfTargetFrame_CheckClassification(self);
		end
		JcfTargetFrame_CheckDead(self);
		if ( self.showLeader ) then
			if ( UnitLeadsAnyGroup(self.unit) ) then
				self.leaderIcon:SetTexture("Interface\\GroupFrame\\UI-Group-LeaderIcon");
				self.leaderIcon:SetTexCoord(0, 1, 0, 1);
				self.leaderIcon:Show();
			else
				self.leaderIcon:Hide();
			end
		end
		JcfTargetFrame_UpdateAuras(self);
		if ( self.portrait ) then
			self.portrait:SetAlpha(1.0);
		end
		JcfTargetFrame_CheckBattlePet(self);
		if ( self.petBattleIcon ) then
			self.petBattleIcon:SetAlpha(1.0);
		end
	end
end

function JcfTargetFrame_OnEvent (self, event, ...)
	JcfUnitFrame_OnEvent(self, event, ...);

	local arg1 = ...;
	if ( event == "PLAYER_ENTERING_WORLD" ) then
		JcfTargetFrame_Update(self);
	elseif ( event == "PLAYER_TARGET_CHANGED" ) then
		-- Moved here to avoid taint from functions below
		JcfTargetFrame_Update(self);
		JcfTargetFrame_UpdateRaidTargetIcon(self);
		CloseDropDownMenus();

		if ( UnitExists(self.unit) and not C_PlayerInteractionManager.IsReplacingUnit()) then
			if ( UnitIsEnemy(self.unit, "player") ) then
				PlaySound(SOUNDKIT.IG_CREATURE_AGGRO_SELECT);
			elseif ( UnitIsFriend("player", self.unit) ) then
				PlaySound(SOUNDKIT.IG_CHARACTER_NPC_SELECT);
			else
				PlaySound(SOUNDKIT.IG_CREATURE_NEUTRAL_SELECT);
			end
		end
	elseif ( event == "UNIT_TARGETABLE_CHANGED" and arg1 == self.unit) then
		JcfTargetFrame_Update(self);
		JcfTargetFrame_UpdateRaidTargetIcon(self);
		CloseDropDownMenus();
		UIParent_ManageFramePositions();
	elseif ( event == "UNIT_HEALTH" ) then
		if ( arg1 == self.unit ) then
			JcfTargetFrame_CheckDead(self);
		end
	elseif ( event == "UNIT_LEVEL" ) then
		if ( arg1 == self.unit ) then
			JcfTargetFrame_CheckLevel(self);
		end
	elseif ( event == "UNIT_FACTION" ) then
		if ( arg1 == self.unit or arg1 == "player" ) then
			JcfTargetFrame_CheckFaction(self);
			JcfTargetFrame_UpdateAuras(self);
			if ( self.showLevel ) then
				JcfTargetFrame_CheckLevel(self);
			end
		end
	elseif ( event == "UNIT_CLASSIFICATION_CHANGED" ) then
		if ( arg1 == self.unit ) then
			JcfTargetFrame_CheckClassification(self);
		end
	elseif ( event == "UNIT_AURA" ) then
		if ( arg1 == self.unit ) then
			JcfTargetFrame_UpdateAuras(self);
		end
	elseif ( event == "PLAYER_FLAGS_CHANGED" ) then
		if ( arg1 == self.unit ) then
			if ( UnitLeadsAnyGroup(self.unit) ) then
				self.leaderIcon:Show();
			else
				self.leaderIcon:Hide();
			end
		end
	elseif ( event == "GROUP_ROSTER_UPDATE" ) then
		JcfTargetFrame_Update(self);
		if (self.unit == "focus") then
			-- If this is the focus frame, clear focus if the unit no longer exists
			if (not UnitExists(self.unit)) then
				ClearFocus();
			end
		else
			if ( self.totFrame ) then
				JcfTargetofTarget_Update(self.totFrame);
			end
			JcfTargetFrame_CheckFaction(self);
		end
	elseif ( event == "RAID_TARGET_UPDATE" ) then
		JcfTargetFrame_UpdateRaidTargetIcon(self);
	elseif ( event == "PLAYER_FOCUS_CHANGED" ) then
		if ( UnitExists(self.unit) ) then
			self:Show()
			JcfTargetFrame_Update(self);
			JcfTargetFrame_UpdateRaidTargetIcon(self);
		else
			self:Hide()
		end
		CloseDropDownMenus();
	end
end

function JcfTargetFrame_OnVariablesLoaded()
	JcfTargetFrame_SetLocked(not TARGET_FRAME_UNLOCKED);
	JcfTargetFrame_UpdateBuffsOnTop();

	JcfFocusFrame_SetSmallSize(not GetCVarBool("fullSizeJcfFocusFrame"));
	JcfFocusFrame_UpdateBuffsOnTop();
end

function JcfTargetFrame_OnHide (self)
	PlaySound(SOUNDKIT.INTERFACE_SOUND_LOST_TARGET_UNIT);
	CloseDropDownMenus();
end

function JcfTargetFrame_CheckLevel (self)
	local targetEffectiveLevel = UnitLevel(self.unit);

	if ( UnitIsCorpse(self.unit) ) then
		self.levelText:Hide();
		self.highLevelTexture:Show();
	elseif ( targetEffectiveLevel > 0 ) then
		-- Normal level target
		self.levelText:SetText(targetEffectiveLevel);
		-- Color level number
		if ( UnitCanAttack("player", self.unit) ) then
			local color = GetCreatureDifficultyColor(targetEffectiveLevel);
			self.levelText:SetVertexColor(color.r, color.g, color.b);
		else
			self.levelText:SetVertexColor(1.0, 0.82, 0.0);
		end

		if ( self.isBossFrame ) then
			BossJcfTargetFrame_UpdateLevelTextAnchor(self, targetEffectiveLevel);
		else
			JcfTargetFrame_UpdateLevelTextAnchor(self, targetEffectiveLevel);
		end

		self.levelText:Show();
		self.highLevelTexture:Hide();
	else
		-- Target is too high level to tell
		self.levelText:Hide();
		self.highLevelTexture:Show();
	end
end

--This is overwritten in LocalizationPost for different languages.
function JcfTargetFrame_UpdateLevelTextAnchor (self, targetLevel)
	if ( targetLevel >= 100 ) then
		self.levelText:SetPoint("CENTER", 62, -16);
	else
		self.levelText:SetPoint("CENTER", 62, -16);
	end
end

function JcfTargetFrame_CheckFaction (self)
	if (self.unit == "target" and JCFTargetSettings ~= nil and JCFTargetSettings:GetHideNameBackground()) then
		self.nameBackground:SetVertexColor(0, 0, 0, 0.5);
	elseif (self.unit == "focus" and JCFFocusSettings ~= nil and JCFFocusSettings:GetHideNameBackground()) then
		self.nameBackground:SetVertexColor(0, 0, 0, 0.5);
	elseif (not UnitPlayerControlled(self.unit) and UnitIsTapDenied(self.unit)) then
		self.nameBackground:SetVertexColor(0.5, 0.5, 0.5);
		if ( self.portrait ) then
			self.portrait:SetVertexColor(0.5, 0.5, 0.5);
		end
	else
		self.nameBackground:SetVertexColor(UnitSelectionColor(self.unit));
		if ( self.portrait ) then
			self.portrait:SetVertexColor(1.0, 1.0, 1.0);
		end
	end

	if ( self.showPVP ) then
		local factionGroup = UnitFactionGroup(self.unit);
		if ( UnitIsPVPFreeForAll(self.unit) ) then
				self.prestigePortrait:Hide();
				self.prestigeBadge:Hide();
				self.pvpIcon:SetTexture("Interface\\TargetingFrame\\UI-PVP-FFA");
				self.pvpIcon:Show();
		elseif ( factionGroup and factionGroup ~= "Neutral" and UnitIsPVP(self.unit) ) then
				self.prestigePortrait:Hide();
				self.prestigeBadge:Hide();
				self.pvpIcon:SetTexture("Interface\\TargetingFrame\\UI-PVP-"..factionGroup);
				self.pvpIcon:Show();
		else
			self.prestigePortrait:Hide();
			self.prestigeBadge:Hide();
			self.pvpIcon:Hide();
		end
	end
end

function JcfTargetFrame_CheckBattlePet(self)
	--[[if ( UnitIsWildBattlePet(self.unit) or UnitIsBattlePetCompanion(self.unit) ) then
		local petType = UnitBattlePetType(self.unit);
		self.petBattleIcon:SetTexture("Interface\\TargetingFrame\\PetBadge-"..PET_TYPE_SUFFIX[petType]);
		self.petBattleIcon:Show();
	else
		self.petBattleIcon:Hide();
	end]]
end


function JcfTargetFrame_CheckClassification (self, forceNormalTexture)
	local classification = UnitClassification(self.unit);
	self.nameBackground:Show();
	self.manabar.pauseUpdates = false;
	self.manabar:Show();
	JcfTextStatusBar_UpdateTextString(self.manabar);
	self.threatIndicator:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-Flash");

	if (self.overideTexture > 0 and UnitIsPlayer(self.unit) ) then
		if self.overideTexture == 1 then
			self.borderTexture:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-Rare.blp"); end
		if self.overideTexture == 3 then
			self.borderTexture:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-Rare-Elite.blp"); end
		if self.overideTexture == 2 then
			self.borderTexture:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-Elite.blp"); end
	else
		if ( forceNormalTexture ) then
			self.borderTexture:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame");
		elseif ( classification == "minus" ) then
			self.borderTexture:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-Minus");
			self.nameBackground:Hide();
			self.manabar.pauseUpdates = true;
			self.manabar:Hide();
			self.manabar.TextString:Hide();
			self.manabar.LeftText:Hide();
			self.manabar.RightText:Hide();
			forceNormalTexture = true;
		elseif ( classification == "worldboss" or classification == "elite" ) then
			self.borderTexture:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-Elite");
		elseif ( classification == "rareelite" ) then
			self.borderTexture:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-Rare-Elite");
		elseif ( classification == "rare" ) then
			self.borderTexture:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-Rare");
		else
			self.borderTexture:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame");
			forceNormalTexture = true;
		end
	end

	if ( forceNormalTexture ) then
		self.haveElite = nil;
		if ( classification == "minus" ) then
			self.Background:SetSize(119,12);
			self.Background:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", 7, 47);
		else
			self.Background:SetSize(119,25);
			self.Background:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", 7, 35);
		end
		if ( self.threatIndicator ) then
			if ( classification == "minus" ) then
				self.threatIndicator:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-Minus-Flash");
				self.threatIndicator:SetTexCoord(0, 1, 0, 1);
				self.threatIndicator:SetWidth(256);
				self.threatIndicator:SetHeight(128);
				self.threatIndicator:SetPoint("TOPLEFT", self, "TOPLEFT", -24, 0);
			else
				self.threatIndicator:SetTexCoord(0, 0.9453125, 0, 0.181640625);
				self.threatIndicator:SetWidth(242);
				self.threatIndicator:SetHeight(93);
				self.threatIndicator:SetPoint("TOPLEFT", self, "TOPLEFT", -24, 0);
			end
		end
	else
		self.haveElite = true;
		JcfTargetFrameBackground:SetSize(119,41);
		self.Background:SetSize(119,25);
		self.Background:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", 7, 35);
		if ( self.threatIndicator ) then
			self.threatIndicator:SetTexCoord(0, 0.9453125, 0.181640625, 0.400390625);
			self.threatIndicator:SetWidth(242);
			self.threatIndicator:SetHeight(112);
			self.threatIndicator:SetPoint("TOPLEFT", self, "TOPLEFT", -22, 9);
		end
	end

	--[[if (self.questIcon) then
		if (UnitIsQuestBoss(self.unit)) then
			self.questIcon:Show();
		else
			self.questIcon:Hide();
		end
	end]]
end

function JcfTargetFrame_CheckDead (self)
	if ( (UnitHealth(self.unit) <= 0) and UnitIsConnected(self.unit) ) then
		if ( UnitIsUnconscious(self.unit) ) then
			self.unconsciousText:Show();
			self.deadText:Hide();
		else
			self.unconsciousText:Hide();
			self.deadText:Show();
		end
	else
		self.deadText:Hide();
		self.unconsciousText:Hide();
	end
end

function JcfTargetFrame_OnUpdate (self, elapsed)
	if ( self.totFrame and self.totFrame:IsShown() ~= UnitExists(self.totFrame.unit) ) then
		JcfTargetofTarget_Update(self.totFrame);
	end

	self.elapsed = (self.elapsed or 0) + elapsed;
	if ( self.elapsed > 0.5 ) then
		self.elapsed = 0;
		JcfUnitFrame_UpdateThreatIndicator(self.threatIndicator, self.threatNumericIndicator, self.feedbackUnit);
	end
end

local largeBuffList = {};
local largeDebuffList = {};
local function ShouldAuraBeLarge(caster)
	if not caster then
		return false;
	end

	for token, value in pairs(PLAYER_UNITS) do
		if UnitIsUnit(caster, token) or UnitIsOwnerOrControllerOfUnit(token, caster) then
			return value;
		end
	end
end

function JcfTargetFrame_UpdateAuras (self)
	local frame, frameName;
	local frameIcon, frameCount, frameCooldown;
	local numBuffs = 0;
	local playerIsTarget = UnitIsUnit(PlayerFrame.unit, self.unit);
	local selfName = self:GetName();
	local canAssist = UnitCanAssist("player", self.unit);
	local i = 0;
	AuraUtil.ForEachAura(self.unit, "HELPFUL", JCF_MAX_TARGET_BUFFS, function(...)
        local buffName, icon, count, debuffType, duration, expirationTime, caster, canStealOrPurge, _ , spellId, _, _, casterIsPlayer, nameplateShowAll = ...;
		i = i + 1;
        if (buffName) then
            frameName = selfName.."Buff"..(i);
            frame = _G[frameName];
            if ( not frame ) then
                if ( not icon ) then
                    return;
                else
                    frame = CreateFrame("Button", frameName, self, "JcfTargetBuffFrameTemplate");
                    frame.unit = self.unit;
                end
            end
            if ( icon and ( not self.maxBuffs or i <= self.maxBuffs ) ) then
                frame:SetID(i);

                -- set the icon
                frameIcon = _G[frameName.."Icon"];
                frameIcon:SetTexture(icon);

                -- set the count
                frameCount = _G[frameName.."Count"];
                if ( count > 1 and self.showAuraCount ) then
                    frameCount:SetText(count);
                    frameCount:Show();
                else
                    frameCount:Hide();
                end

                -- Handle cooldowns
                frameCooldown = _G[frameName.."Cooldown"];
                CooldownFrame_Set(frameCooldown, expirationTime - duration, duration, duration > 0, true);

                -- Show stealable frame if the target is not the current player and the buff is stealable.
                local frameStealable = _G[frameName.."Stealable"];
                if ( not playerIsTarget and canStealOrPurge ) then
                    frameStealable:Show();
                else
                    frameStealable:Hide();
                end

                -- set the buff to be big if the buff is cast by the player or his pet
				numBuffs = numBuffs + 1;
                largeBuffList[numBuffs] = ShouldAuraBeLarge(caster);

                frame:ClearAllPoints();
                frame:Show();
            else
                frame:Hide();
            end
        else
            return;
        end
	end)

	for i = numBuffs + 1, JCF_MAX_TARGET_BUFFS do
		local frame = _G[selfName.."Buff"..i];
		if ( frame ) then
			frame:Hide();
		else
			break;
		end
	end

	local color;
	local frameBorder;
	local numDebuffs = 0;

	local frameNum = 1;
	local index = 1;

	local maxDebuffs = self.maxDebuffs or JCF_MAX_TARGET_DEBUFFS;
	AuraUtil.ForEachAura(self.unit, "HARMFUL|INCLUDE_NAME_PLATE_ONLY", maxDebuffs, function(...)

	    local debuffName, icon, count, debuffType, duration, expirationTime, caster, _, _, _, _, _, casterIsPlayer, nameplateShowAll = ...;
		if ( debuffName ) then
			if ( JcfTargetFrame_ShouldShowDebuffs(self.unit, caster, nameplateShowAll, casterIsPlayer) ) then
				frameName = selfName.."Debuff"..frameNum;
				frame = _G[frameName];
				if ( icon ) then
					if ( not frame ) then
						frame = CreateFrame("Button", frameName, self, "JcfTargetDebuffFrameTemplate");
						frame.unit = self.unit;
					end
					frame:SetID(index);

					-- set the icon
					frameIcon = _G[frameName.."Icon"];
					frameIcon:SetTexture(icon);

					-- set the count
					frameCount = _G[frameName.."Count"];
					if ( count > 1 and self.showAuraCount ) then
						frameCount:SetText(count);
						frameCount:Show();
					else
						frameCount:Hide();
					end

					-- Handle cooldowns
					frameCooldown = _G[frameName.."Cooldown"];
					CooldownFrame_Set(frameCooldown, expirationTime - duration, duration, duration > 0, true);

					-- set debuff type color
					if ( debuffType ) then
						color = DebuffTypeColor[debuffType];
					else
						color = DebuffTypeColor["none"];
					end
					frameBorder = _G[frameName.."Border"];
					frameBorder:SetVertexColor(color.r, color.g, color.b);

					-- set the debuff to be big if the buff is cast by the player or his pet
					numDebuffs = numDebuffs + 1;
					largeDebuffList[numDebuffs] = ShouldAuraBeLarge(caster);

					frame:ClearAllPoints();
					frame:Show();

					frameNum = frameNum + 1;
				end
			end
		else
			return;
		end
		index = index + 1;
	end)

	for i = frameNum, JCF_MAX_TARGET_DEBUFFS do
		local frame = _G[selfName.."Debuff"..i];
		if ( frame ) then
			frame:Hide();
		else
			break;
		end
	end

	self.auraRows = 0;

	local mirrorAurasVertically = false;
	if ( self.buffsOnTop ) then
		mirrorAurasVertically = true;
	end
	local haveJcfTargetofTarget;
	if ( self.totFrame ) then
		haveJcfTargetofTarget = self.totFrame:IsShown();
	end
	self.spellbarAnchor = nil;
	local maxRowWidth;
	-- update buff positions
	maxRowWidth = ( haveJcfTargetofTarget and self.TOT_AURA_ROW_WIDTH ) or AURA_ROW_WIDTH;
	JcfTargetFrame_UpdateAuraPositions(self, selfName.."Buff", numBuffs, numDebuffs, largeBuffList, JcfTargetFrame_UpdateBuffAnchor, maxRowWidth, 3, mirrorAurasVertically);
	-- update debuff positions
	maxRowWidth = ( haveJcfTargetofTarget and self.auraRows < NUM_TOT_AURA_ROWS and self.TOT_AURA_ROW_WIDTH ) or AURA_ROW_WIDTH;
	JcfTargetFrame_UpdateAuraPositions(self, selfName.."Debuff", numDebuffs, numBuffs, largeDebuffList, JcfTargetFrame_UpdateDebuffAnchor, maxRowWidth, 3, mirrorAurasVertically);
	-- update the spell bar position
	if ( self.spellbar ) then
		JcfTarget_Spellbar_AdjustPosition(self.spellbar);
	end
end

--
--		Hide debuffs on mobs cast by players other than me and aren't flagged to show to entire party on nameplates.
--
function JcfTargetFrame_ShouldShowDebuffs(unit, caster, nameplateShowAll, casterIsAPlayer)
	if (GetCVarBool("noBuffDebuffFilterOnTarget")) then
		return true;
	end

	if (nameplateShowAll) then
		return true;
	end

	if (caster and (UnitIsUnit("player", caster) or UnitIsOwnerOrControllerOfUnit("player", caster))) then
		return true;
	end

	if (UnitIsUnit("player", unit)) then
		return true;
	end

	local targetIsFriendly = not UnitCanAttack("player", unit);
	local targetIsAPlayer =  UnitIsPlayer(unit);
	local targetIsAPlayerPet = UnitIsOtherPlayersPet(unit);

	if (not targetIsAPlayer and not targetIsAPlayerPet and not targetIsFriendly and casterIsAPlayer) then
        return false;
    end

    return true;
end

function JcfTargetFrame_UpdateAuraPositions(self, auraName, numAuras, numOppositeAuras, largeAuraList, updateFunc, maxRowWidth, offsetX, mirrorAurasVertically)
	-- a lot of this complexity is in place to allow the auras to wrap around the target of target frame if it's shown

	-- Position auras
	local size;
	local offsetY = AURA_OFFSET_Y;
	-- current width of a row, increases as auras are added and resets when a new aura's width exceeds the max row width
	local rowWidth = 0;
	local firstBuffOnRow = 1;
	for i=1, numAuras do
		-- update size and offset info based on large aura status
		if ( largeAuraList[i] ) then
			size = LARGE_AURA_SIZE;
			offsetY = AURA_OFFSET_Y + AURA_OFFSET_Y;
		else
			size = SMALL_AURA_SIZE;
		end

		-- anchor the current aura
		if ( i == 1 ) then
			rowWidth = size;
			self.auraRows = self.auraRows + 1;
		else
			rowWidth = rowWidth + size + offsetX;
		end
		if ( rowWidth > maxRowWidth ) then
			-- this aura would cause the current row to exceed the max row width, so make this aura
			-- the start of a new row instead
			updateFunc(self, auraName, i, numOppositeAuras, firstBuffOnRow, size, offsetX, offsetY, mirrorAurasVertically);

			rowWidth = size;
			self.auraRows = self.auraRows + 1;
			firstBuffOnRow = i;
			offsetY = AURA_OFFSET_Y;

			if ( self.auraRows > NUM_TOT_AURA_ROWS ) then
				-- if we exceed the number of tot rows, then reset the max row width
				-- note: don't have to check if we have tot because AURA_ROW_WIDTH is the default anyway
				maxRowWidth = AURA_ROW_WIDTH;
			end
		else
			updateFunc(self, auraName, i, numOppositeAuras, i - 1, size, offsetX, offsetY, mirrorAurasVertically);
		end
	end
end

function JcfTargetFrame_UpdateBuffAnchor(self, buffName, index, numDebuffs, anchorIndex, size, offsetX, offsetY, mirrorVertically)
	--For mirroring vertically
	local point, relativePoint;
	local startY, auraOffsetY;
	if ( mirrorVertically ) then
		point = "BOTTOM";
		relativePoint = "TOP";
		startY = -15;
		if ( self.threatNumericIndicator:IsShown() ) then
			startY = startY + self.threatNumericIndicator:GetHeight();
		end
		offsetY = - offsetY;
		auraOffsetY = -AURA_OFFSET_Y;
	else
		point = "TOP";
		relativePoint="BOTTOM";
		startY = AURA_START_Y;
		auraOffsetY = AURA_OFFSET_Y;
	end

	local buff = _G[buffName..index];
	if ( index == 1 ) then
		if ( UnitIsFriend("player", self.unit) or numDebuffs == 0 ) then
			-- unit is friendly or there are no debuffs...buffs start on top
			buff:SetPoint(point.."LEFT", self, relativePoint.."LEFT", AURA_START_X, startY);
		else
			-- unit is not friendly and we have debuffs...buffs start on bottom
			buff:SetPoint(point.."LEFT", self.debuffs, relativePoint.."LEFT", 0, -offsetY);
		end
		self.buffs:SetPoint(point.."LEFT", buff, point.."LEFT", 0, 0);
		self.buffs:SetPoint(relativePoint.."LEFT", buff, relativePoint.."LEFT", 0, -auraOffsetY);
		self.spellbarAnchor = buff;
	elseif ( anchorIndex ~= (index-1) ) then
		-- anchor index is not the previous index...must be a new row
		buff:SetPoint(point.."LEFT", _G[buffName..anchorIndex], relativePoint.."LEFT", 0, -offsetY);
		self.buffs:SetPoint(relativePoint.."LEFT", buff, relativePoint.."LEFT", 0, -auraOffsetY);
		self.spellbarAnchor = buff;
	else
		-- anchor index is the previous index
		buff:SetPoint(point.."LEFT", _G[buffName..anchorIndex], point.."RIGHT", offsetX, 0);
	end

	-- Resize
	buff:SetWidth(size);
	buff:SetHeight(size);
end

function JcfTargetFrame_UpdateDebuffAnchor(self, debuffName, index, numBuffs, anchorIndex, size, offsetX, offsetY, mirrorVertically)
	local buff = _G[debuffName..index];
	local isFriend = UnitIsFriend("player", self.unit);

	--For mirroring vertically
	local point, relativePoint;
	local startY, auraOffsetY;
	if ( mirrorVertically ) then
		point = "BOTTOM";
		relativePoint = "TOP";
		startY = -15;
		if ( self.threatNumericIndicator:IsShown() ) then
			startY = startY + self.threatNumericIndicator:GetHeight();
		end
		offsetY = - offsetY;
		auraOffsetY = -AURA_OFFSET_Y;
	else
		point = "TOP";
		relativePoint="BOTTOM";
		startY = AURA_START_Y;
		auraOffsetY = AURA_OFFSET_Y;
	end

	if ( index == 1 ) then
		if ( isFriend and numBuffs > 0 ) then
			-- unit is friendly and there are buffs...debuffs start on bottom
			buff:SetPoint(point.."LEFT", self.buffs, relativePoint.."LEFT", 0, -offsetY);
		else
			-- unit is not friendly or there are no buffs...debuffs start on top
			buff:SetPoint(point.."LEFT", self, relativePoint.."LEFT", AURA_START_X, startY);
		end
		self.debuffs:SetPoint(point.."LEFT", buff, point.."LEFT", 0, 0);
		self.debuffs:SetPoint(relativePoint.."LEFT", buff, relativePoint.."LEFT", 0, -auraOffsetY);
		if ( ( isFriend ) or ( not isFriend and numBuffs == 0) ) then
			self.spellbarAnchor = buff;
		end
	elseif ( anchorIndex ~= (index-1) ) then
		-- anchor index is not the previous index...must be a new row
		buff:SetPoint(point.."LEFT", _G[debuffName..anchorIndex], relativePoint.."LEFT", 0, -offsetY);
		self.debuffs:SetPoint(relativePoint.."LEFT", buff, relativePoint.."LEFT", 0, -auraOffsetY);
		if ( ( isFriend ) or ( not isFriend and numBuffs == 0) ) then
			self.spellbarAnchor = buff;
		end
	else
		-- anchor index is the previous index
		buff:SetPoint(point.."LEFT", _G[debuffName..(index-1)], point.."RIGHT", offsetX, 0);
	end

	-- Resize
	buff:SetWidth(size);
	buff:SetHeight(size);
	local debuffFrame =_G[debuffName..index.."Border"];
	debuffFrame:SetWidth(size+2);
	debuffFrame:SetHeight(size+2);
end

function JcfTargetFrame_HealthUpdate (self, elapsed, unit)

end

function JcfTargetHealthCheck (self)

end

function JcfTargetFrameDropDown_Initialize (self)
end

-- Raid target icon function
RAID_TARGET_ICON_DIMENSION = 64;
RAID_TARGET_TEXTURE_DIMENSION = 256;
RAID_TARGET_TEXTURE_COLUMNS = 4;
RAID_TARGET_TEXTURE_ROWS = 4;
function JcfTargetFrame_UpdateRaidTargetIcon (self)
	local index = GetRaidTargetIndex(self.unit);
	if ( index ) then
		JcfSetRaidTargetIconTexture(self.raidTargetIcon, index);
		self.raidTargetIcon:Show();
	else
		self.raidTargetIcon:Hide();
	end
end

function JcfSetRaidTargetIconTexture (texture, raidTargetIconIndex)
	raidTargetIconIndex = raidTargetIconIndex - 1;
	local left, right, top, bottom;
	local coordIncrement = RAID_TARGET_ICON_DIMENSION / RAID_TARGET_TEXTURE_DIMENSION;
	left = mod(raidTargetIconIndex , RAID_TARGET_TEXTURE_COLUMNS) * coordIncrement;
	right = left + coordIncrement;
	top = floor(raidTargetIconIndex / RAID_TARGET_TEXTURE_ROWS) * coordIncrement;
	bottom = top + coordIncrement;
	texture:SetTexCoord(left, right, top, bottom);
end

function JcfSetRaidTargetIcon (unit, index)
	if ( GetRaidTargetIndex(unit) and GetRaidTargetIndex(unit) == index ) then
		SetRaidTarget(unit, 0);
	else
		SetRaidTarget(unit, index);
	end
end

function JcfTargetFrame_CreateJcfTargetofTarget(self, unit)
	local thisName = self:GetName().."ToT";
	local frame = CreateFrame("BUTTON", thisName, self, "JcfTargetofTargetFrameTemplate");
	self.totFrame = frame;
	JcfUnitFrame_Initialize(frame, unit, _G[thisName.."TextureFrameName"], _G[thisName.."Portrait"],
						 _G[thisName.."HealthBar"], _G[thisName.."TextureFrameHealthBarText"],
						 _G[thisName.."ManaBar"], _G[thisName.."TextureFrameManaBarText"]);
	SetJcfTextStatusBarTextZeroText(frame.healthbar, DEAD);
	frame.deadText = _G[thisName.."TextureFrameDeadText"];
	frame.unconsciousText = _G[thisName.."TextureFrameUnconsciousText"];
	SecureUnitButton_OnLoad(frame, unit);
end

function JcfTargetofTarget_OnHide(self)
	JcfTargetFrame_UpdateAuras(self:GetParent());
end

function JcfTargetofTarget_Update(self, elapsed)
	local show;
	local parent = self:GetParent();
	if ( GetCVar("showTargetOfTarget") == "1" and UnitExists(parent.unit) and UnitExists(self.unit) and ( not UnitIsUnit(PlayerFrame.unit, parent.unit) ) and ( UnitHealth(parent.unit) > 0 ) ) then
		if ( not self:IsShown() ) then
			self:Show();
			if ( parent.spellbar ) then
				parent.haveToT = true;
				JcfTarget_Spellbar_AdjustPosition(parent.spellbar);
			end
		end
		JcfUnitFrame_Update(self);
		JcfTargetofTarget_CheckDead(self);
		JcfTargetofTargetHealthCheck(self);
		RefreshDebuffs(self, self.unit, nil, nil, true);
	else
		if ( self:IsShown() ) then
			self:Hide();
			if ( parent.spellbar ) then
				parent.haveToT = nil;
				JcfTarget_Spellbar_AdjustPosition(parent.spellbar);
			end
		end
	end
	if ((parent.unit == "target" and JCFTargetSettings:GetTotClassColor()) or
		(parent.unit == "focus" and JCFFocusSettings:GetTotClassColor())) then
		if (self) then
			local _, classKey = UnitClass(self.unit)
			local r,g,b,_ = GetClassColor(classKey)
			_G[self:GetName().."HealthBar"].lockColor = true
			_G[self:GetName().."HealthBar"]:SetStatusBarColor(r, g, b)
		end
	else
		if (self) then
			_G[self:GetName().."HealthBar"].lockColor = false
			_G[self:GetName().."HealthBar"]:SetStatusBarColor(0, 1, 0)
		end
	end
	if (parent.unit == "target" and JCFTargetSettings:GetTotReanchor()) then
		local xOff = JCFTargetSettings:GetTotXOffset();
		local yOff = JCFTargetSettings:GetTotYOffset();
		self:ClearAllPoints()
		self:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -35 + xOff, -10 + yOff)
	elseif (parent.unit == "focus" and JCFFocusSettings:GetTotReanchor()) then
		local xOff = JCFFocusSettings:GetTotXOffset();
		local yOff = JCFFocusSettings:GetTotYOffset();
		self:ClearAllPoints()
		self:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -35 + xOff, -10 + yOff)
	else
		self:ClearAllPoints()
		self:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -35, -10)
	end
end

function JcfTargetofTarget_CheckDead(self)
	if ( (UnitHealth(self.unit) <= 0) and UnitIsConnected(self.unit) ) then
		self.background:SetAlpha(0.9);
		if ( UnitIsUnconscious(self.unit) ) then
			self.unconsciousText:Show();
			self.deadText:Hide();
		else
			self.unconsciousText:Hide();
			self.deadText:Show();
		end
	else
		self.background:SetAlpha(1);
		self.deadText:Hide();
		self.unconsciousText:Hide();
	end
end

function JcfTargetofTargetHealthCheck(self)
	if ( UnitIsPlayer(self.unit) ) then
		local unitHPMin, unitHPMax, unitCurrHP;
		unitHPMin, unitHPMax = self.healthbar:GetMinMaxValues();
		unitCurrHP = self.healthbar:GetValue();
		self.unitHPPercent = unitCurrHP / unitHPMax;
		if ( UnitIsDead(self.unit) ) then
			self.portrait:SetVertexColor(0.35, 0.35, 0.35, 1.0);
		elseif ( UnitIsGhost(self.unit) ) then
			self.portrait:SetVertexColor(0.2, 0.2, 0.75, 1.0);
		elseif ( (self.unitHPPercent > 0) and (self.unitHPPercent <= 0.2) ) then
			self.portrait:SetVertexColor(1.0, 0.0, 0.0);
		else
			self.portrait:SetVertexColor(1.0, 1.0, 1.0, 1.0);
		end
	else
		self.portrait:SetVertexColor(1.0, 1.0, 1.0, 1.0);
	end
end

function JcfTargetFrame_CreateSpellbar(self, event, boss)
	local name = self:GetName().."SpellBar";
	local spellbar;
	if ( boss ) then
		spellbar = CreateFrame("STATUSBAR", name, self, "JcfBossSpellBarTemplate");
	else
		spellbar = CreateFrame("STATUSBAR", name, self, "JcfTargetSpellBarTemplate");
	end
	spellbar.boss = boss;
	spellbar:SetFrameLevel(_G[self:GetName().."TextureFrame"]:GetFrameLevel() - 1);
	self.spellbar = spellbar;
	self.auraRows = 0;
	spellbar:RegisterEvent("CVAR_UPDATE");
	spellbar:RegisterEvent("VARIABLES_LOADED");

	JcfCastingBarFrame_SetUnit(spellbar, self.unit, false, true);
	if ( event ) then
		spellbar.updateEvent = event;
		spellbar:RegisterEvent(event);
	end

	-- check to see if the castbar should be shown
	if ( GetCVar("showTargetCastbar") == "0") then
		spellbar.showCastbar = false;
	end
end

function JcfTarget_Spellbar_OnEvent(self, event, ...)
	local arg1 = ...

	--	Check for target specific events
	if ( (event == "VARIABLES_LOADED") or ((event == "CVAR_UPDATE") and (arg1 == "SHOW_TARGET_CASTBAR")) ) then
		if ( GetCVar("showTargetCastbar") == "0") then
			self.showCastbar = false;
		else
			self.showCastbar = true;
		end

		if ( not self.showCastbar ) then
			self:Hide();
		elseif ( self.casting or self.channeling ) then
			self:Show();
		end
		return;
	elseif ( event == self.updateEvent ) then
		-- check if the new target is casting a spell
		local nameChannel  = UnitChannelInfo(self.unit);
		local nameSpell  = UnitCastingInfo(self.unit);
		if ( nameChannel ) then
			event = "UNIT_SPELLCAST_CHANNEL_START";
			arg1 = self.unit;
		elseif ( nameSpell ) then
			event = "UNIT_SPELLCAST_START";
			arg1 = self.unit;
		else
			self.casting = nil;
			self.channeling = nil;
			self:SetMinMaxValues(0, 0);
			self:SetValue(0);
			self:Hide();
			return;
		end
		-- The position depends on the classification of the target
		JcfTarget_Spellbar_AdjustPosition(self);
	end
	JcfCastingBarFrame_OnEvent(self, event, arg1, select(2, ...));
end

function JcfTarget_Spellbar_AdjustPosition(self)
	local parentFrame = self:GetParent();
	if (self.unit == "target" and JCFTargetSettings ~= nil) then
		self:SetScale(JCFTargetSettings:GetCastBarScale())
	end
	if (self.unit == "focus" and JCFFocusSettings ~= nil) then
		self:SetScale(JCFFocusSettings:GetCastBarScale())
	end
	if (self.unit == "target" and JCFTargetSettings ~= nil and JCFTargetSettings:GetCastBarReanchor()) then
		local xOff = JCFTargetSettings:GetCastBarXOffset();
		local yOff = JCFTargetSettings:GetCastBarYOffset();
		self:SetPoint("TOPLEFT", parentFrame, "BOTTOMLEFT", 25 + xOff, 7 + yOff);
	elseif (self.unit == "focus" and JCFFocusSettings ~= nil and JCFFocusSettings:GetCastBarReanchor()) then
		local xOff = JCFFocusSettings:GetCastBarXOffset();
		local yOff = JCFFocusSettings:GetCastBarYOffset();
		self:SetPoint("TOPLEFT", parentFrame, "BOTTOMLEFT", 25 + xOff, 7 + yOff);
	else
		if ( self.boss ) then
			self:SetPoint("TOPLEFT", parentFrame, "BOTTOMLEFT", 25, 10 );
		elseif ( parentFrame.haveToT ) then
			if ( parentFrame.buffsOnTop or parentFrame.auraRows <= 1 ) then
				self:SetPoint("TOPLEFT", parentFrame, "BOTTOMLEFT", 25, -21 );
			else
				self:SetPoint("TOPLEFT", parentFrame.spellbarAnchor, "BOTTOMLEFT", 20, -15);
			end
		elseif ( parentFrame.haveElite ) then
			if ( parentFrame.buffsOnTop or parentFrame.auraRows <= 1 ) then
				self:SetPoint("TOPLEFT", parentFrame, "BOTTOMLEFT", 25, -5 );
			else
				self:SetPoint("TOPLEFT", parentFrame.spellbarAnchor, "BOTTOMLEFT", 20, -15);
			end
		else
			if ( (not parentFrame.buffsOnTop) and parentFrame.auraRows > 0 ) then
				self:SetPoint("TOPLEFT", parentFrame.spellbarAnchor, "BOTTOMLEFT", 20, -15);
			else
				self:SetPoint("TOPLEFT", parentFrame, "BOTTOMLEFT", 25, 7 );
			end
		end
	end
end

function JcfTargetFrame_OnDragStart(self)
	self:StartMoving();
	self:SetUserPlaced(true);
	self:SetClampedToScreen(true);
end

function JcfTargetFrame_OnDragStop(self)
	self:StopMovingOrSizing();
end

function JcfTargetFrame_SetLocked(locked)
	TARGET_FRAME_UNLOCKED = not locked;
	if ( locked ) then
		JcfTargetFrame:RegisterForDrag();	--Unregister all buttons.
	else
		JcfTargetFrame:RegisterForDrag("LeftButton");
	end
end

function JcfTargetFrame_ResetUserPlacedPosition()
	JcfTargetFrame:ClearAllPoints();
	JcfTargetFrame:SetUserPlaced(false);
	JcfTargetFrame:SetClampedToScreen(false);
	JcfTargetFrame_SetLocked(true);
	JcfUIParent_UpdateTopFramePositions();
end

function JcfTargetFrame_UpdateBuffsOnTop()
	if ( TARGET_FRAME_BUFFS_ON_TOP ) then
		JcfTargetFrame.buffsOnTop = true;
	else
		JcfTargetFrame.buffsOnTop = false;
	end
	JcfTargetFrame_UpdateAuras(JcfTargetFrame);
end

-- *********************************************************************************
-- Focus Frame
-- *********************************************************************************
JCF_FOCUS_FRAME_LOCKED = true;
function JcfFocusFrame_IsLocked()
	return JCF_FOCUS_FRAME_LOCKED;
end

function JcfFocusFrame_SetLock(locked)
	JCF_FOCUS_FRAME_LOCKED = locked;
end

function JcfFocusFrame_OnDragStart(self, button)
	FOCUS_FRAME_MOVING = false;
	if ( not JCF_FOCUS_FRAME_LOCKED ) then
		local cursorX, cursorY = GetCursorPosition();
		self:SetFrameStrata("DIALOG");
		self:StartMoving();
		FOCUS_FRAME_MOVING = true;
	end
end

function JcfFocusFrame_OnDragStop(self)
	if ( not JCF_FOCUS_FRAME_LOCKED and FOCUS_FRAME_MOVING ) then
		self:StopMovingOrSizing();
		self:SetFrameStrata("BACKGROUND");
		if ( self:GetBottom() < 15 + MainMenuBar:GetHeight() ) then
			local anchorX = self:GetLeft();
			local anchorY = 60;
			if ( self.smallSize ) then
				anchorY = 90;	-- empirically determined
			end
			self:SetPoint("BOTTOMLEFT", anchorX, anchorY);
		end
		FOCUS_FRAME_MOVING = false;
	end
end

function JcfFocusFrame_SetSmallSize(smallSize, onChange)
	if ( smallSize and not JcfFocusFrame.smallSize ) then
		local x = JcfFocusFrame:GetLeft();
		local y = JcfFocusFrame:GetTop();
		JcfFocusFrame.smallSize = true;
		JcfFocusFrame.maxBuffs = 0;
		JcfFocusFrame.maxDebuffs = 8;
		JcfFocusFrame:SetScale(SMALL_FOCUS_SCALE);
		JcfFocusFrameToT:SetScale(SMALL_FOCUS_UPSCALE);
		JcfFocusFrameToT:SetPoint("BOTTOMRIGHT", -13, -17);
		JcfFocusFrame.TOT_AURA_ROW_WIDTH = 80;	-- not as much room for auras with scaled-up ToT frame
		JcfFocusFrame.spellbar:SetScale(SMALL_FOCUS_UPSCALE);
		JcfFocusFrameTextureFrameName:SetFontObject(FocusFontSmall);
		JcfFocusFrameHealthBar.TextString:SetFontObject(JcfTextStatusBarTextLarge);
		JcfFocusFrameHealthBar.TextString:SetPoint("CENTER", -50, 4);
		JcfFocusFrameTextureFrameName:SetWidth(120);
		if ( onChange ) then
			-- the frame needs to be repositioned because anchor offsets get adjusted with scale
			JcfFocusFrame:ClearAllPoints();
			JcfFocusFrame:SetPoint("TOPLEFT", x * SMALL_FOCUS_UPSCALE + 29, (y - GetScreenHeight()) * SMALL_FOCUS_UPSCALE - 13);
		end
		JcfFocusFrame:UnregisterEvent("UNIT_CLASSIFICATION_CHANGED");
		JcfFocusFrame.showClassification = true;
		JcfFocusFrame:UnregisterEvent("PLAYER_FLAGS_CHANGED");
		JcfFocusFrame.showLeader = nil;
		JcfFocusFrame.showPVP = nil;
		JcfFocusFrame.pvpIcon:Hide();
		JcfFocusFrame.prestigePortrait:Hide();
		JcfFocusFrame.prestigeBadge:Hide();
		JcfFocusFrame.leaderIcon:Hide();
		JcfFocusFrame.showAuraCount = nil;
--		JcfTargetFrame_CheckClassification(JcfFocusFrame, true);
		JcfTargetFrame_Update(JcfFocusFrame);
	elseif ( not smallSize and JcfFocusFrame.smallSize ) then
		local x = JcfFocusFrame:GetLeft();
		local y = JcfFocusFrame:GetTop();
		JcfFocusFrame.smallSize = false;
		JcfFocusFrame.maxBuffs = nil;
		JcfFocusFrame.maxDebuffs = nil;
		JcfFocusFrame:SetScale(LARGE_FOCUS_SCALE);
		JcfFocusFrameToT:SetScale(LARGE_FOCUS_SCALE);
		JcfFocusFrameToT:SetPoint("BOTTOMRIGHT", -35, -10);
		JcfFocusFrame.TOT_AURA_ROW_WIDTH = TOT_AURA_ROW_WIDTH;
		JcfFocusFrame.spellbar:SetScale(LARGE_FOCUS_SCALE);
		JcfFocusFrameTextureFrameName:SetFontObject(GameFontNormalSmall);
		JcfFocusFrameHealthBar.TextString:SetFontObject(JcfTextStatusBarText);
		JcfFocusFrameHealthBar.TextString:SetPoint("CENTER", -50, 3);
		JcfFocusFrameTextureFrameName:SetWidth(100);
		if ( onChange ) then
			-- the frame needs to be repositioned because anchor offsets get adjusted with scale
			JcfFocusFrame:ClearAllPoints();
			JcfFocusFrame:SetPoint("TOPLEFT", (x - 29) / SMALL_FOCUS_UPSCALE, (y + 13) / SMALL_FOCUS_UPSCALE - GetScreenHeight());
		end
		JcfFocusFrame:RegisterEvent("UNIT_CLASSIFICATION_CHANGED");
		JcfFocusFrame.showClassification = true;
		JcfFocusFrame:RegisterEvent("PLAYER_FLAGS_CHANGED");
		JcfFocusFrame.showPVP = true;
		JcfFocusFrame.showLeader = true;
		JcfFocusFrame.showAuraCount = true;
		JcfTargetFrame_Update(JcfFocusFrame);
	end
end

function JcfFocusFrame_UpdateBuffsOnTop()
	if ( JCF_FOCUS_FRAME_BUFFS_ON_TOP ) then
		JcfFocusFrame.buffsOnTop = true;
	else
		JcfFocusFrame.buffsOnTop = false;
	end
	JcfTargetFrame_UpdateAuras(JcfFocusFrame);
end