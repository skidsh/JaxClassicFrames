JCFTargetSettings = {}

local function GetSettings()
    return JaxClassicFrames.db.profile.target
end

function JCFTargetSettings:GetEnabled()
    return GetSettings().enabled
end
function JCFTargetSettings:SetEnabled(_, value)
    GetSettings().enabled = value
    self:RebuildFrames()
end

function JCFTargetSettings:GetClassPortraitEnabled()
    return GetSettings().classPortrait
end
function JCFTargetSettings:SetClassPortraitEnabled(_, value)
    GetSettings().classPortrait = value
    JcfUnitFramePortrait_Update(_G["JcfTargetFrame"])
end

function JCFTargetSettings:GetClassColorHealthEnabled()
    return GetSettings().classColorHealthBar
end
function JCFTargetSettings:SetClassColorHealthEnabled(_, value)
    GetSettings().classColorHealthBar = value
    self:RebuildFrames()
end


function JCFTargetSettings:GetHideNameBackground()
    return GetSettings().hideNameBackground
end
function JCFTargetSettings:SetHideNameBackground(_, value)
    GetSettings().hideNameBackground = value
    self:RebuildFrames()
end

function JCFTargetSettings:GetCastBarScale()
    return GetSettings().castBarScale
end
function JCFTargetSettings:SetCastBarScale(_, value)
    GetSettings().castBarScale = value
    JcfTargetFrame.spellbar:Show()
    UIFrameFadeOut(JcfTargetFrame.spellbar, 3, 1, 0)
    self:RebuildFrames()
end

function JCFTargetSettings:GetCastBarXOffset()
    return GetSettings().castBarXOffset
end
function JCFTargetSettings:SetCastBarXOffset(_, value)
    GetSettings().castBarXOffset = value
    JcfTargetFrame.spellbar:Show()
    UIFrameFadeOut(JcfTargetFrame.spellbar, 3, 1, 0)
    self:RebuildFrames()
end

function JCFTargetSettings:GetCastBarYOffset()
    return GetSettings().castBarYOffset
end
function JCFTargetSettings:SetCastBarYOffset(_, value)
    GetSettings().castBarYOffset = value
    JcfTargetFrame.spellbar:Show()
    UIFrameFadeOut(JcfTargetFrame.spellbar, 3, 1, 0)
    self:RebuildFrames()
end

function JCFTargetSettings:GetCastBarReanchor()
    return GetSettings().castBarReanchor
end
function JCFTargetSettings:SetCastBarReanchor(_, value)
    GetSettings().castBarReanchor = value
    JcfTargetFrame.spellbar:Show()
    UIFrameFadeOut(JcfTargetFrame.spellbar, 3, 1, 0)
    self:RebuildFrames()
end

function JCFTargetSettings:GetTotXOffset()
    return GetSettings().totXOffset
end
function JCFTargetSettings:SetTotXOffset(_, value)
    GetSettings().totXOffset = value
    self:RebuildFrames()
end

function JCFTargetSettings:GetTotYOffset()
    return GetSettings().totYOffset
end
function JCFTargetSettings:SetTotYOffset(_, value)
    GetSettings().totYOffset = value
    self:RebuildFrames()
end

function JCFTargetSettings:GetTotReanchor()
    return GetSettings().totReanchor
end
function JCFTargetSettings:SetTotReanchor(_, value)
    GetSettings().totReanchor = value
    self:RebuildFrames()
end


function JCFTargetSettings:RebuildFrames()
    if not JaxClassicFrames.DisableFrames then
        JaxClassicFrames.DisableFrames = {}
    end
    JaxClassicFrames.DisableFrames["JcfTargetFrame"] = not GetSettings().enabled
    JaxClassicFrames.DisableFrames[JcfFramesToSyncAndHide["JcfTargetFrame"].name] = not GetSettings().enabled
    if GetSettings().enabled then
        _G["JcfTargetFrame"]:SetAlpha(1)
        _G[JcfFramesToSyncAndHide["JcfTargetFrame"].name]:SetAlpha(0)
    else
        _G["JcfTargetFrame"]:SetAlpha(0)
        _G[JcfFramesToSyncAndHide["JcfTargetFrame"].name]:SetAlpha(1)
    end

    local spellbar = JcfTargetFrame.spellbar;
    JcfCastingBarFrame_SetIcon(spellbar, 298591)
    spellbar:SetMinMaxValues(0,1)
    spellbar:SetValue(1)
    spellbar.Text:SetText("Moving")

    JcfUnitFramePortrait_Update(_G["JcfTargetFrame"])

    JcfTargetFrame_Update(JcfTargetFrame)
    JcfTargetFrame_CheckFaction(JcfTargetFrame)
end