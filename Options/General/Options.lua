function GetJCFOptions()
    return {
        type = "group",
        name = "Jax Classic Frames",
        handler = JaxClassicFrames,
        args = {
            player = GetJCFPlayerOptions(),
            target = GetJCFTargetOptions(),
            focus = GetJCFFocusOptions()
        },
    }
end

function GetJCFOptionsBlizzard()
    return {
        type = "group",
        name = "Jax Classic Frames",
        args = {
            g1 = {
                order = 1,
                type = "execute",
                name = "Open Jax Classic Frames Options",
                func = function()
                    HideUIPanel(SettingsPanel)
                    HideUIPanel(GameMenuFrame)
                    JaxClassicFrames:OpenOptions();
                end
            }
        },
    }
end