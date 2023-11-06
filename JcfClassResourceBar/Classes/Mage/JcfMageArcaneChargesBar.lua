JcfMagePowerBar = {};

function JcfMagePowerBar:UpdatePower()
	local numCharges = UnitPower(self:GetUnit(), self.powerType, true);
	for i = 1, #self.classResourceButtonTable do
		self.classResourceButtonTable[i]:SetActive(i <= numCharges);
	end
end


JcfArcaneChargeMixin = { };

function JcfArcaneChargeMixin:Setup()
	self.isActive = nil;
	self:ResetVisuals();
	self:Show();
end

function JcfArcaneChargeMixin.OnRelease(framePool, self)
	self:ResetVisuals();
	FramePool_HideAndClearAnchors(framePool, self);
end

function JcfArcaneChargeMixin:SetActive(isActive)
	if self.isActive == isActive then
		return;
	end

	self.isActive = isActive;

	self:ResetVisuals();

	if self.isActive then
		self.activateAnim:Restart();
	else
		self.deactivateAnim:Restart();
	end
end

function JcfArcaneChargeMixin:ResetVisuals()
	self.activateAnim:Stop();
	self.deactivateAnim:Stop();

	for _, fxTexture in ipairs(self.fxTextures) do
		fxTexture:SetAlpha(0);
	end
end