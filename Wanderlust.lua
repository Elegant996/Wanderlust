--[[Local horror]]
local Scale = 1
local r, g, b, a = 0, 0, 0, 1
local BGThickness = 2
local OffsetX, OffsetY = -10, -10
local Point, AnchorPoint = "TOPRIGHT", "TOPRIGHT"
local trackingsize = 14
local trackingfontflag = "THINOUTLINE"
local trackingowncolor = {0.41, 0.8, 0.94}

--[[ Loading ]]
Wanderlust = CreateFrame("Frame", "Wanderlust", UIParent, BackdropTemplateMixin and "BackdropTemplate")
Wanderlust:RegisterEvent("ADDON_LOADED")
Wanderlust:SetScript("OnEvent", function(self, event, addon)
    if(addon~="Wanderlust") then return end

    
    --[[ Carbonite hint ]]
    local total = 0
    local SetTextureTrick = function(self, elapsed)
        total = total + elapsed
        if(total > 2) then
            Minimap:SetMaskTexture("Interface\\Buttons\\WHITE8X8")
            Wanderlust:SetScript("OnUpdate", nil)
        end
    end
    Wanderlust:SetScript("OnUpdate", SetTextureTrick)
    
    --[[ Location and scale ]]
    Minimap:ClearAllPoints()
	Minimap:SetScale(Scale)
    Minimap:SetPoint(Point, UIParent, AnchorPoint, OffsetX / Scale, OffsetY / Scale)
    MinimapCluster:EnableMouse(false)

    --[[ Background ]]
	Mixin(Minimap, BackdropTemplateMixin or {})
    Minimap:SetBackdrop({bgFile = "Interface\\ChatFrame\\ChatFrameBackground", insets = {
        top = -BGThickness / Scale,
        left = -BGThickness / Scale,
        bottom = -BGThickness / Scale,
        right = -BGThickness / Scale
    }})
    Minimap:SetBackdropColor(r, g, b, a)

    --[[ Click func ]]
    
    local oldOnClick = Minimap:GetScript("OnMouseUp")
    Minimap:SetScript("OnMouseUp", function(self,click)
	    if(click=="RightButton") then
		    ToggleDropDownMenu(1, nil, MiniMapTrackingDropDown, "cursor", 0, 0)
	    elseif(click=="MiddleButton") then
		    if (not CalendarFrame) then LoadAddOn("Blizzard_Calendar") end Calendar_Toggle() 
	    else 
		    oldOnClick(self)
	    end
    end)

    --[[ Tracking ]]
	MiniMapTracking:ClearAllPoints()
	MiniMapTracking:SetParent(Minimap)
	MiniMapTracking:SetPoint('TOPLEFT', 0, -2)
	MiniMapTracking:SetAlpha(0)
	MiniMapTrackingBackground:Hide()
	MiniMapTrackingButtonBorder:SetTexture(nil)
	MiniMapTrackingButton:SetHighlightTexture(nil)
	MiniMapTrackingIconOverlay:SetTexture(nil)
	MiniMapTrackingIcon:SetTexCoord(0.065, 0.935, 0.065, 0.935)
	MiniMapTrackingIcon:SetWidth(20)
	MiniMapTrackingIcon:SetHeight(20)
	
    Wanderlust.tracking = CreateFrame("Frame", nil, Minimap, BackdropTemplateMixin and "BackdropTemplate")
    Wanderlust.tracking:SetPoint("BOTTOM", 0, 20)
    
    local t = Wanderlust.tracking:CreateFontString(nil, "OVERLAY")
    t:SetFont("Fonts\\FRIZQT__.ttf", trackingsize, trackingfontflag)
    t:SetPoint("RIGHT")
    t:SetPoint("LEFT")
    
    t:SetTextColor(unpack(trackingowncolor))
    
    local function UpdateTrackingText()
        for i = 1, GetNumTrackingTypes() do
            local name, texture, active = GetTrackingInfo(i)
            if(active) then
                t:SetText(name)
                Wanderlust.tracking:SetWidth(t:GetStringWidth()>140 and 140 or t:GetStringWidth())
                Wanderlust.tracking:SetHeight(t:GetStringHeight())
                return
            end
        end
        t:SetText("")
    end

--[[ Instance Difficulty - should work now finally]]

local _, class = UnitClass("player")
local color = RAID_CLASS_COLORS[class]
local id = CreateFrame("Frame", nil, UIParent, BackdropTemplateMixin and "BackdropTemplate")
id:SetPoint("TOP", Minimap, "TOP")
id:RegisterEvent("PLAYER_ENTERING_WORLD")
id:RegisterEvent("PLAYER_DIFFICULTY_CHANGED")
id:RegisterEvent("GROUP_ROSTER_UPDATE")
id:RegisterEvent("RAID_ROSTER_UPDATE")

local idtext = id:CreateFontString(nil, "OVERLAY")
idtext:SetPoint("TOP", Minimap, "TOP", 0, -4)
idtext:SetFont("Fonts\\FRIZQT__.ttf", 14, "THINOUTLINE")
idtext:SetTextColor(color.r, color.g, color.b)

function indiff()
	local inInstance, _ = IsInInstance()
	local _, _, difficultyID = GetInstanceInfo()
	local numGroupMembers = GetNumGroupMembers()
	local cmLevel = C_ChallengeMode.GetActiveKeystoneInfo()
	
	if inInstance then
		if difficultyID == 1 then
			idtext:SetText("5")
		elseif difficultyID == 2 then
			idtext:SetText("5H")
		elseif difficultyID == 3 then
			idtext:SetText("10")
		elseif difficultyID == 4 then
			idtext:SetText("25")
		elseif difficultyID == 5 then
			idtext:SetText("10H")
		elseif difficultyID == 6 then
			idtext:SetText("25H") 
		elseif difficultyID == 7 then
			idtext:SetText("LFR") 
		elseif difficultyID == 8 then
			idtext:SetText("5M+") 
		elseif difficultyID == 9 then
			idtext:SetText("40")
		elseif difficultyID == 11 then
			idtext:SetText("3H")
		elseif difficultyID == 12 then
			idtext:SetText("3")
		elseif difficultyID == 14 then
			idtext:SetText((numGroupMembers > 10 and numGroupMembers or 10).."N")
		elseif difficultyID == 15 then
			idtext:SetText((numGroupMembers > 10 and numGroupMembers or 10).."H")
		elseif difficultyID == 16 then
			idtext:SetText("20M")
		elseif difficultyID == 17 then
			idtext:SetText((numGroupMembers > 10 and numGroupMembers or 10).."LFR")
		elseif difficultyID == 23 then
			idtext:SetText("5M")
		elseif difficultyID == 24 then
			idtext:SetText("5TW")
		elseif difficultyID == 33 then
			idtext:SetText((numGroupMembers > 10 and numGroupMembers or 10).."TW")
		elseif difficultyID == 34 then
			idtext:SetText("PvP")
		end
	end
	if not inInstance then
		idtext:SetText("") 
	end
end
id:SetScript("OnEvent", function() indiff() end)

    Minimap:SetScript("OnEnter", function()
        UpdateTrackingText()
		MiniMapTracking:SetAlpha(1)
        Wanderlust.tracking:SetAlpha(1)
    end)
	
		
	MiniMapTrackingButton:SetScript("OnEnter",function()
		UpdateTrackingText()
		MiniMapTracking:SetAlpha(1)
        Wanderlust.tracking:SetAlpha(1)
	end)

    Minimap:SetScript("OnLeave", function()
        MiniMapTracking:SetAlpha(0)
        Wanderlust.tracking:SetAlpha(0)
    end)
	
	MiniMapTrackingButton:SetScript("OnLeave", function()
        MiniMapTracking:SetAlpha(0)
        Wanderlust.tracking:SetAlpha(0)
    end)
	
	MiniMapTrackingButton:SetScript("OnMouseUp", function(self,click)
	    if(click=="RightButton") then
		    ToggleDropDownMenu(1, nil, MiniMapTrackingDropDown, "cursor", 0, 0)
		elseif(click=="MiddleButton") then
			if (not CalendarFrame) then LoadAddOn("Blizzard_Calendar") end Calendar_Toggle() 
		end
	end)


    Wanderlust.tracking.text = t
	
--[[ Clock ]]
if not IsAddOnLoaded("Blizzard_TimeManager") then
	LoadAddOn("Blizzard_TimeManager")
end
local clockFrame, clockTime = TimeManagerClockButton:GetRegions()
clockFrame:Hide()
clockTime:SetFont("Fonts\\FRIZQT__.ttf", 12, "THINOUTLINE")
clockTime:SetTextColor(1, 1, 1)
TimeManagerClockButton:ClearAllPoints()
TimeManagerClockButton:SetPoint("BOTTOM", Minimap, "BOTTOM", 0, -2)
TimeManagerClockButton:SetScript('OnShow', nil)
TimeManagerClockButton:Show()
TimeManagerClockButton:SetScript('OnClick', function(self, button)
	 if(button=="RightButton") then
		    ToggleDropDownMenu(1, nil, MiniMapTrackingDropDown, "cursor", 0, 0)
	 elseif(button == 'MiddleButton') then
		ToggleCalendar()
	else
		if(self.alarmFiring) then
			PlaySound('igMainMenuQuit')
			TimeManager_TurnOffAlarm()
		else
			ToggleTimeManager()
		end
	end
end)

    
--[[ Calendar ]]
local cal = CreateFrame("Frame", nil, Minimap, BackdropTemplateMixin and "BackdropTemplate")
GameTimeFrame:HookScript("OnShow", cal.Show)
GameTimeFrame:SetScript("OnEvent", function(self, event, addon)
	if C_Calendar.GetNumPendingInvites() ~= 0 then
		clockTime:SetTextColor(0, 1, 0)
	else
		clockTime:SetTextColor(1, 1, 1)
	end
end)

    self:UnregisterEvent(event)
end)

function GetMinimapShape() return "SQUARE" end

--[[ Hiding ugly things	]]
local dummy = function() end
local frames = {
    --"MiniMapVoiceChatFrame",
    "MiniMapWorldMapButton",
    "MinimapZoneTextButton",
    "MiniMapMailBorder",
    "MinimapBorderTop",
    "MiniMapInstanceDifficulty",
    "MinimapNorthTag",
    "MinimapZoomOut",
    "MinimapZoomIn",
    "MinimapBorder",
    "GameTimeFrame",
	"QueueStatusMinimapButtonBorder",
	"GuildInstanceDifficulty",
--    "Boss1TargetFrame",
--    "Boss2TargetFrame",
--    "Boss3TargetFrame",
--    "Boss4TargetFrame"
}
GameTimeFrame:SetAlpha(0)
GameTimeFrame:EnableMouse(false)
GameTimeCalendarInvitesTexture:SetParent("Minimap")

for i in pairs(frames) do
    _G[frames[i]]:Hide()
    _G[frames[i]].Show = dummy
end

--[[ Mousewheel zoom ]]
Minimap:EnableMouseWheel(true)
Minimap:SetScript("OnMouseWheel", function(_, zoom)
    if zoom > 0 then
        Minimap_ZoomIn()
    else
        Minimap_ZoomOut()
    end
end)

--[[ BG icon ]]
--QueueStatusMinimapButton:ClearAllPoints()
--QueueStatusMinimapButton:SetParent(Minimap)
--QueueStatusMinimapButton:SetPoint('TOPRIGHT', 2, -2)
--MiniMapBattlefieldBorder:SetTexture(nil)
--BattlegroundShine:Hide()

--[[ Random Group icon ]]
QueueStatusMinimapButton:ClearAllPoints()
QueueStatusMinimapButton:SetParent(Minimap)
QueueStatusMinimapButton:SetPoint('TOPRIGHT', 2, -2)
QueueStatusMinimapButton:SetHighlightTexture(nil)

--[[ Mail icon ]]
MiniMapMailFrame:ClearAllPoints()
MiniMapMailFrame:SetPoint("BOTTOMRIGHT", Minimap, "BOTTOMRIGHT", 6, -8)
MiniMapMailIcon:SetTexture("Interface\\AddOns\\Wanderlust\\mail")
