local RogueComboFix = CreateFrame("Frame");
RogueComboFix:RegisterEvent("UNIT_POWER_FREQUENT")

RogueComboFix:SetScript("OnEvent", function(self, event, unit, resource)
    if (unit == "player") then
        if (ComboPointPlayerFrame and resource == "COMBO_POINTS") then
            if (GetCVar("comboPointLocation") == "1") then
                ComboPointPlayerFrame:Hide()
            else
                ComboPointPlayerFrame:Show()
            end
        end
    end
end)