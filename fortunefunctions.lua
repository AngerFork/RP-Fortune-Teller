local addon, ns = ...

-------------
-- Main Interface Window Builder
-------------
local FortuneAdd = {};
FortuneAdd.panel = CreateFrame( "Frame", "FortuneAdd", UIParent );	-- Create the Panel
FortuneAdd.panel.name = "RP Fortune Teller";		-- Name the Panel
local mainFortuneCategory = Settings.RegisterCanvasLayoutCategory(FortuneAdd.panel, "RP Fortune Teller")
Settings.RegisterAddOnCategory(mainFortuneCategory)
FortuneAdd.panel:RegisterEvent("ADDON_LOADED")		-- Trigger an event when this addon loads.
FortuneAdd.panel:SetScript("OnEvent", function(self, event, loadedAddon)
	-- ADDON_LOADED fires once per addon, so make sure it's ours before touching saved settings.
	if (event == "ADDON_LOADED" and loadedAddon == addon) then
		-- Register Generic Addon Settings
		FortuneAdd:RegisterDefaultGenericSetting("ForceTargets", true) -- Should we allow targets to be differentiated?
		FortuneAdd:RegisterDefaultGenericSetting("LuckyNumReturned", 6) -- How many lucky numbers should we return?
		FortuneAdd:RegisterDefaultGenericSetting("LuckyNumMax", 42) -- What is the highest lucky number we should return?
		FortuneAdd:RegisterDefaultGenericSetting("ShowBar", false) -- Show the Prophecy/Task button bar? (off until turned on)

		FortuneAdd:SetUpBar()
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

	-- Check box to show/hide the Prophecy/Task button bar
	local ShowBar = FortuneAdd:CreateCheckBox("RPFortuneShowBar", FortuneAdd.panel, "Show Prophecy/Task Button Bar", "Shows a small movable bar with Prophecy and Task buttons. Same as /rpf_bar.", ForceTargets, 0, -4, false)
	ShowBar:SetScript("OnClick", function(self)
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
		FortuneAdd:SetBarShown(not not self:GetChecked())
	end)
	
		-- String to mention the max value slider.
	local sliderString = FortuneAdd.panel:CreateFontString("sliderString", "OVERLAY", "GameFontNormal")
	sliderString:SetText("Lucky Numbers to return")
	sliderString:SetPoint("TOPLEFT", 20, -155)
	
	-- Slider to determine the max value for the Lucky Number option.
	local LuckyNumSlider = FortuneAdd:CreateSlider("NumValueSlider", RPFortuneSettings.LuckyNumReturned, 1, 10, -155)
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
	sliderMaxString:SetPoint("TOPLEFT", 20, -215)
	
	-- Slider to determine the max value for the Lucky Number option.
	local LuckyNumMaxSlider = FortuneAdd:CreateSlider("MaxValueSlider", RPFortuneSettings.LuckyNumMax, 1, 100, -215)	
	local sliderMaxText = _G[LuckyNumMaxSlider:GetName() .. "Text"]
	sliderMaxText:SetText(RPFortuneSettings.LuckyNumMax)
	LuckyNumMaxSlider:SetScript("OnValueChanged", function(_, value)
		RPFortuneSettings.LuckyNumMax = math.floor(value)
		sliderMaxText:SetText(RPFortuneSettings.LuckyNumMax)
	end)
	LuckyNumMaxSlider:Show()

	-- Slash command reference
	local commandsHeader = FortuneAdd.panel:CreateFontString("RPFortuneCommandsHeader", "OVERLAY", "GameFontNormalLarge")
	commandsHeader:SetText("Slash Commands")
	commandsHeader:SetPoint("TOPLEFT", 16, -275)

	local commandList = {
		{ "/rpf", "Opens this options menu" },
		{ "/rpf_tell", "Tell a prophecy (use once to peer into the future, again to reveal it)" },
		{ "/rpf_task", "Give a task (use once to look for a task, again to hand it out)" },
		{ "/rpf_lucky", "Reveal lucky numbers" },
		{ "/rpf_bar", "Show/hide the Prophecy/Task button bar" },
		{ "/rpf_zone", "Show the exact zone name to use in tasklists.lua" },
	}
	local lines = {}
	for _, c in ipairs(commandList) do
		lines[#lines + 1] = "|cffffd100" .. c[1] .. "|r  -  " .. c[2]
	end
	local commandsText = FortuneAdd.panel:CreateFontString("RPFortuneCommandsText", "OVERLAY", "GameFontHighlight")
	commandsText:SetPoint("TOPLEFT", commandsHeader, "BOTTOMLEFT", 4, -10)
	commandsText:SetWidth(560)
	commandsText:SetJustifyH("LEFT")
	commandsText:SetSpacing(6)
	commandsText:SetText(table.concat(lines, "\n"))

	-- Quick refresh function to ensure our check boxes work.
    function FortuneAdd:Refresh()
        ForceTargets:SetChecked(RPFortuneSettings.ForceTargets)
        ShowBar:SetChecked(RPFortuneSettings.ShowBar)
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

-------------
-- Sending chat
-------------
-- Why there's no timer between the two emotes any more:
-- Modern clients (Midnight / WoW Forever) only reliably let an addon send chat while it's
-- responding to something you physically did (a click, a keypress, typing a slash command).
-- The old SecondEmote ran from C_Timer.After, two seconds after your click, so the game
-- dropped it. Now each step is sent from its own click. The first click does the "peering"
-- emote, then the button counts down and turns into a "Reveal" button for the second click.

local function Print(msg)
	print("|cff9d7bffRP Fortune Teller:|r " .. msg)
end

function FortuneAdd:SendEmote(msg)
	if (C_ChatInfo and C_ChatInfo.InChatMessagingLockdown and C_ChatInfo.InChatMessagingLockdown()) then
		Print("The game is blocking addon chat right now (usually during a boss fight). Try again in a moment.")
		return false
	end
	if (C_ChatInfo and C_ChatInfo.SendChatMessage) then
		C_ChatInfo.SendChatMessage(msg, "EMOTE")
	else
		SendChatMessage(msg, "EMOTE")
	end
	return true
end

-------------
-- Randomizer
-------------
-- The game's math.random can hand back the same sequence after every login or /reload,
-- which made fortunes come out in the same order each session. To avoid that:
--   1. Every roll mixes in the exact (sub-millisecond) moment you clicked, which is
--      different every time a real person plays.
--   2. Lines are dealt from a shuffled "deck", so nothing repeats until every line in
--      that list has been used once. Then the deck is reshuffled.

local function Clock()
	if (debugprofilestop) then
		return debugprofilestop()
	end
	return GetTime() * 1000
end

-- Some clients still allow seeding; harmless if they don't.
if (math.randomseed) then
	pcall(math.randomseed, math.floor(Clock() * 1000) + (time and time() or 0))
end

-- Returns a whole number from 1 to n.
local function Roll(n)
	if (n <= 1) then
		return 1
	end
	local base = math.random(n) - 1
	local jitter = math.floor(Clock() * 1000) % n
	return ((base + jitter) % n) + 1
end
ns.Roll = Roll

-- One shuffled deck per list. Weak keys so lists aren't kept alive by the decks.
local decks = setmetatable({}, { __mode = "k" })

local function Reshuffle(list, lastPicked)
	local order = {}
	for i = 1, #list do
		order[i] = i
	end
	-- Fisher-Yates shuffle
	for i = #order, 2, -1 do
		local j = Roll(i)
		order[i], order[j] = order[j], order[i]
	end
	-- Don't let the first card of the new deck be the last card of the old one.
	if (#order > 1 and order[#order] == lastPicked) then
		order[#order], order[1] = order[1], order[#order]
	end
	return { order = order, size = #list, last = lastPicked }
end

local function RandomFrom(list)
	if (type(list) == "string") then
		return list
	end
	if (type(list) ~= "table" or #list == 0) then
		return nil
	end
	local deck = decks[list]
	-- Build a new deck when we run out, or if the list was edited and changed size.
	if (not deck or #deck.order == 0 or deck.size ~= #list) then
		deck = Reshuffle(list, deck and deck.last)
		decks[list] = deck
	end
	local index = table.remove(deck.order)	-- deal from the top (end) of the deck
	deck.last = index
	return list[index]
end

-- Should this fortune use the "with target" lists?
local function UseTargetLists()
	if (not UnitExists("target")) then
		return false
	end
	if (RPFortuneSettings.ForceTargets) then
		return true
	end
	return Roll(10) < 6
end

-------------
-- Two-step actions (emote now, reveal on the next click)
-------------
local REVEAL_DELAY = 3		-- Seconds before the reveal is allowed (the "Wait 3 sec" in the diagram)
local PENDING_TIMEOUT = 60	-- Seconds before an unrevealed vision fades away

local pending = {}		-- pending[key] = { reveal = function, readyAt = time, expiresAt = time, announced = bool }
local ticker = nil

function FortuneAdd:IsPending(key)
	return pending[key] ~= nil
end

function FortuneAdd:TickPending()
	local now = GetTime()
	local anyLeft = false
	for key, p in pairs(pending) do
		if (now >= p.expiresAt) then
			pending[key] = nil
			Print("The vision fades... (" .. key .. " was never revealed)")
		else
			anyLeft = true
			if (now >= p.readyAt and not p.announced) then
				p.announced = true
				PlaySound(SOUNDKIT.IG_QUEST_LIST_OPEN)
			end
		end
	end
	if (not anyLeft and ticker) then
		ticker:Cancel()
		ticker = nil
	end
	FortuneAdd:UpdateBar()
end

-- firstStep() sends the opening emote and returns a function that sends the reveal.
function FortuneAdd:RunTwoStep(key, firstStep)
	local p = pending[key]
	if (p) then
		local wait = p.readyAt - GetTime()
		if (wait > 0) then
			Print(string.format("Still concentrating... ready in %d.", math.ceil(wait)))
			return
		end
		pending[key] = nil
		p.reveal()
		FortuneAdd:TickPending()
		return
	end

	local reveal = firstStep()
	if (not reveal) then
		return
	end
	local now = GetTime()
	pending[key] = { reveal = reveal, readyAt = now + REVEAL_DELAY, expiresAt = now + PENDING_TIMEOUT, announced = false }
	if (not ticker) then
		ticker = C_Timer.NewTicker(0.2, function() FortuneAdd:TickPending() end)
	end
	FortuneAdd:UpdateBar()
end

-------------
-- Prophecy: textPropEmote -> wait -> textPropOutput
-------------
function FortuneAdd:ProphecyFirst()
	-- Decide once, so the peering emote and the prophecy match each other.
	local withTarget = UseTargetLists()
	local emote = RandomFrom(withTarget and ns.PeeringWithTarget or ns.PeeringWithoutTarget)
	if (not self:SendEmote(emote)) then
		return nil
	end
	return function()
		-- If the target walked off in the meantime, fall back to a general prophecy.
		local stillTargeted = withTarget and UnitExists("target")
		self:SendEmote(RandomFrom(stillTargeted and ns.FortunesWithTarget or ns.FortunesWithoutTarget))
	end
end

function FortuneAdd:Prophecy()
	self:RunTwoStep("Prophecy", function() return self:ProphecyFirst() end)
end

-------------
-- Task: textTaskEmote -> pull arrayTask -> (zone lookup) -> textTaskOutput
-------------
function FortuneAdd:GetZoneName()
	local zone = GetZoneText()
	if (zone == nil or zone == "") then
		zone = GetRealZoneText()
	end
	return zone
end

-- Pick a task following the diagram. Returns the task text.
function FortuneAdd:PickTask()
	local entry = RandomFrom(ns.arrayTask)
	if (entry and not entry.isZoneTask) then
		return entry.textTaskOutput
	end

	-- Zone task: look up where we're standing.
	local zoneInfo = ns.arrayZoneInfo[self:GetZoneName() or ""]
	local zoneTask = zoneInfo and RandomFrom(zoneInfo.textZoneTask)
	if (zoneTask) then
		return zoneTask
	end

	-- No task written for this zone yet, so hand out a general one instead.
	local general = {}
	for _, t in ipairs(ns.arrayTask) do
		if (not t.isZoneTask and t.textTaskOutput and t.textTaskOutput ~= "") then
			general[#general + 1] = t.textTaskOutput
		end
	end
	return RandomFrom(general)
end

function FortuneAdd:TaskFirst()
	local withTarget = UnitExists("target")
	-- Choose the task now, so it matches the zone you were in when you started.
	local taskText = self:PickTask()
	if (not taskText) then
		Print("No tasks found. Check tasklists.lua.")
		return nil
	end
	if (not self:SendEmote(RandomFrom(withTarget and ns.textTaskEmoteWithTarget or ns.textTaskEmote))) then
		return nil
	end
	return function()
		local stillTargeted = withTarget and UnitExists("target")
		local line = RandomFrom(stillTargeted and ns.textTaskGiveWithTarget or ns.textTaskGiveWithoutTarget)
		-- Using a function here means any % signs in the task text are left alone.
		line = line:gsub("{task}", function() return taskText end)
		self:SendEmote(line)
	end
end

function FortuneAdd:Task()
	self:RunTwoStep("Task", function() return self:TaskFirst() end)
end

-------------
-- Button bar ("Button: Prophecy" / "Button: Task")
-------------
local BUTTON_LABELS = {
	Prophecy = { start = "Prophecy", reveal = "Reveal" },
	Task = { start = "Task", reveal = "Give Task" },
}

function FortuneAdd:SetUpBar()
	local bar = CreateFrame("Frame", "RPFortuneBar", UIParent, "BackdropTemplate")
	bar:SetSize(232, 56)
	bar:SetBackdrop({
		bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		tile = true, tileSize = 16, edgeSize = 16,
		insets = { left = 4, right = 4, top = 4, bottom = 4 },
	})
	bar:SetBackdropColor(0.08, 0.04, 0.12, 0.9)
	bar:SetClampedToScreen(true)
	bar:SetMovable(true)
	bar:EnableMouse(true)
	bar:RegisterForDrag("LeftButton")
	bar:SetScript("OnDragStart", bar.StartMoving)
	bar:SetScript("OnDragStop", function(self)
		self:StopMovingOrSizing()
		local point, _, relativePoint, x, y = self:GetPoint()
		RPFortuneSettings.BarPosition = { point, relativePoint, x, y }
	end)

	local pos = RPFortuneSettings.BarPosition
	if (pos) then
		bar:SetPoint(pos[1], UIParent, pos[2], pos[3], pos[4])
	else
		bar:SetPoint("CENTER", UIParent, "CENTER", 0, -200)
	end

	local title = bar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	title:SetPoint("TOP", 0, -7)
	title:SetText("RP Fortune Teller")

	local function MakeButton(key, x, onClick)
		local b = CreateFrame("Button", nil, bar, "UIPanelButtonTemplate")
		b:SetSize(104, 24)
		b:SetPoint("BOTTOMLEFT", x, 8)
		b:SetText(BUTTON_LABELS[key].start)
		b:SetScript("OnClick", onClick)
		return b
	end
	bar.buttons = {
		Prophecy = MakeButton("Prophecy", 10, function() FortuneAdd:Prophecy() end),
		Task = MakeButton("Task", 118, function() FortuneAdd:Task() end),
	}

	self.bar = bar
	bar:SetShown(RPFortuneSettings.ShowBar)
	self:UpdateBar()
end

function FortuneAdd:UpdateBar()
	if (not self.bar) then
		return
	end
	local now = GetTime()
	for key, button in pairs(self.bar.buttons) do
		local p = pending[key]
		if (not p) then
			button:SetText(BUTTON_LABELS[key].start)
			button:Enable()
		elseif (now < p.readyAt) then
			button:SetText(string.format("%s (%d)", BUTTON_LABELS[key].reveal, math.ceil(p.readyAt - now)))
			button:Disable()
		else
			button:SetText("|cff00ff00" .. BUTTON_LABELS[key].reveal .. "|r")
			button:Enable()
		end
	end
end

function FortuneAdd:SetBarShown(shown)
	RPFortuneSettings.ShowBar = shown
	if (self.bar) then
		self.bar:SetShown(shown)
	end
	-- Keep the options menu checkbox in sync (Refresh only exists once the menu has been opened).
	if (self.Refresh) then
		self:Refresh()
	end
end

function FortuneAdd:ToggleBar()
	self:SetBarShown(not RPFortuneSettings.ShowBar)
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

	-- Add in each number one at a time, without repeats (unless there aren't enough numbers to go around).
	local used = {}
	local allowRepeats = RPFortuneSettings.LuckyNumReturned > maxValue
	for i = 1, RPFortuneSettings.LuckyNumReturned, 1
	do 
		local n = Roll(maxValue)
		while (used[n] and not allowRepeats) do
			n = Roll(maxValue)
		end
		used[n] = true
		luckyNums[i] = n
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
	FortuneAdd:SendEmote(chatValue)
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

-- Run once to peer into the future, run again (after a few seconds) to reveal it.
SLASH_RPFTELL1 = "/rpfortune_tell"
SLASH_RPFTELL2 = "/rpf_tell"
SLASH_RPFTELL3 = "/rpf_prophecy"
SlashCmdList["RPFTELL"] = function()
	FortuneAdd:Prophecy()
end

-- Run once to look for a task, run again (after a few seconds) to hand it out.
SLASH_RPFTASK1 = "/rpfortune_task"
SLASH_RPFTASK2 = "/rpf_task"
SlashCmdList["RPFTASK"] = function()
	FortuneAdd:Task()
end

SLASH_RPFLUCKY1 = "/rpfortune_lucky"
SLASH_RPFLUCKY2 = "/rpf_lucky"
SlashCmdList["RPFLUCKY"] = function()
	FortuneAdd:LuckyNumbers(RPFortuneSettings.LuckyNumMax)
end

-- Show/hide the Prophecy/Task button bar.
SLASH_RPFBAR1 = "/rpf_bar"
SlashCmdList["RPFBAR"] = function()
	FortuneAdd:ToggleBar()
end

-- Prints the exact zone name to use as a key in arrayZoneInfo (tasklists.lua).
SLASH_RPFZONE1 = "/rpf_zone"
SlashCmdList["RPFZONE"] = function()
	print("|cff9d7bffRP Fortune Teller:|r Zone name for tasklists.lua: [\"" .. (FortuneAdd:GetZoneName() or "?") .. "\"]")
end
