function JaxClassicFrames:GetEnabled()
    return self.db.profile.enabled
end
function JaxClassicFrames:SetEnabled(_, value)
    self.db.profile.enabled = value
end