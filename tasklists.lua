local addon, ns = ...

-------------
-- Task lists (the quest-giver side of the addon)
--
-- How a Task works:
--   1. Click "Task" (or /rpf_task): you emote a random textTaskEmote and the addon
--      secretly pulls a random entry from arrayTask.
--   2. After a short pause, click "Give Task" (or /rpf_task again):
--        - isZoneTask = false -> hand out that entry's textTaskOutput
--        - isZoneTask = true  -> look up the zone you're standing in, in arrayZoneInfo,
--                                and hand out that zone's textZoneTask
--          (if the zone isn't in the list yet, a general task is used instead)
--
-- Tips:
--   * The mix of zone vs. general tasks is just how many entries of each you put
--     in arrayTask. Three "true" entries and one "false" = zone tasks ~75% of the time.
--   * Zone names must match the game exactly. Stand in a zone and type /rpf_zone
--     to see the exact name to use as the key.
--   * textZoneTask can be one string, or a list of strings to pick from at random.
--   * You can use %t in any line and it will be replaced with your target's name.
-------------

-- The "rummaging for a quest" emote. Sent first.
ns.textTaskEmoteWithTarget = {
	"looks %t up and down, as if measuring them for an errand.",
	"pulls out a long, crumpled list and runs a finger down it while glancing at %t.",
	"stirs a bubbling Potion, then points the spoon at %t.",
	"flips through a ledger labelled 'People Who Owe Me Favors' and stops at %t's name.",
	"waves %t over with a conspiratorial whisper.",
}

ns.textTaskEmote = {
	"pulls out a long, crumpled list of errands.",
	"rings a tiny bell. Adventurers wanted!",
	"rummages through a satchel full of half-finished requests.",
	"clears their throat loudly, looking for a volunteer.",
	"pins a notice to the nearest available surface.",
}

-- How the task is handed over. {task} is replaced with the chosen task text.
ns.textTaskGiveWithTarget = {
	"hands %t a scrap of paper. It reads: \"{task}\"",
	"points dramatically at %t. \"{task}\"",
	"leans in close to %t and whispers, \"{task}\"",
	"presses a quest scroll into %t's hands: \"{task}\"",
}

ns.textTaskGiveWithoutTarget = {
	"announces to anyone listening: \"{task}\"",
	"posts a notice: \"{task}\"",
	"calls out, \"{task}\"",
}

-- Each entry is either a general task or a "use the zone's task" slot.
ns.arrayTask = {
	{ isZoneTask = false, textTaskOutput = "Fite me IRL." },
	{ isZoneTask = false, textTaskOutput = "Find me a song that is better than anything by Mariah Carey. Take your time. You will need it." },
	{ isZoneTask = false, textTaskOutput = "Go and do something nice for a stranger. I will know if you don't." },
	{ isZoneTask = false, textTaskOutput = "Return to me with the tears of a Rogue. Good luck catching one." },
	{ isZoneTask = false, textTaskOutput = "Dance with the next person you see. No questions." },
	{ isZoneTask = true,  textTaskOutput = "" },
	{ isZoneTask = true,  textTaskOutput = "" },
	{ isZoneTask = true,  textTaskOutput = "" },
	{ isZoneTask = true,  textTaskOutput = "" },
	{ isZoneTask = true,  textTaskOutput = "" },
}

-- Zone-specific tasks, keyed by the exact in-game zone name (/rpf_zone shows it).
ns.arrayZoneInfo = {
	["Tirisfal Glades"] = { textZoneTask = {
		"Bring me 5 Bat Wings.",
		"Find out what the farmers here are really growing.",
	}},
	["Uldum"] = { textZoneTask = "Return to me with 6 Aqir Wings." },
	["The Jade Forest"] = { textZoneTask = "Track down 12 Apples." },
	["Elwynn Forest"] = { textZoneTask = {
		"Bring me 8 Wolf Meat. Hogger cannot have all of it.",
		"Find a candle that will not go out. Kobolds have opinions about candles.",
	}},
	["Durotar"] = { textZoneTask = "Bring me 4 Scorpid Tails. Carefully." },
	["Stormwind City"] = { textZoneTask = "Count every guard in the Trade District. Report back with the number." },
	["Orgrimmar"] = { textZoneTask = "Get a signature from the most important person in the Valley of Strength." },
	["Westfall"] = { textZoneTask = "Bring me a Goretusk Liver. It is for a Potion. Probably." },
	["Stranglethorn Vale"] = { textZoneTask = "Find me one page of the Green Hills of Stranglethorn. Just one. Please." },
	["Mechagon"] = { textZoneTask = "Spend one night in Mechagon without falling asleep. Keep your limbs." },
	["Dalaran"] = { textZoneTask = "Bring me something purple. It is Dalaran, so this should be easy." },
}
