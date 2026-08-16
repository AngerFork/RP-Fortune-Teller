local addon = ...

-------------
-- Main Interface Window Builder
-------------
local FortuneAdd = {};
FortuneAdd.panel = CreateFrame( "Frame", "FortuneAdd", UIParent );	-- Create the Panel
FortuneAdd.panel.name = "RP Fortune Teller";		-- Name the Panel
local mainFortuneCategory = Settings.RegisterCanvasLayoutCategory(FortuneAdd.panel, "RP Fortune Teller")
Settings.RegisterAddOnCategory(mainFortuneCategory)
FortuneAdd.panel:RegisterEvent("ADDON_LOADED")		-- Trigger an event when this addon loads.
FortuneAdd.panel:SetScript("OnEvent", function(self, event, ...)
	if (event == "ADDON_LOADED") then
		-- Register Generic Addon Settings
		FortuneAdd:RegisterDefaultGenericSetting("ForceTargets", true) -- Should we allow targets to be differentiated?
		FortuneAdd:RegisterDefaultGenericSetting("LuckyNumReturned", 6) -- How many lucky numbers should we return?
		FortuneAdd:RegisterDefaultGenericSetting("LuckyNumMax", 42) -- What is the highest lucky number we should return?

		FortuneAdd.panel:UnregisterEvent("ADDON_LOADED")
    end
end)

-------------
-- Main Interface Window
-------------
FortuneAdd.panel:Hide()
FortuneAdd.panel:SetScript("OnShow", function()
    local Title = FortuneAdd.panel:CreateFontString("Title", "ARTWORK", "GameFontNormalLarge")
    Title:SetPoint("TOPLEFT", FortuneAdd.panel, 16, -16)
	Title:SetText("RP Fortune Teller")
	
	-- Credit string for Reputation/Potions
	local creditString = FortuneAdd.panel:CreateFontString("creditString", "OVERLAY", "GameFontNormal")
	creditString:SetText("Made in memory of Reputation/Potions, Mariah Carey's #1 fan and a fantastic friend.")
	creditString:SetPoint("TOPLEFT", 20, -45)

	-- Check box to force fortunes to use the targeted list when a target is selected
	local ForceTargets = FortuneAdd:CreateCheckBox("ForceTargets", FortuneAdd.panel, "Force Targeted Fortunes", nil, Title, 0, -40, false)
    ForceTargets:SetScript("OnClick", function(self)
        local checked = not not self:GetChecked()
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
		RPFortuneSettings.ForceTargets = checked
    end)
	
		-- String to mention the max value slider.
	local sliderString = FortuneAdd.panel:CreateFontString("sliderString", "OVERLAY", "GameFontNormal")
	sliderString:SetText("Lucky Numbers to return")
	sliderString:SetPoint("TOPLEFT", 20, -125)
	
	-- Slider to determine the max value for the Lucky Number option.
	local LuckyNumSlider = FortuneAdd:CreateSlider("NumValueSlider", RPFortuneSettings.LuckyNumReturned, 1, 10, -125)
	local sliderText = _G[LuckyNumSlider:GetName() .. "Text"]
	sliderText:SetText(RPFortuneSettings.LuckyNumReturned)
	LuckyNumSlider:SetScript("OnValueChanged", function(_, value)
		RPFortuneSettings.LuckyNumReturned = math.floor(value)
		sliderText:SetText(RPFortuneSettings.LuckyNumReturned)
	end)
	LuckyNumSlider:Show()
	
	-- String to mention the max value slider.
	local sliderMaxString = FortuneAdd.panel:CreateFontString("sliderMaxString", "OVERLAY", "GameFontNormal")
	sliderMaxString:SetText("Max Lucky Number value")
	sliderMaxString:SetPoint("TOPLEFT", 20, -185)
	
	-- Slider to determine the max value for the Lucky Number option.
	local LuckyNumMaxSlider = FortuneAdd:CreateSlider("MaxValueSlider", RPFortuneSettings.LuckyNumMax, 1, 100, -185)	
	local sliderMaxText = _G[LuckyNumMaxSlider:GetName() .. "Text"]
	sliderMaxText:SetText(RPFortuneSettings.LuckyNumMax)
	LuckyNumMaxSlider:SetScript("OnValueChanged", function(_, value)
		RPFortuneSettings.LuckyNumMax = math.floor(value)
		sliderMaxText:SetText(RPFortuneSettings.LuckyNumMax)
	end)
	LuckyNumMaxSlider:Show()

	-- Quick refresh function to ensure our check boxes work.
    function FortuneAdd:Refresh()
        ForceTargets:SetChecked(RPFortuneSettings.ForceTargets)
    end

    FortuneAdd:Refresh()
    FortuneAdd.panel:SetScript("OnShow", nil)
end)

-- Generic Registration Panel
function FortuneAdd:RegisterDefaultGenericSetting(key, value)
    if (RPFortuneSettings == nil) then
        RPFortuneSettings = {}
    end
   if (RPFortuneSettings[key] == nil) then
        RPFortuneSettings[key] = value
   end
end

-- Generic checkbox function
function FortuneAdd:CreateCheckBox(name, parent, label, tooltip, relativeTo, x, y, disableInCombat)
    local checkBox = CreateFrame("CheckButton", name, parent, "InterfaceOptionsCheckButtonTemplate")
    checkBox:SetPoint("TOPLEFT", relativeTo, "BOTTOMLEFT", x, y)
    checkBox.Text:SetText(label)

    if ( tooltip ) then
        checkBox.tooltipText = tooltip
    end

    return checkBox
end

function FortuneAdd:CreateSlider(sliderName, currentValue, minValue, maxValue, y)
	local slider = CreateFrame("Slider", sliderName, FortuneAdd.panel, "OptionsSliderTemplate")	
	slider.mytype = "slider"
	slider.myheight = 50
	slider:SetMinMaxValues(minValue, maxValue)
	slider:SetValue(currentValue)
	slider:SetWidth(250)
	slider:SetPoint("TOPLEFT", 220, y)
	_G[slider:GetName() .. 'Low']:SetText(minValue); --Sets the left-side slider text (default is "Low").
	_G[slider:GetName() .. 'High']:SetText(maxValue); --Sets the right-side slider text (default is "High").
	
	return slider
end

-- Called to determine the fortune given.
function FortuneAdd:SecondEmote()
	if (UnitExists("target")) then
		if (RPFortuneSettings.ForceTargets) then		
			SendChatMessage(FortunesWithTarget[math.random(#FortunesWithTarget)], "EMOTE")
		else
			if (math.random(1, 10) < 6) then 
				SendChatMessage(FortunesWithTarget[math.random(#FortunesWithTarget)], "EMOTE")
			else 
				SendChatMessage(FortunesWithoutTarget[math.random(#FortunesWithoutTarget)], "EMOTE")
			end
		end
	else 
		SendChatMessage(FortunesWithoutTarget[math.random(#FortunesWithoutTarget)], "EMOTE")
	end
end

-- Called to determine the "peer into the future" emote
function FortuneAdd:FirstEmote()
	if (UnitExists("target")) then
		if (RPFortuneSettings.ForceTargets) then
			SendChatMessage(PeeringWithTarget[math.random(#PeeringWithTarget)], "EMOTE")
		else
			if (math.random(1, 10) < 6) then 
				SendChatMessage(PeeringWithTarget[math.random(#PeeringWithTarget)], "EMOTE")
			else
				SendChatMessage(PeeringWithoutTarget[math.random(#PeeringWithoutTarget)], "EMOTE")
			end
		end
	else 
		SendChatMessage(PeeringWithoutTarget[math.random(#PeeringWithoutTarget)], "EMOTE")
	end
	C_Timer.After(2, function ()
		FortuneAdd:SecondEmote()
	end)
end

-- Called when you need to find someone's lucky numbers
function FortuneAdd:LuckyNumbers(maxValue)
	-- Set up the numbers emote
	local chatValue = ""	
	local luckyNums = {}
	if (UnitExists("target")) then
		chatValue = chatValue .. "foresees %t's lucky numbers: "
	else 
		chatValue = chatValue .. "foresees some lucky numbers: "
	end

	-- Add in each number one at a time.
	for i = 1, RPFortuneSettings.LuckyNumReturned, 1
	do 
		luckyNums[i] = math.random(1, maxValue)
	end
	
	table.sort(luckyNums)
	
	for i = 1, RPFortuneSettings.LuckyNumReturned, 1
	do 
		chatValue = chatValue .. luckyNums[i]
		if (i < RPFortuneSettings.LuckyNumReturned) then
			chatValue = chatValue .. ", "
		end
	end
	
	-- Emote the lucky numbers
	SendChatMessage(chatValue, "EMOTE")
end

-------------
-- Keyboard Shortcuts
-------------
SLASH_RPFMENU1 = "/rpfortune"
SLASH_RPFMENU2 = "/rpf"
SlashCmdList["RPFMENU"] = function()
	SettingsPanel:Open(); 
	SettingsPanel:SelectCategory(mainFortuneCategory, true);
end 

SLASH_RPFTELL1 = "/rpfortune_tell"
SLASH_RPFTELL2 = "/rpf_tell"
SlashCmdList["RPFTELL"] = function()
    FortuneAdd:FirstEmote()
end 

SLASH_RPFLUCKY1 = "/rpfortune_lucky"
SLASH_RPFLUCKY2 = "/rpf_lucky"
SlashCmdList["RPFLUCKY"] = function()
    FortuneAdd:LuckyNumbers(RPFortuneSettings.LuckyNumMax)
end 