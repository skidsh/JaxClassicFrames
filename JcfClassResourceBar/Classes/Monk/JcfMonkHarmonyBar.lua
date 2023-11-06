local DefaulChiSpacing = 3; -- Default spacing between chi orbs
local TightChiSpacing = 2;	-- Spacing between chi orbs when num orb threshold is reached
local TightChiSpacingThreshold = 6;	-- Threshold of chi orb counts to start using tight spacing

JcfMonkPowerBar = {};

function JcfMonkPowerBar:UpdatePower()
	local numChi = UnitPower(self:GetUnit(), Enum.PowerType.Chi);
	for i = 1, #self.classResourceButtonTable do
		self.classResourceButtonTable[i]:SetActive(i <= numChi);
	end
end

function JcfMonkPowerBar:UpdateMaxPower()
	local maxPoints = UnitPowerMax(self:GetUnit(), self.powerType);
	if maxPoints >= TightChiSpacingThreshold then
		self.spacing = TightChiSpacing;
	else
		self.spacing = DefaulChiSpacing;
	end
	JcfClassResourceBarMixin.UpdateMaxPower(self);
end


JcfMonkLightEnergyMixin = {};

function JcfMonkLightEnergyMixin:Setup()
	self.active = nil;
	self:ResetVisuals();
	self:Show();
end

function JcfMonkLightEnergyMixin.OnRelease(framePool, self)
	self:ResetVisuals();
	FramePool_HideAndClearAnchors(framePool, self);
end

function JcfMonkLightEnergyMixin:SetActive(active)
	if self.active == active then
		return;
	end

	self.active = active;

	self:ResetVisuals();

	if self.active then
		self.FB_Wind_FX:SetAlpha(1);
		self.activate:Restart();
	else
		self.Chi_BG:SetAlpha(1);
		self.deactivate:Restart();
	end
end

function JcfMonkLightEnergyMixin:ResetVisuals()
	self.activate:Stop();
	self.deactivate:Stop();

	self.Chi_Icon:SetAlpha(0);
	self.Chi_Icon:SetAlpha(0);
	self.Chi_BG_Active:SetAlpha(0);

	if self.fxTextures then
		for _, fxTexture in ipairs(self.fxTextures) do
			fxTexture:SetAlpha(0);
		end
	end
end