function JcfUIParent_UpdateTopFramePositions()
	local topOffset = 0;
	local yOffset = 0;
	local xOffset = -180;

	if JcfPlayerFrame and not JcfPlayerFrame:IsUserPlaced() and not JcfPlayerFrame_IsAnimatedOut(JcfPlayerFrame) then
		JcfPlayerFrame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", -19, -4 - topOffset)
	end

	if JcfTargetFrame and not JcfTargetFrame:IsUserPlaced() then
		JcfTargetFrame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 250, -4 - topOffset);
	end
end

function JcfRefreshBuffs(frame, unit, numBuffs, suffix, checkCVar)
	local frameName = frame:GetName();

	frame.hasDispellable = nil;

	numBuffs = numBuffs or MAX_PARTY_BUFFS;
	suffix = suffix or "Buff";

	local unitStatus, statusColor;
	local debuffTotal = 0;
	local name, icon, count, debuffType, duration, expirationTime;

	local filter;
	if ( checkCVar and SHOW_CASTABLE_BUFFS == "1" and UnitCanAssist("player", unit) ) then
		filter = "RAID";
	end

	for i=1, numBuffs do
		name, icon, count, debuffType, duration, expirationTime = UnitBuff(unit, i, filter);
		local buffName = frameName..suffix..i;
		if ( icon ) then
			-- if we have an icon to show then proceed with setting up the aura

			-- set the icon
			local buffIcon = _G[buffName].Icon;
			buffIcon:SetTexture(icon);

			-- setup the cooldown
			--[[local coolDown = _G[buffName.."Cooldown"];
			if ( coolDown ) then
				CooldownFrame_Set(coolDown, expirationTime - duration, duration, true);
			end]]

			-- show the aura
			_G[buffName]:Show();
		else
			-- no icon, hide the aura
			_G[buffName]:Hide();
		end
	end
end
