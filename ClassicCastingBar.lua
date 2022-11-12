local ClearCastOnInterrupt = false;
local PlayerCastingBarFrame = PlayerCastingBarFrame
local TargetFrame = TargetFrame;
local FocusFrame = FocusFrame;

local function HookOnEventPlayer(self, event, ...)
    if (self.unit == nil) then return end
    self:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
    if (self.unit == "player" or self.unit == "target" or self.unit == "focus") then
        self.Text:SetPoint("TOPLEFT", 0, 4)
        self.Text:SetPoint("TOPRIGHT", 0, 4)
    end
    if (string.find(self.unit, "nameplate")) then
        self.Icon:ClearAllPoints()
        self.Icon:SetPoint("TOPLEFT", -21, 0)
        self.Icon:SetSize(self:GetHeight(), self:GetHeight())
        if (not self.newBackground) then            
            self.newBackground = self:CreateTexture(nil, "BACKGROUND")
        end
        self.newBackground:SetAllPoints()
        self.newBackground:SetColorTexture(0, 0, 0, 0.4)
    end
    if ( self.barType == "interrupted" ) then
        self:SetStatusBarColor(1, 0, 0, 1);
        if (ClearCastOnInterrupt) then
            self:SetValue(100)
        end
        self:HideSpark()
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
    PermaHide(self.Background)
    if ( look == "CLASSIC" ) then
        -- self.Flash = false
        self:SetSize(195, 13)
        self.Border:ClearAllPoints()
        self.Border:SetPoint("TOP", 0, 28)
        self.Border:SetTexture("Interface\\CastingBar\\UI-CastingBar-Border")
        self.Border:SetSize(256, 64)
        self.BorderShield:SetTexture("Interface\\CastingBar\\UI-CastingBar-Small-Shield")
        self.BorderShield:SetSize(256, 64)
        self.BorderShield:ClearAllPoints()
        self.BorderShield:SetPoint("TOP", 0, 28)
        self.Text:ClearAllPoints()
        self.Text:SetPoint("TOPLEFT", 0, 4)
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
PlayerCastingBarFrame:HookScript("OnEvent", HookOnEventPlayer)
PermaHide(PlayerCastingBarFrame.Background)

local function HookTargetFrame(frame)
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

HookTargetFrame(TargetFrame);
HookTargetFrame(FocusFrame);

hooksecurefunc("CompactUnitFrame_OnLoad", function(frame, unit)
    if ( frame.castBar ) then
        frame.castBar:HookScript("OnEvent", HookOnEventPlayer)
    end
end)

hooksecurefunc("DefaultCompactNamePlateFrameAnchorInternal", function(self, options)
    HookOnEventPlayer(self.castBar)
end)

hooksecurefunc("PlayerFrame_AttachCastBar", function()

end)