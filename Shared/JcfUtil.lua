function JcfUtil_AlwaysHide(frame)
    frame:SetAlpha(0);

    hooksecurefunc(frame, "Show", function()
        if JaxClassicFrames and JaxClassicFrames:IsFrameDisabled(frame) then
            return
        end
        frame:SetAlpha(0);
    end)
    hooksecurefunc(frame, "SetAlpha", function(f, a)
        if JaxClassicFrames and JaxClassicFrames:IsFrameDisabled(frame) then
            return
        end
        if a > 0 then
            frame:SetAlpha(0);
        end
    end)

    if (frame.PlayInterruptAnims) then
        hooksecurefunc(frame, "PlayInterruptAnims", function(f, a)
            if JaxClassicFrames and JaxClassicFrames:IsFrameDisabled(frame) then
                return
            end
            frame:ApplyAlpha(0);
            frame:StopAnims();
        end)
    end
    if (frame.PlayFinishAnim) then
        hooksecurefunc(frame, "PlayFinishAnim", function(f, a)
            if JaxClassicFrames and JaxClassicFrames:IsFrameDisabled(frame) then
                return
            end
            frame:ApplyAlpha(0);
            frame:StopAnims();
        end)
    end
    if (frame.PlayFadeAnim) then
        hooksecurefunc(frame, "PlayFadeAnim", function(f, a)
            if JaxClassicFrames and JaxClassicFrames:IsFrameDisabled(frame) then
                return
            end
            frame:ApplyAlpha(0);
            frame:StopAnims();
        end)
    end
end

function JcfUtil_AlwaysSync(parent, child, xOffset, yOffset)
    child:SetUserPlaced(true);
    child:ClearAllPoints();
    child:SetPoint("CENTER", parent, "CENTER", xOffset, yOffset);
    child:SetScale(parent:GetScale());

    hooksecurefunc(parent, "SetPoint", function(frame, ...)
        if JaxClassicFrames and JaxClassicFrames:IsFrameDisabled(child) then
            return
        end
        child:ClearAllPoints();
        child:SetPoint("CENTER", parent, "CENTER", xOffset, yOffset);
    end)
    hooksecurefunc(parent, "SetScale", function(frame, s)
        if (child:GetName() == "JcfCastingBarFrame") then
            s = s * JaxClassicFrames.db.profile.player.castBarScale;
        end
        child:SetScale(s);
    end)
    hooksecurefunc(parent, "HighlightSystem", function (frame)
        if JaxClassicFrames and JaxClassicFrames:IsFrameDisabled(child) then
            return
        end
        child.isInEditMode = true;
        if child:GetName() == "JcfCastingBarFrame" then
            child:SetAlpha(1)
        end
        child:SetFrameStrata("BACKGROUND")
    end)
    hooksecurefunc(parent, "ClearHighlight", function (frame)
        if JaxClassicFrames and JaxClassicFrames:IsFrameDisabled(child) then
            return
        end
        child.isInEditMode = false;
        if child:GetName() == "JcfCastingBarFrame" then
            child:SetAlpha(0)
            child:SetFrameStrata("HIGH")
        else
            child:SetFrameStrata("LOW")
        end
    end)
end

function JcfAttachBigDebuffs(frame)
    if (frame.portrait and frame.unit) then
        local frameName = "BigDebuffs" .. frame.unit:lower() .. "UnitFrame"
        print(frameName)
        print(_G[frameName])
        hooksecurefunc(_G[frameName].icon, "SetTexture", function(f, texture)
            frame.portrait:SetTexture(texture)
        end)
    end
end

JcfFramesToSyncAndHide =
{
    ["JcfPlayerFrame"] =
        {
            ["name"] = "PlayerFrame",
            ["xOffset"] = -20,
            ["yOffset"] = 2,
        },
    ["JcfPetFrame"] =
        {
            ["name"] = "PetFrame",
            ["xOffset"] = 0,
            ["yOffset"] = 0,
        },
    ["JcfTargetFrame"] =
        {
            ["name"] = "TargetFrame",
            ["xOffset"] = 20,
            ["yOffset"] = 0,
        },
    ["JcfFocusFrame"] =
        {
            ["name"] = "FocusFrame",
            ["xOffset"] = 22,
            ["yOffset"] = 0,
        },
    ["JcfCastingBarFrame"] =
        {
            ["name"] = "PlayerCastingBarFrame",
            ["xOffset"] = 5,
            ["yOffset"] = -6,
        },
}

for newFrameName, frameInfo in pairs(JcfFramesToSyncAndHide) do
    JcfUtil_AlwaysHide(_G[frameInfo["name"]]);
    JcfUtil_AlwaysSync(_G[frameInfo["name"]], _G[newFrameName], frameInfo["xOffset"], frameInfo["yOffset"]);
    _G[newFrameName]:EnableMouse(false);
end

if (ComboFrame ~= nil) then
    local point, relativeTo, relativePoint, xOfs, yOfs = ComboFrame:GetPoint()
    ComboFrame:ClearAllPoints();
    ComboFrame:SetPoint(point, relativeTo, relativePoint, xOfs+20, yOfs);
    ComboFrame:SetScale(TargetFrame:GetScale())
    hooksecurefunc(TargetFrame, "SetScale", function(frame, s)
        ComboFrame:SetScale(s);
    end)
end

local bgWatcher = CreateFrame("Frame", "bgWatcher")
local function bgwatch(self)
    if (C_AddOns.IsAddOnLoaded("BigDebuffs")) then
        if (BigDebuffs) then
            if (BigDebuffs.UnitFrames) then
                for newFrameName, frameInfo in pairs(JcfFramesToSyncAndHide) do
                    if _G[newFrameName].unit then
                        local frame = BigDebuffs.UnitFrames[_G[newFrameName].unit]
                        if (frame) then
                            if (_G[newFrameName].portrait) then
                                if (frame:IsShown()) then
                                    _G[newFrameName].portrait:SetTexCoord(0,1,0,1)
                                    SetPortraitToTexture(_G[newFrameName].portrait, frame.icon:GetTexture())
                                    if (_G[newFrameName.."PortraitCooldown"]) then
                                        local start, currMS = frame.cooldown:GetCooldownTimes();
                                        _G[newFrameName.."PortraitCooldown"]:SetCooldown(start/1000, currMS/1000)
                                    end
                                else
                                    JcfUnitFramePortrait_Update(_G[newFrameName])
                                    if (_G[newFrameName.."PortraitCooldown"]) then
                                        _G[newFrameName.."PortraitCooldown"]:SetCooldown(0, 0)
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end
bgWatcher:SetScript("OnUpdate", bgwatch)