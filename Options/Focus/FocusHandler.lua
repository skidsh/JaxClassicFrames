JCFFocusSettings = {}

local function GetSettings()
    return JaxClassicFrames.db.profile.focus
end

function JCFFocusSettings:GetEnabled()
    return GetSettings().enabled
end
function JCFFocusSettings:SetEnabled(_, value)
    GetSettings().enabled = value
    self:RebuildFrames()
end

function JCFFocusSettings:GetClassPortraitEnabled()
    return GetSettings().classPortrait
end
function JCFFocusSettings:SetClassPortraitEnabled(_, value)
    GetSettings().classPortrait = value
    JcfUnitFramePortrait_Update(_G["JcfFocusFrame"])
end

function JCFFocusSettings:GetClassColorHealthEnabled()
    return GetSettings().classColorHealthBar
end
function JCFFocusSettings:SetClassColorHealthEnabled(_, value)
    GetSettings().classColorHealthBar = value
    self:RebuildFrames()
end


function JCFFocusSettings:GetHideNameBackground()
    return GetSettings().hideNameBackground
end
function JCFFocusSettings:SetHideNameBackground(_, value)
    GetSettings().hideNameBackground = value
    self:RebuildFrames()
end

function JCFFocusSettings:GetCastBarScale()
    return GetSettings().castBarScale
end
function JCFFocusSettings:SetCastBarScale(_, value)
    GetSettings().castBarScale = value
    JcfFocusFrame.spellbar:Show()
    UIFrameFadeOut(JcfFocusFrame.spellbar, 3, 1, 0)
    self:RebuildFrames()
end

function JCFFocusSettings:GetCastBarXOffset()
    return GetSettings().castBarXOffset
end
function JCFFocusSettings:SetCastBarXOffset(_, value)
    GetSettings().castBarXOffset = value
    JcfFocusFrame.spellbar:Show()
    UIFrameFadeOut(JcfFocusFrame.spellbar, 3, 1, 0)
    self:RebuildFrames()
end

function JCFFocusSettings:GetCastBarYOffset()
    return GetSettings().castBarYOffset
end
function JCFFocusSettings:SetCastBarYOffset(_, value)
    GetSettings().castBarYOffset = value
    JcfFocusFrame.spellbar:Show()
    UIFrameFadeOut(JcfFocusFrame.spellbar, 3, 1, 0)
    self:RebuildFrames()
end

function JCFFocusSettings:GetCastBarReanchor()
    return GetSettings().castBarReanchor
end
function JCFFocusSettings:SetCastBarReanchor(_, value)
    GetSettings().castBarReanchor = value
    JcfFocusFrame.spellbar:Show()
    UIFrameFadeOut(JcfFocusFrame.spellbar, 3, 1, 0)
    self:RebuildFrames()
end

function JCFFocusSettings:GetTotXOffset()
    return GetSettings().totXOffset
end
function JCFFocusSettings:SetTotXOffset(_, value)
    GetSettings().totXOffset = value
    self:RebuildFrames()
end

function JCFFocusSettings:GetTotYOffset()
    return GetSettings().totYOffset
end
function JCFFocusSettings:SetTotYOffset(_, value)
    GetSettings().totYOffset = value
    self:RebuildFrames()
end

function JCFFocusSettings:GetTotReanchor()
    return GetSettings().totReanchor
end
function JCFFocusSettings:SetTotReanchor(_, value)
    GetSettings().totReanchor = value
    self:RebuildFrames()
end


function JCFFocusSettings:RebuildFrames()
    if not JaxClassicFrames.DisableFrames then
        JaxClassicFrames.DisableFrames = {}
    end
    JaxClassicFrames.DisableFrames["JcfFocusFrame"] = not GetSettings().enabled
    JaxClassicFrames.DisableFrames[JcfFramesToSyncAndHide["JcfFocusFrame"].name] = not GetSettings().enabled
    if GetSettings().enabled then
        _G["JcfFocusFrame"]:SetAlpha(1)
        _G[JcfFramesToSyncAndHide["JcfFocusFrame"].name]:SetAlpha(0)
    else
        _G["JcfFocusFrame"]:SetAlpha(0)
        _G[JcfFramesToSyncAndHide["JcfFocusFrame"].name]:SetAlpha(1)
    end

    local spellbar = JcfFocusFrame.spellbar;
    JcfCastingBarFrame_SetIcon(spellbar, 298591)
    spellbar:SetMinMaxValues(0,1)
    spellbar:SetValue(1)
    spellbar.Text:SetText("Moving")

    JcfUnitFramePortrait_Update(_G["JcfFocusFrame"])

    JcfTargetFrame_Update(JcfFocusFrame)
    JcfTargetFrame_CheckFaction(JcfFocusFrame)
end