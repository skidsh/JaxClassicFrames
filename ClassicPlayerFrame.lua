-- LoadAddOn("Blizzard_DebugTools")

-- DevTools_Dump()
local PlayerName = PlayerName
local PlayerFrame = PlayerFrame
local PlayerLevelText = PlayerLevelText
local PlayerHitIndicator = PlayerHitIndicator
local PlayerFrameManaBar = PlayerFrameManaBar
local PlayerFrameHealthBar = PlayerFrameHealthBar
local SetTextStatusBarText = SetTextStatusBarText
local PlayerFrameManaBarText = PlayerFrameManaBarText
local PlayerFrameHealthBarText = PlayerFrameHealthBarText
local PlayerFrameManaBarTextLeft = PlayerFrameManaBarTextLeft
local PlayerFrameManaBarTextRight = PlayerFrameManaBarTextRight
local PlayerFrameHealthBarTextLeft = PlayerFrameHealthBarTextLeft
local PlayerFrameHealthBarTextRight = PlayerFrameHealthBarTextRight
local ranOnce = false

function GetAtlasForBar(self)
	local atlas = nil
	if (self.powerType and (self.powerType >= 11 or self.powerType == 8)) then
		atlas = PowerBarColor[self.powerType].atlas
	end
	return atlas
end

local function updateBarTexture(self, texture)
	local atlas = GetAtlasForBar(self)
	if (atlas) then
		if (self.SetStatusBarAtlas) then
			self:SetStatusBarAtlas(atlas)
		end
	else
		if (texture == "Interface\\TargetingFrame\\UI-StatusBar") then return end
		self:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
	end
end
local function updateManaBarColor(self, r, g, b, a)
	local color = {};
	color.r = 1;
	color.g = 1;
	color.b = 1;
	local atlas = GetAtlasForBar(self)
	if (not atlas and self.powerType) then
		color = GetPowerBarColor(self.powerType)
	end
	if (color.r ~= r or color.g ~= g or color.b ~= b) then
		self:SetStatusBarColor(color.r, color.g, color.b)
	end
end

local function updateBarColor(self, r, g, b, a)
	local color = {};
	color.r = 0;
	color.g = 1;
	color.b = 0;
	if (self.powerType) then
		color = GetPowerBarColor(self.powerType)
	end
	if (color.r ~= r or color.g ~= g or color.b ~= b) then
		self:SetStatusBarColor(color.r, color.g, color.b)
	end
end

PlayerFrame.PlayerFrameContainer.FrameTexture:ClearAllPoints()
PlayerFrame.PlayerFrameContainer.FrameTexture:SetPoint("TOPLEFT", PlayerFrame.PlayerFrameContainer, "TOPLEFT", -20, -5)
PlayerFrame.PlayerFrameContainer.FrameTexture:SetSize(232, 100)
PlayerFrame.PlayerFrameContainer.FrameTexture:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame")
--<TexCoords left="1.0" right="0.09375" top="0" bottom="0.78125"/>
PlayerFrame.PlayerFrameContainer.FrameTexture:SetTexCoord(1, 0.09375, 0, 0.78125)
PlayerFrame.PlayerFrameContainer:SetFrameLevel(4)
PlayerFrame.PlayerFrameContent.PlayerFrameContentContextual:SetFrameLevel(5)
PlayerFrame.PlayerFrameContainer.PlayerPortrait:SetSize(64, 64)

PlayerFrameHealthBarText:SetParent(PlayerFrame.PlayerFrameContainer)
PlayerFrameManaBarText:SetParent(PlayerFrame.PlayerFrameContainer)
PlayerFrameHealthBarTextLeft:SetParent(PlayerFrame.PlayerFrameContainer)
PlayerFrameManaBarTextLeft:SetParent(PlayerFrame.PlayerFrameContainer)
PlayerFrameHealthBarTextRight:SetParent(PlayerFrame.PlayerFrameContainer)
PlayerFrameManaBarTextRight:SetParent(PlayerFrame.PlayerFrameContainer)

PlayerFrame.Background = PlayerFrame:CreateTexture(nil, "ARTWORK");
PlayerFrame.Background:SetPoint("TOPLEFT", PlayerFrame, "TOPLEFT", 86, -26);
PlayerFrame.Background:SetSize(119, 41)
PlayerFrame.Background:SetColorTexture(0, 0, 0, 0.5)

local function RunOncePlayer()
	if (not ranOnce) then
		ranOnce = true
		PermaHide(PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.StatusTexture);
		PermaHide(PlayerFrame.PlayerFrameContent.PlayerFrameContentContextual.PrestigeBadge)
		PermaHide(PlayerFrame.PlayerFrameContent.PlayerFrameContentContextual.PrestigePortrait)
		PermaHide(PlayerFrame.PlayerFrameContent.PlayerFrameContentContextual.PlayerPortraitCornerIcon)
		PermaHide(PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.ManaBarMask)
		PermaHide(PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.HealthBarMask)
		PermaHide(PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.HealthBarArea.PlayerFrameHealthBarAnimatedLoss)
		PermaHide(PlayerFrameManaBar.FeedbackFrame)
		PermaHide(PlayerFrame.threatIndicator)
		if (GetCVar("comboPointLocation") == "1") then
			PermaHide(ComboPointPlayerFrame)
		end
	end
end

local function HookBars(frameToHook, colorHook)
	updateBarTexture(frameToHook);
	colorHook(frameToHook);
	hooksecurefunc(frameToHook, "SetStatusBarTexture", updateBarTexture)
	hooksecurefunc(frameToHook, "SetStatusBarColor", updateManaBarColor)
end

HookBars(PlayerFrameHealthBar, updateBarColor)
HookBars(PlayerFrameManaBar, updateManaBarColor)

hooksecurefunc("PlayerFrame_ToPlayerArt", function()
	RunOncePlayer()
	PlayerFrameHealthBar:SetSize(119, 12);
	PlayerFrameHealthBar:SetPoint("TOPLEFT", 88, -46);

	PlayerFrameManaBar:SetSize(119, 12);
	PlayerFrameManaBar:SetPoint("TOPLEFT", 88, -57);
 end)

 hooksecurefunc("PlayerFrame_UpdatePlayerNameTextAnchor", function()
	PlayerName:ClearAllPoints()
	PlayerName:SetJustifyH("CENTER")
	PlayerName:SetPoint("TOPLEFT", PlayerFrame.PlayerFrameContainer, "TOPLEFT", 97, -31)
 end)

 hooksecurefunc("PlayerFrame_UpdateLevel", function()
	PlayerLevelText:ClearAllPoints();
	PlayerLevelText:SetPoint("CENTER", PlayerFrame.PlayerFrameContent.PlayerFrameContentContextual, "CENTER", -81, -22)
	PlayerLevelText:SetParent(PlayerFrame.PlayerFrameContent.PlayerFrameContentContextual)
	PlayerHitIndicator:SetParent(PlayerFrame.PlayerFrameContent.PlayerFrameContentContextual)
 end)

 hooksecurefunc("PlayerFrame_UpdateRolesAssigned", function()
	local roleIcon = PlayerFrame.PlayerFrameContent.PlayerFrameContentContextual.RoleIcon;
	roleIcon:SetShown(true);
	roleIcon:ClearAllPoints();
	roleIcon:SetPoint("CENTER", PlayerFrame.PlayerFrameContent.PlayerFrameContentContextual.LeaderIcon, "CENTER", 15, 0)

	PlayerLevelText:SetShown(true);
 end)

local function holyPower(self)
	self:ClearAllPoints()
	self:SetPoint("TOPLEFT", 10, 15)
end
local function alternatePower(self)
	self:ClearAllPoints()
	self:SetPoint("TOPLEFT", 30, 5)
end
hooksecurefunc("AlternatePowerBar_OnEvent", alternatePower)
PaladinPowerBarFrame:HookScript("OnEvent", holyPower)