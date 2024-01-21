function GetJCFPlayerOptions()
    return {
        order = 1,
        name = "Player",
        handler = JCFPlayerSettings,
        type = "group",
        args = {
            playerEnable = {
                order = 1,
                width = "full",
                name = "Enable",
                desc = "Enable or disable",
                type = "toggle",
                get = "GetEnabled",
                set = "SetEnabled",
            },
            playerClassPortraitEnable = {
                order = 2,
                width = "full",
                name = "Class Icon Portrait",
                desc = "Enable or disable class icon portrait",
                disabled = function() return not JCFPlayerSettings:GetEnabled() end,
                type = "toggle",
                get = "GetClassPortraitEnabled",
                set = "SetClassPortraitEnabled",
            },
            playerClassColorHealthEnable = {
                disabled = function() return not JCFPlayerSettings:GetEnabled() end,
                order = 3,
                width = "full",
                name = "Class Color Health Bar",
                desc = "Enable or disable class color player health bar",
                type = "toggle",
                get = "GetClassColorHealthEnabled",
                set = "SetClassColorHealthEnabled",
            },
            playerEliteMode = {
                disabled = function() return not JCFPlayerSettings:GetEnabled() end,
                order = 3,
                name = "Elite Mode",
                desc = "Select an Elite Mode style",
                values = {
                    [0] = "None",
                    [1] = "Rare",
                    [2] = "Elite",
                    [3] = "Rare Elite"
                },
                type = "select",
                get = "GetEliteMode",
                set = "SetEliteMode",
            },
            playerCastBar = {
                name = "Player Castbar",
                handler = JCFPlayerSettings,
                type = "group",
                args = {
                    playerCastBarEnable = {
                        order = 4,
                        width = "full",
                        name = "Enable Classic Player Castbar",
                        desc = "Enable or disable classic player castbar",
                        type = "toggle",
                        get = "GetCastBarEnabled",
                        set = "SetCastBarEnabled",
                    },
                    playerCastBarScale = {
                        order = 5,
                        width = "1",
                        name = "Classic Player Castbar Scale",
                        desc = "Set castbar scale",
                        type = "range",
                        disabled = function() return not JCFPlayerSettings:GetCastBarEnabled() end,
                        get = "GetCastBarScale",
                        set = "SetCastBarScale",
                        softMax = 3
                    },
                }
            }
        },
    }
end