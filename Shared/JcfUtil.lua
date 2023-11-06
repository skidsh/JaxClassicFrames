function JcfUtil_AlwaysHide(frame)
    frame:SetAlpha(0);

    hooksecurefunc(frame, "Show", function()
        frame:SetAlpha(0);
    end)
    hooksecurefunc(frame, "SetAlpha", function(f, a)
        if a > 0 then
            frame:SetAlpha(0);
        end
    end)

    if (frame.PlayInterruptAnims) then
        hooksecurefunc(frame, "PlayInterruptAnims", function(f, a)
            frame:ApplyAlpha(0);
            frame:StopAnims();
        end)
    end
    if (frame.PlayFinishAnim) then
        hooksecurefunc(frame, "PlayFinishAnim", function(f, a)
            frame:ApplyAlpha(0);
            frame:StopAnims();
        end)
    end
    if (frame.PlayFadeAnim) then
        hooksecurefunc(frame, "PlayFadeAnim", function(f, a)
            frame:ApplyAlpha(0);
            frame:StopAnims();
        end)
    end
end

function JcfUtil_AlwaysSync(parent, child, xOffset, yOffset)
    child:SetUserPlaced(true);
    child:ClearAllPoints();
    child:SetPoint("TOPLEFT", parent, "TOPLEFT", xOffset, yOffset);
    child:SetScale(parent:GetScale());
    hooksecurefunc(parent, "SetPoint", function(frame, ...)
        child:ClearAllPoints();
        child:SetPoint("TOPLEFT", parent, "TOPLEFT", xOffset, yOffset);
    end)
    hooksecurefunc(parent, "SetScale", function(frame, s)
        child:SetScale(s);
    end)
    hooksecurefunc(parent, "HighlightSystem", function (frame)
        child.isInEditMode = true;
        if child:GetName() == "JcfCastingBarFrame" then
            child:SetAlpha(1)
        end
        child:SetFrameStrata("BACKGROUND")
    end)
    hooksecurefunc(parent, "ClearHighlight", function (frame)
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

local framesToSyncAndHide =
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

for newFrameName, frameInfo in pairs(framesToSyncAndHide) do
    JcfUtil_AlwaysHide(_G[frameInfo["name"]]);
    JcfUtil_AlwaysSync(_G[frameInfo["name"]], _G[newFrameName], frameInfo["xOffset"], frameInfo["yOffset"]);
    _G[newFrameName]:EnableMouse(false);
end

local bgWatcher = CreateFrame("Frame", "bgWatcher")
local function bgwatch(self)
    if (IsAddOnLoaded("BigDebuffs")) then
        if (BigDebuffs) then
            if (BigDebuffs.UnitFrames) then
                for newFrameName, frameInfo in pairs(framesToSyncAndHide) do
                    if _G[newFrameName].unit then
                        local frame = BigDebuffs.UnitFrames[_G[newFrameName].unit]
                        if (frame) then
                            if (_G[newFrameName].portrait) then
                                if (frame:IsShown()) then
                                    SetPortraitToTexture(_G[newFrameName].portrait, frame.icon:GetTexture())
                                    if (_G[newFrameName.."PortraitCooldown"]) then
                                        local start, currMS = frame.cooldown:GetCooldownTimes();
                                        _G[newFrameName.."PortraitCooldown"]:SetCooldown(start/1000, currMS/1000)
                                    end
                                else
                                    SetPortraitTexture(_G[newFrameName].portrait, _G[newFrameName].unit)
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
