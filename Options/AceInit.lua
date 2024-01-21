JaxClassicFrames = LibStub("AceAddon-3.0"):NewAddon("JaxClassicFrames", "AceConsole-3.0")
local options = GetJCFOptions();
local optionsBlizzards = GetJCFOptionsBlizzard();

function JaxClassicFrames:OnInitialize()
	self.db = LibStub("AceDB-3.0"):New("JaxClassicFramesDB", JaxClassicFramesDBDefaults, true)

	LibStub("AceConfig-3.0"):RegisterOptionsTable("JaxClassicFrames", options)
	LibStub("AceConfig-3.0"):RegisterOptionsTable("JaxClassicFramesBlizzards", optionsBlizzards)
	self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("JaxClassicFramesBlizzards", "Jax Classic Frames")
	self:RegisterChatCommand("jcf", "OpenOptions")
	self:RegisterChatCommand("jaxclassicframes", "OpenOptions")
    JCFPlayerSettings:RebuildFrames()
    JCFTargetSettings:RebuildFrames()
    JCFFocusSettings:RebuildFrames()
end

function JaxClassicFrames:OpenOptions(msg)
    LibStub("AceConfigDialog-3.0"):Open("JaxClassicFrames", JcfOptions.Options)
    JcfOptions.Options.frame:Show()
    JcfOptions:Show()
end

function JaxClassicFrames:IsFrameDisabled(frame)
    return JaxClassicFrames and
        JaxClassicFrames.DisableFrames and
        JaxClassicFrames.DisableFrames[frame:GetName()]
end