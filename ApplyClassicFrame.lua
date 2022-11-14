function PermaHide(frameToHide)
	frameToHide:Hide()
	hooksecurefunc(frameToHide, "Show", function()
		frameToHide:Hide()
	end)
end

function ApplyClassicFrame(frame)
	local contextual = frame.TargetFrameContent.TargetFrameContentContextual;
	PermaHide(contextual.PrestigeBadge)
	PermaHide(contextual.PrestigePortrait)
	PermaHide(contextual.PvpIcon)
	PermaHide(frame.TargetFrameContainer.Flash)

	frame.Background = frame:CreateTexture(nil, "ARTWORK");
	frame.Background:SetPoint("TOPLEFT", frame, "TOPLEFT", 26, -29);
	frame.Background:SetSize(119, 41)
	frame.Background:SetColorTexture(0, 0, 0, 0.5)
	
	if (GetCVar("comboPointLocation") == "1") then
		ComboFrame:SetPoint("TOPRIGHT", TargetFrame, -25, -20)
	end
	
	local function PositionTargetBars()
		local powerColor = GetPowerBarColor(UnitPowerType(frame.unit))

		local FrameManaBar = frame.TargetFrameContent.TargetFrameContentMain.ManaBar;
		local FrameHealthBar = frame.TargetFrameContent.TargetFrameContentMain.HealthBar;

		FrameHealthBar:ClearAllPoints()
		FrameHealthBar:SetSize(119, 12);
		FrameHealthBar:SetPoint("TOPLEFT", 26, -48);
		FrameHealthBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
		FrameHealthBar:SetStatusBarColor(0, 1, 0);

		FrameManaBar:ClearAllPoints()
		FrameManaBar:SetSize(119, 12);
		FrameManaBar:SetPoint("TOPLEFT", 26, -59);

		local atlas = GetAtlasForBar(FrameManaBar)

		if (atlas) then
			if (FrameManaBar.SetStatusBarAtlas) then
				FrameManaBar:SetStatusBarAtlas(atlas)
			end
			FrameManaBar:SetStatusBarColor(1, 1, 1)
		else			
			FrameManaBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
			FrameManaBar:SetStatusBarColor(powerColor.r, powerColor.g, powerColor.b)
		end

		local frameNameText = frame.TargetFrameContent.TargetFrameContentMain.Name;
		frameNameText:ClearAllPoints()
		frameNameText:SetJustifyH("CENTER")
		frameNameText:SetPoint("TOPLEFT", frame.TargetFrameContainer, "TOPLEFT", 40, -33)
		frameNameText:SetParent(frame.TargetFrameContainer)

		FrameHealthBar.TextString:SetParent(frame.TargetFrameContainer)
		FrameHealthBar.RightText:SetParent(frame.TargetFrameContainer)
		FrameHealthBar.LeftText:SetParent(frame.TargetFrameContainer)

		FrameManaBar.TextString:SetParent(frame.TargetFrameContainer)
		FrameManaBar.RightText:SetParent(frame.TargetFrameContainer)
		FrameManaBar.LeftText:SetParent(frame.TargetFrameContainer)
		
		frame.TargetFrameContent.TargetFrameContentMain.ManaBar.RightText:SetPoint("RIGHT", frame.TargetFrameContent.TargetFrameContentMain.ManaBar, "RIGHT", -4, 0)
	end

	local function CreateNameBackground()
		if (frame.nameBackground == nil) then
			frame.nameBackground = frame.TargetFrameContainer:CreateTexture(nil, "BACKGROUND")
		end

		frame.nameBackground:SetSize(119, 19)
		frame.nameBackground:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-LevelBackground")
		frame.nameBackground:ClearAllPoints()
		frame.nameBackground:SetPoint("TOPRIGHT", frame.TargetFrameContent.TargetFrameContentMain, "TOPRIGHT", -88, -30)
		if ( not UnitPlayerControlled(frame.unit) and UnitIsTapDenied(frame.unit) ) then
			frame.nameBackground:SetVertexColor(0.5, 0.5, 0.5);
		else
			local r,g,b = UnitSelectionColor(frame.unit)
			frame.nameBackground:SetVertexColor(r,g,b);
		end
	end

	hooksecurefunc(frame, "CheckClassification", function()
		frame.TargetFrameContainer.FrameTexture:Hide()
		CreateNameBackground()
		if (frame.TargetFrameContainer.ClassicTexture == nil) then
			frame.TargetFrameContainer.ClassicTexture = frame.TargetFrameContainer:CreateTexture(nil, "ARTWORK")
		end
		frame.TargetFrameContainer.ClassicTexture:ClearAllPoints()
		frame.TargetFrameContainer.ClassicTexture:SetPoint("TOPLEFT", frame.TargetFrameContainer, "TOPLEFT", 20, -7)
		frame.TargetFrameContainer.ClassicTexture:SetSize(232, 100)
		frame.TargetFrameContainer.ClassicTexture:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame")
		--<TexCoords left="0.09375" right="1.0" top="0" bottom="0.78125"/>
		frame.TargetFrameContainer.ClassicTexture:SetTexCoord(0.09375, 1, 0, 0.78125)
		frame.TargetFrameContent.TargetFrameContentMain.ReputationColor:Hide()
		frame.TargetFrameContainer.Portrait:SetSize(64, 64)
		frame.TargetFrameContainer:SetFrameStrata("MEDIUM")
		frame.TargetFrameContainer.BossPortraitFrameTexture:SetDrawLayer("BACKGROUND", 1)
		frame.TargetFrameContent.TargetFrameContentContextual:SetFrameStrata("MEDIUM")
	end)

	local function fixDebuffs()
		local frameName = frame.totFrame:GetName();
		local suffix = "Debuff";
		local frameNameWithSuffix = frameName..suffix;
		for i=1,4 do
			local debuffName = frameNameWithSuffix..i;
			_G[debuffName]:ClearAllPoints()
			if (i == 1) then
				_G[debuffName]:SetPoint("TOPLEFT", frame.totFrame, "TOPRIGHT", -23, -8)
			elseif (i==2) then
				_G[debuffName]:SetPoint("TOPLEFT", frame.totFrame, "TOPRIGHT", -10, -8)
			elseif (i==3) then
				_G[debuffName]:SetPoint("TOPLEFT", frame.totFrame, "TOPRIGHT", -23, -21)
			elseif (i==4) then
				_G[debuffName]:SetPoint("TOPLEFT", frame.totFrame, "TOPRIGHT", -10, -21)
			end
		end
	end

	hooksecurefunc(frame, "Update", function()
		PositionTargetBars();
		if (frame.totFrame) then
			frame.totFrame:ClearAllPoints()
			frame.totFrame:SetPoint("TOPLEFT", frame, "BOTTOMRIGHT", -83, 17)
			frame.totFrame.FrameTexture:Hide()

			local powerColor = GetPowerBarColor(UnitPowerType(frame.totFrame.unit))

			frame.totFrame.HealthBarMask:Hide()
			frame.totFrame.HealthBar:ClearAllPoints()
			frame.totFrame.HealthBar:SetPoint("TOPRIGHT", -29, -15)
			frame.totFrame.HealthBar:SetSize(46, 7)
			frame.totFrame.HealthBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
			frame.totFrame.HealthBar:SetStatusBarColor(0, 1, 0);
			frame.totFrame.HealthBar:SetFrameLevel(1)

			frame.totFrame.ManaBarMask:Hide()
			frame.totFrame.ManaBar:ClearAllPoints()
			frame.totFrame.ManaBar:SetPoint("TOPRIGHT", -29, -23)
			frame.totFrame.ManaBar:SetSize(46, 7)
			frame.totFrame.ManaBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
			frame.totFrame.ManaBar:SetStatusBarColor(powerColor.r, powerColor.g, powerColor.b)
			frame.totFrame.ManaBar:SetFrameLevel(1)

			if (frame.totFrame.ClassicTexture == nil) then
				frame.totFrame.ClassicTexture = frame.totFrame:CreateTexture(nil, "BORDER")
			end
			frame.totFrame.ClassicTexture:ClearAllPoints()
			frame.totFrame.ClassicTexture:SetPoint("TOPLEFT", frame.totFrame, "TOPLEFT", 0, 0)
			frame.totFrame.ClassicTexture:SetTexture("Interface\\TargetingFrame\\UI-TargetofTargetFrame")
			-- <TexCoords left="0.015625" right="0.7265625" top="0" bottom="0.703125"/>
			frame.totFrame.ClassicTexture:SetTexCoord(0.015625, 0.7265625, 0, 0.703125)
			frame.totFrame.ClassicTexture:SetSize(93, 45)

			frame.totFrame.name:ClearAllPoints();
			frame.totFrame.name:SetPoint("BOTTOMLEFT", 42, 5)
			fixDebuffs()
		end
	end)

	hooksecurefunc(frame, "CheckLevel", function()
		local contextual = frame.TargetFrameContent.TargetFrameContentContextual
		local levelText = frame.TargetFrameContent.TargetFrameContentMain.LevelText;
		local petBattle = contextual.PetBattleIcon;
		local highLevelTexture = contextual.HighLevelTexture;

		highLevelTexture:ClearAllPoints();
		highLevelTexture:SetParent(contextual)
		highLevelTexture:SetPoint("CENTER", contextual, "CENTER", 81, -24)

		petBattle:ClearAllPoints();
		petBattle:SetParent(contextual)
		petBattle:SetPoint("CENTER", contextual, "CENTER", 81, 24)

		levelText:ClearAllPoints();
		levelText:SetParent(contextual)
		levelText:SetPoint("CENTER", contextual, "CENTER", 81, -24)
	end)

	hooksecurefunc(frame, "CreateTargetofTarget", function()
		if (frame.totFrame) then
			frame.totFrame.FrameTexture:Hide()
		end
	end)
	
	frame:HookScript("OnEvent", function(s, e, ...)
		PositionTargetBars()
	end)


	if (frame.totFrame) then
		frame.totFrame:RegisterEvent("UNIT_AURA")
		frame.totFrame:HookScript("OnEvent", function(s, e, ...)
			local arg1 = ...;
			if ((not (arg1 == "")) and (not (arg1 == nil)) and
				(not (s.unit == "")) and (not (s.unit == nil)) and
				 UnitIsUnit(arg1, s.unit)) then
				RefreshDebuffs(s, s.unit, nil, nil, true)
			end
		end)
	end
end
