local DefaultMaxPoints = 5;	-- Default number of max points for normal layout handling
local DefaultLeftPadding = 0;	-- Padding to use while at or below DefaultMaxPoints
local LeftPaddingPerPointOverDefault = 0;	-- Padding to add for each max point above DefaultMaxPoints

JcfRogueComboPointBarMixin = {};
function JcfRogueComboPointBarMixin:ShouldShowBar()
	local unit = self:GetUnit();
	local _, myclass = UnitClass(unit);
	local cvarComboLocation = GetCVar("comboPointLocation") ~= "1";
	local class = myclass == "ROGUE";
	return cvarComboLocation and class;
end
function JcfRogueComboPointBarMixin:UpdatePower()
	local unit = self:GetUnit();
	local comboPoints = UnitPower(unit, self.powerType);
	local chargedPowerPoints = GetUnitChargedPowerPoints(unit);
	for i = 1, #self.classResourceButtonTable do
		local isFull = i <= comboPoints;
		local isCharged = chargedPowerPoints and tContains(chargedPowerPoints, i) or false;

		self.classResourceButtonTable[i]:Update(isFull, isCharged);
	end
end

function JcfRogueComboPointBarMixin:UpdateChargedPowerPoints()
	self:UpdatePower();
end

function JcfRogueComboPointBarMixin:UpdateMaxPower()
	local maxPoints = UnitPowerMax(self:GetUnit(), self.powerType);
	if maxPoints <= DefaultMaxPoints then
		self.leftPadding = DefaultLeftPadding;
		self.customScale = 1.0;
	else
		local pointsOverDefault = maxPoints - DefaultMaxPoints;
		self.leftPadding = pointsOverDefault * LeftPaddingPerPointOverDefault;
		self.customScale = 1.0 - (pointsOverDefault * 0.15);
	end

	JcfClassResourceBarMixin.UpdateMaxPower(self);
end


JcfRogueComboPointMixin = {};

function JcfRogueComboPointMixin:Setup()
	self.isFull = nil;
	self.isCharged = nil;
	self:ResetVisuals();
	self:Show();
end

function JcfRogueComboPointMixin.OnRelease(framePool, self)
	self:ResetVisuals();
	FramePool_HideAndClearAnchors(framePool, self);
end

function JcfRogueComboPointMixin:Update(isFull, isCharged)
	if self.isFull == isFull and self.isCharged == isCharged then
		return;
	end

	local wasFull = self.isFull ~= nil and self.isFull or false;
	local wasCharged = self.isCharged ~= nil and self.isCharged or false;
	self.isFull = isFull;
	self.isCharged = isCharged;

	self:ResetVisuals();

	local transitionAnim = JcfRogueComboPointTransitions.GetTransitionAnim(wasCharged, wasFull, isCharged, isFull);
	if transitionAnim then
		self[transitionAnim]:Restart();
	end
end

function JcfRogueComboPointMixin:ResetVisuals()
	for _, transitionAnim in ipairs(self.transitionAnims) do
		transitionAnim:Stop();
	end

	for _, fxTexture in ipairs(self.fxTextures) do
		fxTexture:SetAlpha(0);
	end
end


JcfRogueComboPointTransitions = {};

function JcfRogueComboPointTransitions.Init()
	-- Using an Init func allows us to use these local named bools and make this big thing more readable
	local uncharged, charged = false, true;
	local empty, full = false, true;
	JcfRogueComboPointTransitions.transitions = {
		{ from = {uncharged, empty}, to = {uncharged, empty}, anim = "unchargedEmpty" },

		{ from = {uncharged, empty}, to = {uncharged, full}, anim = "unchargedEmptyToUnchargedFull" },
		{ from = {uncharged, empty}, to = {charged, full}, anim = "unchargedEmptyToChargedFull" },
		{ from = {uncharged, empty}, to = {charged, empty}, anim = "unchargedEmptyToChargedEmpty" },

		{ from = {charged, empty}, to = {charged, full}, anim = "chargedEmptyToChargedFull" },
		{ from = {charged, empty}, to = {uncharged, full}, anim = "chargedEmptyToUnchargedFull" },
		{ from = {charged, empty}, to = {uncharged, empty}, anim = "chargedEmptyToUnchargedEmpty" },

		{ from = {uncharged, full}, to = {uncharged, empty}, anim = "unchargedFullToUnchargedEmpty" },
		{ from = {uncharged, full}, to = {charged, full}, anim = "unchargedFullToChargedFull" },
		{ from = {uncharged, full}, to = {charged, empty}, anim = "unchargedFullToChargedEmpty" },

		{ from = {charged, full}, to = {charged, empty}, anim = "chargedFullToChargedEmpty" },
		{ from = {charged, full}, to = {uncharged, empty}, anim = "chargedFullToUnchargedEmpty" },
		{ from = {charged, full}, to = {uncharged, full}, anim = "chargedFullToUnchargedFull" },
	};
end

function JcfRogueComboPointTransitions.GetTransitionAnim(fromIsCharged, fromIsFull, toIsCharged, toIsFull)
	if not JcfRogueComboPointTransitions.transitions then
		JcfRogueComboPointTransitions.Init();
	end

	local function stateMatches(state, isCharged, isFull)
		return state[1] == isCharged and state[2] == isFull;
	end
	for _, transition in ipairs(JcfRogueComboPointTransitions.transitions) do
		if stateMatches(transition.from, fromIsCharged, fromIsFull) and stateMatches(transition.to, toIsCharged, toIsFull) then
			return transition.anim;
		end
	end
	return nil;
end