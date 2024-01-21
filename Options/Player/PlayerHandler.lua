JCFPlayerSettings = {}

local function GetSettings()
    return JaxClassicFrames.db.profile.player
end

function JCFPlayerSettings:GetEnabled()
    return GetSettings().enabled
end
function JCFPlayerSettings:SetEnabled(_, value)
    GetSettings().enabled = value
    self:RebuildFrames()
end

function JCFPlayerSettings:GetClassPortraitEnabled()
    return GetSettings().classPortrait
end
function JCFPlayerSettings:SetClassPortraitEnabled(_, value)
    GetSettings().classPortrait = value
    self:RebuildFrames()
end

function JCFPlayerSettings:GetCastBarEnabled()
    return GetSettings().enableCastBar
end
function JCFPlayerSettings:SetCastBarEnabled(_, value)
    GetSettings().enableCastBar = value
    self:RebuildFrames()
end

function JCFPlayerSettings:GetCastBarScale()
    return GetSettings().castBarScale
end
function JCFPlayerSettings:SetCastBarScale(_, value)
    GetSettings().castBarScale = value
    JcfCastingBarFrame:Show()
    UIFrameFadeOut(JcfCastingBarFrame, 3, 1, 0)
    self:RebuildFrames()
end

function JCFPlayerSettings:GetClassColorHealthEnabled()
    return GetSettings().classColorHealthBar
end
function JCFPlayerSettings:SetClassColorHealthEnabled(_, value)
    GetSettings().classColorHealthBar = value
    self:RebuildFrames()
end

function JCFPlayerSettings:GetEliteMode()
    return GetSettings().eliteMode
end
function JCFPlayerSettings:SetEliteMode(_, value)
    GetSettings().eliteMode = value
    self:RebuildFrames()
end

function JCFPlayerSettings:RebuildFrames()
    if not JaxClassicFrames.DisableFrames then
        JaxClassicFrames.DisableFrames = {}
    end
    JaxClassicFrames.DisableFrames["JcfPlayerFrame"] = not GetSettings().enabled
    JaxClassicFrames.DisableFrames[JcfFramesToSyncAndHide["JcfPlayerFrame"].name] = not GetSettings().enabled
    if GetSettings().enabled then        
        _G["JcfPlayerFrame"]:SetAlpha(1)
        _G[JcfFramesToSyncAndHide["JcfPlayerFrame"].name]:SetAlpha(0)
    else
        _G["JcfPlayerFrame"]:SetAlpha(0)
        _G[JcfFramesToSyncAndHide["JcfPlayerFrame"].name]:SetAlpha(1)
    end
    JaxClassicFrames.DisableFrames["JcfCastingBarFrame"] = not GetSettings().enableCastBar
    JaxClassicFrames.DisableFrames[JcfFramesToSyncAndHide["JcfCastingBarFrame"].name] = not GetSettings().enableCastBar

    local spellbar = JcfCastingBarFrame;
    JcfCastingBarFrame_SetIcon(spellbar, 298591)
    spellbar:SetMinMaxValues(0,1)
    spellbar:SetValue(1)
    spellbar.Text:SetText("Moving")
    spellbar:SetScale(GetSettings().castBarScale)

    JcfUnitFramePortrait_Update(_G["JcfPlayerFrame"])

    if (GetSettings().classColorHealthBar) then
		local _, classKey = UnitClass("player")
		local r,g,b,_ = GetClassColor(classKey)
        JcfPlayerFrameHealthBar.lockColor = true
		JcfPlayerFrameHealthBar:SetStatusBarColor(r, g, b);
    else
        JcfPlayerFrameHealthBar:SetStatusBarColor(0, 1, 0);
	end


    if GetSettings().eliteMode == 0 then
		JcfPlayerFrameTexture:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame"); end
	if GetSettings().eliteMode == 1 then
		JcfPlayerFrameTexture:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-Rare.blp"); end
	if GetSettings().eliteMode == 3 then
		JcfPlayerFrameTexture:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-Rare-Elite.blp"); end
	if GetSettings().eliteMode == 2 then
		JcfPlayerFrameTexture:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-Elite.blp"); end
end