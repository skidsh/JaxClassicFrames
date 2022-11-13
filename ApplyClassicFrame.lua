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

	frame.Background = frame:CreateTexture(nil, "ARTWORK");
	frame.Background:SetPoint("TOPLEFT", frame, "TOPLEFT", 26, -29);
	frame.Background:SetSize(119, 41)
	frame.Background:SetColorTexture(0, 0, 0, 0.5)

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
		FrameManaBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
		FrameManaBar:SetStatusBarColor(powerColor.r, powerColor.g, powerColor.b)


		local frameNameText = frame.TargetFrameContent.TargetFrameContentMain.Name;
		frameNameText:ClearAllPoints()
		frameNameText:SetJustifyH("CENTER")
		frameNameText:SetPoint("TOPLEFT", frame.TargetFrameContent.TargetFrameContentMain, "TOPLEFT", 40, -33)


		FrameHealthBar.TextString:SetParent(frame.TargetFrameContainer)
		FrameManaBar.TextString:SetParent(frame.TargetFrameContainer)
		FrameHealthBar.LeftText:SetParent(frame.TargetFrameContainer)
		FrameManaBar.RightText:SetParent(frame.TargetFrameContainer)
		FrameHealthBar.RightText:SetParent(frame.TargetFrameContainer)
		FrameManaBar.LeftText:SetParent(frame.TargetFrameContainer)

		frame.TargetFrameContent.TargetFrameContentMain.ManaBar.RightText:SetPoint("RIGHT", frame.TargetFrameContent.TargetFrameContentMain.ManaBar, "RIGHT", -4, 0)
	end

	hooksecurefunc(frame, "CheckClassification", function()
		frame.TargetFrameContainer.FrameTexture:Hide()
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

	hooksecurefunc(frame, "Update", function()
		PositionTargetBars();
		if (frame.totFrame) then
			frame.totFrame:ClearAllPoints()
			frame.totFrame:SetPoint("TOPLEFT", frame, "BOTTOMRIGHT", -55, 17)
			frame.totFrame.FrameTexture:Hide()

			frame.totFrame.HealthBarMask:ClearAllPoints()
			frame.totFrame.HealthBarMask:SetPoint("TOPLEFT", frame.totFrame, "TOPLEFT", 0, -13)
			frame.totFrame.HealthBar:SetFrameLevel(1)
			frame.totFrame.HealthBar:ClearAllPoints()
			frame.totFrame.HealthBar:SetPoint("TOPLEFT", frame.totFrame, "TOPLEFT", 44, -13)
			frame.totFrame.HealthBar:SetSize(46, 9)
			frame.totFrame.HealthBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")


			frame.totFrame.ManaBarMask:ClearAllPoints()
			frame.totFrame.ManaBarMask:SetPoint("TOPLEFT", frame.totFrame, "TOPLEFT", 0, -18)
			frame.totFrame.ManaBar:SetFrameLevel(1)
			frame.totFrame.ManaBar:ClearAllPoints()
			frame.totFrame.ManaBar:SetPoint("TOPLEFT", frame.totFrame, "TOPLEFT", 44, -23)
			frame.totFrame.ManaBar:SetSize(46, 9)
			frame.totFrame.ManaBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")

			if (frame.totFrame.ClassicTexture == nil) then
				frame.totFrame.ClassicTexture = frame.totFrame:CreateTexture(nil, "BORDER")
			end
			frame.totFrame.ClassicTexture:ClearAllPoints()
			frame.totFrame.ClassicTexture:SetPoint("TOPLEFT", frame.totFrame, "TOPLEFT", 0, 0)
			frame.totFrame.ClassicTexture:SetTexture("Interface\\TargetingFrame\\UI-TargetofTargetFrame")
			-- <TexCoords left="0.015625" right="0.7265625" top="0" bottom="0.703125"/>
			frame.totFrame.ClassicTexture:SetTexCoord(0.015625, 0.7265625, 0, 0.703125)
			frame.totFrame.ClassicTexture:SetSize(93, 45)
		end
	end)

	hooksecurefunc("TargetHealthCheck", function()
		PositionTargetBars();
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
end
