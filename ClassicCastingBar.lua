local ClearCastOnInterrupt = true;
local PlayerCastingBarFrame = PlayerCastingBarFrame
local TargetFrame = TargetFrame;
local FocusFrame = FocusFrame;

local function HookOnEventPlayer(self, event, ...)
    if (self.type == "player" or self.type == "target")
    then
        self:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
        if (self.type == "player") then        
            self.Text:SetPoint("TOPLEFT", 0, 2)
            self.Text:SetPoint("TOPRIGHT", 0, 2)
        end
        if (self.type == "target") then
            self.Text:SetPoint("TOPLEFT", 0, 4)
            self.Text:SetPoint("TOPRIGHT", 0, 4)
        end
    end
    if (self.type == "nameplate") then
        self.Spark:SetHeight(self:GetHeight()+7)
        self.Icon:ClearAllPoints()
        self.Icon:SetPoint("TOPLEFT", -21, 0)
        self.Icon:SetSize(self:GetHeight(), self:GetHeight())
        if (not self.newBackground) then
            self.newBackground = self:CreateTexture(nil, "BACKGROUND")
        end
        self.newBackground:SetAllPoints(self)
        self.newBackground:SetColorTexture(0, 0, 0, 0.4)
    end
    if ( self.barType == "interrupted" or event == "UNIT_SPELLCAST_INTERRUPTED") then
        self:SetStatusBarColor(1, 0, 0, 1);
        self.Spark:Show()
        if (ClearCastOnInterrupt) then
            self:SetValue(100)
        end
        return
    elseif (self.barType == "channel" or event == "UNIT_SPELLCAST_STOP") then
        self:SetStatusBarColor(0, 1, 0, 1);
    else
        self:SetStatusBarColor(1, 0.7, 0, 1);
    end
    
end
local function HookOnEventTarget(self, event, ...)    
    if (self == PlayerCastingBarFrame and not PlayerCastingBarFrame.attachedToPlayerFrame) then
        return
    end
    self.Icon:ClearAllPoints()
    self.Icon:SetPoint("TOPLEFT", -23, 5)
    local border = self.Border or self.border
    if (border) then
        border:ClearAllPoints()
        border:SetPoint("TOPLEFT", -23, 20)
        border:SetPoint("TOPRIGHT", 23, 20)
        border:SetTexture("Interface\\CastingBar\\UI-CastingBar-Border-Small")
        border:SetSize(0, 49)
    end
    self.BorderShield:SetTexture("Interface\\CastingBar\\UI-CastingBar-Small-Shield")
    self.BorderShield:ClearAllPoints()
    self.BorderShield:SetPoint("TOPLEFT", -28, 20)
    self.BorderShield:SetPoint("TOPRIGHT", 18, 20)
    self.BorderShield:SetSize(0, 49)
    self.Text:SetFont("SystemFont_Shadow_Small", 16)
    self.Text:ClearAllPoints()
    if (self.TextBorder) then        
        self.TextBorder:ClearAllPoints()
        self.TextBorder:SetPoint("TOPLEFT", 0, 0)
        self.TextBorder:SetPoint("BOTTOMRIGHT", 0, 0)
    end
    HookOnEventPlayer(self, event, ...)
end
local function HookSetLook(self, look)
    self:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
    if ( look == "CLASSIC" ) then
        -- self.Flash = false
        self:SetSize(195, 13)
        self.Border:ClearAllPoints()
        self.Border:SetPoint("TOP", 0, 26)
        self.Border:SetTexture("Interface\\CastingBar\\UI-CastingBar-Border")
        self.Border:SetSize(256, 64)
        self.BorderShield:SetTexture("Interface\\CastingBar\\UI-CastingBar-Small-Shield")
        self.BorderShield:SetSize(256, 64)
        self.BorderShield:ClearAllPoints()
        self.BorderShield:SetPoint("TOP", 0, 28)
        self.Text:ClearAllPoints()
        self.Text:SetPoint("TOPLEFT", 0, 2)
        self.TextBorder:ClearAllPoints()
        self.TextBorder:SetPoint("TOPLEFT", 0, 0)
        self.TextBorder:SetPoint("BOTTOMRIGHT", 0, 0)
        self.playCastFX = false
    elseif ( look == "UNITFRAME" ) then
        if (self == PlayerCastingBarFrame and PlayerCastingBarFrame.attachedToPlayerFrame) then
            HookOnEventTarget(PlayerCastingBarFrame)
        end
    end
end

hooksecurefunc(PlayerCastingBarFrame, "SetLook", HookSetLook)
PlayerCastingBarFrame.type = "player"
PlayerCastingBarFrame:HookScript("OnEvent", HookOnEventPlayer)
PermaHide(PlayerCastingBarFrame.Background)

local function HookTargetFrame(frame, type)
    frame.spellbar.type = type;
    frame.spellbar:HookScript("OnEvent", HookOnEventTarget)
    PermaHide(frame.spellbar.Background)

    hooksecurefunc(frame.spellbar, "SetPoint", function(self)
        local point, relativeTo, relativePoint, xOfs, yOfs = self:GetPoint()
        if (yOfs == -10) then
            self:ClearAllPoints()
            self:SetPoint(point, relativeTo, relativePoint, xOfs, -20)
        end
    end)
end

HookTargetFrame(TargetFrame, "target");
HookTargetFrame(FocusFrame, "target");

hooksecurefunc("CompactUnitFrame_OnLoad", function(frame, unit)
    if ( frame.castBar ) then
        frame.castBar.type = "nameplate";
        frame.castBar.Background:Hide()
        
        for barType, barTypeInfo in pairs(CASTING_BAR_TYPES) do
            CASTING_BAR_TYPES[barType].filling = "Interface\\TargetingFrame\\UI-StatusBar"
            CASTING_BAR_TYPES[barType].full = "Interface\\TargetingFrame\\UI-StatusBar"
        end
        
        frame.castBar:HookScript("OnEvent", HookOnEventPlayer)
    end
end)
hooksecurefunc("DefaultCompactNamePlateFrameAnchorInternal", function(self, options)
    HookOnEventPlayer(self.castBar)
end)

hooksecurefunc("PlayerFrame_AttachCastBar", function()

end)