function PermaHide(frameToHide)
	frameToHide:Hide()
	hooksecurefunc(frameToHide, "Show", function()
		frameToHide:Hide()
	end)
end

function ApplyClassicFrame(frame)
	local function PositionTargetBars()
		local powerColor = GetPowerBarColor(UnitPowerType(frame.unit))

		local FrameManaBar = frame.TargetFrameContent.TargetFrameContentMain.ManaBar;
		local FrameManaBarMask = frame.TargetFrameContent.TargetFrameContentMain.ManaBarMask;
		local FrameManaBarTexture = frame.TargetFrameContent.TargetFrameContentMain.ManaBar.ManaBarTexture

		local FrameHealthBar = frame.TargetFrameContent.TargetFrameContentMain.HealthBar;
		local FrameHealthBarMask = frame.TargetFrameContent.TargetFrameContentMain.HealthBarMask;
		local FrameHealthBarTexture = frame.TargetFrameContent.TargetFrameContentMain.HealthBar.HealthBarTexture

		FrameHealthBarMask:ClearAllPoints()
		FrameHealthBar:ClearAllPoints()
		FrameHealthBarMask:SetSize(240, 17)
		FrameHealthBarMask:SetPoint("TOPLEFT", 0, -44);
		FrameHealthBar:SetSize(120, 9);
		FrameHealthBar:SetPoint("TOPLEFT", 26, -47);
		FrameHealthBarTexture:SetTexture("Interface\\TargetingFrame\\UI-StatusBar")
		FrameHealthBar:SetStatusBarColor(0, 1, 0);

		FrameManaBarMask:ClearAllPoints()
		FrameManaBar:ClearAllPoints()
		FrameManaBarMask:SetSize(250, 27)
		FrameManaBarMask:SetPoint("TOPLEFT", -40, -48);
		FrameManaBar:SetSize(120, 9);
		FrameManaBar:SetPoint("TOPLEFT", 25, -58);
		FrameManaBarTexture:SetTexture("Interface\\TargetingFrame\\UI-StatusBar")
		FrameManaBar:SetStatusBarColor(powerColor.r, powerColor.g, powerColor.b)


		local frameNameText = frame.TargetFrameContent.TargetFrameContentMain.Name;
		frameNameText:ClearAllPoints()
		frameNameText:SetJustifyH("CENTER")
		frameNameText:SetPoint("TOPLEFT", frame.TargetFrameContent.TargetFrameContentMain, "TOPLEFT", 40, -31)
	end

	hooksecurefunc(frame, "CheckClassification", function()
		frame.TargetFrameContainer.FrameTexture:Hide()
		if (frame.TargetFrameContainer.ClassicTexture == nil) then
			frame.TargetFrameContainer.ClassicTexture = frame.TargetFrameContainer:CreateTexture(nil, "ARTWORK")
		end
		frame.TargetFrameContainer.ClassicTexture:ClearAllPoints()
		frame.TargetFrameContainer.ClassicTexture:SetPoint("TOPLEFT", frame.TargetFrameContainer, "TOPLEFT", 20, -5)
		frame.TargetFrameContainer.ClassicTexture:SetSize(232, 100)
		frame.TargetFrameContainer.ClassicTexture:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame")
		--<TexCoords left="0.09375" right="1.0" top="0" bottom="0.78125"/>
		frame.TargetFrameContainer.ClassicTexture:SetTexCoord(0.09375, 1, 0, 0.78125)
		frame.TargetFrameContent.TargetFrameContentMain.ReputationColor:Hide()
		frame.TargetFrameContainer.Portrait:SetSize(64, 64)
		frame.TargetFrameContainer:SetFrameStrata("MEDIUM")
		frame.TargetFrameContent.TargetFrameContentContextual:SetFrameStrata("MEDIUM")
	end)

	hooksecurefunc(frame, "Update", function()
		local contextual = frame.TargetFrameContent.TargetFrameContentContextual;
		PermaHide(contextual.PrestigeBadge)
		PermaHide(contextual.PrestigePortrait)
		PermaHide(contextual.PvpIcon)
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

			frame.totFrame.ManaBarMask:ClearAllPoints()
			frame.totFrame.ManaBarMask:SetPoint("TOPLEFT", frame.totFrame, "TOPLEFT", 0, -18)
			frame.totFrame.ManaBar:SetFrameLevel(1)
			frame.totFrame.ManaBar:ClearAllPoints()
			frame.totFrame.ManaBar:SetPoint("TOPLEFT", frame.totFrame, "TOPLEFT", 44, -23)
			frame.totFrame.ManaBar:SetSize(46, 9)

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
		local highLevelTexture = contextual.HighLevelTexture;

		highLevelTexture:ClearAllPoints();
		highLevelTexture:SetParent(contextual)
		highLevelTexture:SetPoint("CENTER", contextual, "CENTER", 81, -22)

		levelText:ClearAllPoints();
		levelText:SetParent(contextual)
		levelText:SetPoint("CENTER", contextual, "CENTER", 81, -22)
	end)

	hooksecurefunc(frame, "CreateTargetofTarget", function()
		if (frame.totFrame) then
			frame.totFrame.FrameTexture:Hide()
		end
	end)
end
