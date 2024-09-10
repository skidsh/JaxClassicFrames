
function JcfTextStatusBar_Initialize(self)
	self:RegisterEvent("CVAR_UPDATE");
	self.lockShow = 0;
end

function SetJcfTextStatusBarText(bar, text)
	if ( not bar or not text ) then
		return
	end
	bar.TextString = text;
end

function JcfTextStatusBar_OnEvent(self, event, ...)
	if ( event == "CVAR_UPDATE" ) then
		local cvar, value = ...;
		if ( self.cvar and cvar == self.cvarLabel ) then
			if ( self.TextString ) then
				if ( (value == "1" and self.textLockable) or self.forceShow ) then
					self.TextString:Show();
				elseif ( self.lockShow == 0 ) then
					self.TextString:Hide();
				end
			end
			JcfTextStatusBar_UpdateTextString(self);
		elseif ( cvar == "STATUS_TEXT_PERCENT" ) then
			JcfTextStatusBar_UpdateTextString(self);
		end
	end
end

function JcfTextStatusBar_UpdateTextString(JcfTextStatusBar)
	local textString = JcfTextStatusBar.TextString;
	if(textString) then
		local value = JcfTextStatusBar:GetValue();
		local valueMin, valueMax = JcfTextStatusBar:GetMinMaxValues();
		JcfTextStatusBar_UpdateTextStringWithValues(JcfTextStatusBar, textString, value, valueMin, valueMax);
	end
end

function JcfTextStatusBar_UpdateTextStringWithValues(statusFrame, textString, value, valueMin, valueMax)
	if ( ( tonumber(valueMax) ~= valueMax or valueMax > 0 ) and not ( statusFrame.pauseUpdates ) ) then
		statusFrame:Show();
		if ( value and valueMax > 0 and ( GetCVarBool("statusTextPercentage") or statusFrame.showPercentage ) and not statusFrame.showNumeric) then
			if ( value == 0 and statusFrame.zeroText ) then
				textString:SetText(statusFrame.zeroText);
				statusFrame.isZero = 1;
				textString:Show();
				return;
			end
			value = tostring(math.ceil((value / valueMax) * 100)) .. "%";
			if ( statusFrame.prefix and (statusFrame.alwaysPrefix or not (statusFrame.cvar and GetCVar(statusFrame.cvar) == "1" and statusFrame.textLockable) ) ) then
				textString:SetText(statusFrame.prefix .. " " .. value);
			else
				textString:SetText(value);
			end
		elseif ( value == 0 and statusFrame.zeroText ) then
			textString:SetText(statusFrame.zeroText);
			statusFrame.isZero = 1;
			textString:Show();
			return;
		else
			statusFrame.isZero = nil;
			if ( statusFrame.capNumericDisplay ) then
				value = JcfTextStatusBar_CapDisplayOfNumericValue(value);
				valueMax = JcfTextStatusBar_CapDisplayOfNumericValue(valueMax);
			end
			if ( statusFrame.prefix and (statusFrame.alwaysPrefix or not (statusFrame.cvar and GetCVar(statusFrame.cvar) == "1" and statusFrame.textLockable) ) ) then
				textString:SetText(statusFrame.prefix.." "..value.." / "..valueMax);
			else
				textString:SetText(value.." / "..valueMax);
			end
		end
		
		if ( (statusFrame.cvar and GetCVar(statusFrame.cvar) == "1" and statusFrame.textLockable) or statusFrame.forceShow ) then
			textString:Show();
		elseif ( statusFrame.lockShow > 0 and (not statusFrame.forceHideText) ) then
			textString:Show();
		else
			textString:Hide();
		end
	else
		textString:Hide();
		textString:SetText("");
		if ( not statusFrame.alwaysShow ) then
			statusFrame:Hide();
		else
			statusFrame:SetValue(0);
		end
	end
end

function JcfTextStatusBar_CapDisplayOfNumericValue(value)
	local strLen = strlen(value);
	local retString = value;
	if ( strLen > 8 ) then
		retString = string.sub(value, 1, -7)..SECOND_NUMBER_CAP;
	elseif ( strLen > 5 ) then
		retString = string.sub(value, 1, -4)..FIRST_NUMBER_CAP;
	end
	return retString;
end

function JcfTextStatusBar_OnValueChanged(self)
	JcfTextStatusBar_UpdateTextString(self);
end

function SetJcfTextStatusBarTextPrefix(bar, prefix)
	if ( bar and bar.TextString ) then
		bar.prefix = prefix;
	end
end

function SetJcfTextStatusBarTextZeroText(bar, zeroText)
	if ( bar and bar.TextString ) then
		bar.zeroText = zeroText;
	end
end

function ShowJcfTextStatusBarText(bar)
	if ( bar and bar.TextString ) then
		if ( not bar.lockShow ) then
			bar.lockShow = 0;
		end
		if ( not bar.forceHideText ) then
			bar.TextString:Show();
		end
		bar.lockShow = bar.lockShow + 1;
		JcfTextStatusBar_UpdateTextString(bar);
	end
end

function HideJcfTextStatusBarText(bar)
	if ( bar and bar.TextString ) then
		if ( not bar.lockShow ) then
			bar.lockShow = 0;
		end
		if ( bar.lockShow > 0 ) then
			bar.lockShow = bar.lockShow - 1;
		end
		if ( bar.lockShow > 0 or bar.isZero == 1) then
			bar.TextString:Show();
		elseif ( (bar.cvar and GetCVar(bar.cvar) == "1" and bar.textLockable) or bar.forceShow ) then
			bar.TextString:Show();
		else
			bar.TextString:Hide();
		end
		JcfTextStatusBar_UpdateTextString(bar);
	end
end