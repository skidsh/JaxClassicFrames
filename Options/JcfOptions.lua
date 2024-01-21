local JCF_HEADER = "Jax Classic Frames Options"
JcfOptionsPanelMixin = {}
function JcfOptionsPanelMixin:OnLoad()
	ButtonFrameTemplate_HidePortrait(self)

	self.isLoggingPaused = false;
	self.loadTime = GetTime();
	self.showingArguments = true;


	self.idCounter = CreateCounter();
	self.frameCounter = 0;
	local timer = CreateFrame("FRAME");
	timer:SetScript("OnUpdate", function(o, elapsed)
		self.frameCounter = self.frameCounter + 1;
	end);
	self:RegisterAllEvents();

	self.TitleBar:Init(self);
	self.ResizeButton:Init(self, 600, 400);
	self:SetTitle(JCF_HEADER);
    
    self.Options = LibStub("AceGUI-3.0"):Create("SimpleGroup")
    self.Options.frame:ClearAllPoints()
    self.Options.frame:SetAllPoints(self.Inset)

    self:Hide();

    self:SetScript("OnKeyDown", function(_,key)
        if (self:IsShown() and key == "ESCAPE") then
            self:Hide()
        end
    end)
    self:SetPropagateKeyboardInput(true)

	self.Header.Text:SetText("|cFF99CC01 ".."Author".."|r Jax\n".."|cFF99CC01".." Version".."|r "..C_AddOns.GetAddOnMetadata("JaxClassicFrames", "Version"))
	self.Footer.Text:SetText("")
end

function JcfOptionsPanelMixin:OnShow()
	self:MoveToNewWindow(JCF_HEADER, 930, 300, 930, 300);

end

function JcfOptionsPanelMixin:OnHide()
    self.Options.frame:Hide();
end

function JcfOptionsPanelMixin:MoveToNewWindow(title, width, height, minWidth, minHeight)
	local window = CreateWindow();
	if not window then
		return false;
	end

	-- Setup window visual
	window:SetTitle(title);

	if width and height then
		window:SetSize(width, height);
	end

	if minWidth and minHeight then
		window:SetMinSize(minWidth, minHeight);
	end

	-- Move to window
	self:SetWindow(window);
	self:SetAllPoints(window);

	-- Setup various callbacks to redirect actions to affect window
	self.onCloseCallback = function(closeButton)
		local parent = closeButton:GetParent();
		local window = parent and parent:GetWindow();
		if window then
			window:Close();
		end

		return true;
	end

	self.onDragStartCallback = function()
		window:StartMoving();
		return false;
	end

	self.onDragStopCallback = function()
		window:StopMovingOrSizing();
		return false;
	end

	self.onResizeStartCallback = function()
		window:StartSizing();
		return false;
	end

	self.onResizeStopCallback = function()
		window:StopMovingOrSizing();
		return false;
	end

	return true;
end

function JcfOptionsPanelMixin:MoveToMainWindow()
	local window = self:GetWindow();
	if not window then
		return;
	end

	self.onCloseCallback = nil;
	self.onDragStartCallback = nil;
	self.onDragStopCallback = nil;
	self.onResizeStartCallback = nil;
	self.onResizeStopCallback = nil;
	self:SetWindow(nil);
	window:Close();
end