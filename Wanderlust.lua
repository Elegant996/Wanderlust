--[[Local horror]]
local Scale = 1
local r, g, b, a = 0, 0, 0, 1
local BGThickness = 2
local OffsetX, OffsetY = 10, -10
local Point, AnchorPoint = "TOPLEFT", "TOPLEFT"
local trackingsize = 14
local trackingfontflag = "THINOUTLINE"
local trackingowncolor = {0.41, 0.8, 0.94}

--[[ Loading ]]
Wanderlust = CreateFrame("Frame", "Wanderlust", UIParent)
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
	
    Wanderlust.tracking = CreateFrame("Frame", nil, Minimap)
    Wanderlust.tracking:SetPoint("BOTTOM", 0, 20)
    
    local t = Wanderlust.tracking:CreateFontString(nil, "OVERLAY")
    t:SetFont("Fonts\\FRIZQT__.ttf", trackingsize, trackingfontflag)
    t:SetPoint("RIGHT")
    t:SetPoint("LEFT")
    
    t:SetTextColor(unpack(trackingowncolor))
    
    local function UpdateTrackignText()
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
local id = CreateFrame("Frame", nil, UIParent)
id:SetPoint("TOP", Minimap, "TOP")
id:RegisterEvent("PLAYER_ENTERING_WORLD")
id:RegisterEvent("PLAYER_DIFFICULTY_CHANGED")

local idtext = id:CreateFontString(nil, "OVERLAY")
idtext:SetPoint("TOP", Minimap, "TOP", 0, -4)
idtext:SetFont("Fonts\\FRIZQT__.ttf", 14, "THINOUTLINE")
idtext:SetTextColor(color.r, color.g, color.b)

function indiff()
	local instance, instancetype = IsInInstance()
	local _, _, difficultyIndex, _, _, playerDifficulty, isDynamic = GetInstanceInfo()
	if instance and instancetype == "raid" then
		if isDynamic and difficultyIndex == 1 then
			if playerDifficulty == 0 then
				idtext:SetText("10") end
			if playerDifficulty == 1 then
				idtext:SetText("10H") end
			end
		if isDynamic and difficultyIndex == 2 then
			if playerDifficulty == 0 then
				idtext:SetText("25") end
			if playerDifficulty == 1 then
				idtext:SetText("25H") end
			end
		if not isDynamic then
			if difficultyIndex == 1 then
				idtext:SetText("10") end
			if difficultyIndex == 2 then
				idtext:SetText("25") end
			if difficultyIndex == 3 then
				idtext:SetText("10H") end
			if difficultyIndex == 4 then
				idtext:SetText("25H") end
			end
		end
	if not instance then
		idtext:SetText("") end
end
id:SetScript("OnEvent", function() indiff() end)

    Minimap:SetScript("OnEnter", function()
        UpdateTrackignText()
		MiniMapTracking:SetAlpha(1)
        Wanderlust.tracking:SetAlpha(1)
    end)
	
		
	MiniMapTrackingButton:SetScript("OnEnter",function()
		UpdateTrackignText()
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

local cal = CreateFrame("Frame", nil, Minimap)
GameTimeFrame:HookScript("OnShow", cal.Show)
GameTimeFrame:SetScript("OnEvent", function(self, event, addon)
	if CalendarGetNumPendingInvites() ~= 0 then
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
    "MiniMapVoiceChatFrame",
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
    "MiniMapBattlefieldBorder",
	"MiniMapLFGFrameBorder",
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
MiniMapBattlefieldFrame:ClearAllPoints()
MiniMapBattlefieldFrame:SetParent(Minimap)
MiniMapBattlefieldFrame:SetPoint('TOPRIGHT', 2, -2)
MiniMapBattlefieldBorder:SetTexture(nil)
BattlegroundShine:Hide()

--[[ Random Group icon ]]
MiniMapLFGFrame:ClearAllPoints()
MiniMapLFGFrame:SetParent(Minimap)
MiniMapLFGFrame:SetPoint('TOPRIGHT', 2, -2)
MiniMapLFGFrame:SetHighlightTexture(nil)

--[[ Mail icon ]]
MiniMapMailFrame:ClearAllPoints()
MiniMapMailFrame:SetPoint("BOTTOMRIGHT", Minimap, "BOTTOMRIGHT", 6, -8)
MiniMapMailIcon:SetTexture("Interface\\AddOns\\Wanderlust\\mail")
