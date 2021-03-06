local function recap()
	-- Calculate sum of everyone's deaths
	local sumDeaths = 0
	for _,deaths in pairs(squad) do
		sumDeaths = sumDeaths + deaths
	end
	
	-- Calculate sum of boss deaths
	local sumBosses = 0
	for _,deaths in pairs(bosses) do
	    sumBosses = sumBosses + deaths
    end

	-- Find the maximum number of deaths
	local maxDeaths = 0
	for _,deaths in pairs(squad) do
		if deaths > maxDeaths then
			maxDeaths = deaths
		end
	end

	-- Find who has this number of deaths
	local maxNames = {}
	for name,deaths in pairs(squad) do
		if deaths == maxDeaths then
			table.insert(maxNames, name)
		end
	end

	local nameString = ""
	local listSize = table.getn(maxNames)
	if listSize == 1 then
		nameString = maxNames[1]
		remainderString = ", with a whopping " .. maxDeaths .. " deaths!"
	elseif listSize == 2 then
		nameString = maxNames[1] .. " and " .. maxNames[2]
		remainderString = " are tied with a remarkable " .. maxDeaths .. " deaths!"
	elseif listSize >= 3 then
		for i=1,listSize-1,1 do
			nameString = nameString .. maxNames[i] .. ", "
		end
		nameString = nameString .. "and " .. maxNames[listSize]
		remainderString = " are all tied with an extraordinary " .. maxDeaths .. " deaths!"
	end

	SendChatMessage("PPBBS Recap!", "RAID", nil)
	SendChatMessage("Total deaths this tier: " .. sumDeaths, "RAID", nil)
	SendChatMessage("Top performer: " .. nameString .. remainderString, "RAID", nil)
end

local function list()
	SendChatMessage("PPBBS Bodybag Count:", "RAID", nil)
	for name,deaths in pairs(squad) do
		SendChatMessage(name .. ": " .. deaths, "RAID", nil)
	end
end

local function search(query)
	local found = 0
	for name,deaths in pairs(squad) do
		if name == query then
			SendChatMessage(name .. " has died " .. deaths .. " times!", "RAID", nil)
			found = 1
		end
		if found == 0 then
			SendChatMessage("Ain't nobody in BBS with that name, yo", "RAID", nil)
		end
	end
end

-- ^%a+%s(%a+)%s(%a+)$

local function filter(_, event, msg, player, ...)
    if event == "CHAT_MSG_RAID" or event == "CHAT_MSG_CHANNEL" then
		if msg:match("^!ppbbs") then
			local cmd = msg:match("^%S*%s*(.-)$")
			if cmd == '' then
				recap()
			elseif cmd == 'all' then
				list()
			else
				search(cmd)
			end
		end
	end
end

SLASH_PPBBS1 = "/ppbbs"
SlashCmdList["PPBBS"] = function(msg, editbox)
	local command, name = msg:match("^(%S*)%s*(.-)$")
	if command == "add" and name ~= "" then
		squad[name] = 0
		SendChatMessage("PPBBS: " .. name .. " has been added to the roster.", "RAID", nil)
	elseif command == "remove" and name ~= "" then
		squad[name] = nil
		SendChatMessage("PPBBS: " .. name .. " has been removed from the roster.", "RAID", nil)
	else
		print("Syntax: /ppbbs (add|remove|recap) (name)")
	end	
end

local Loaded_EventFrame = CreateFrame("Frame")
Loaded_EventFrame:RegisterEvent("ADDON_LOADED")
Loaded_EventFrame:SetScript("OnEvent", function(self, event, arg1)
	if event == "ADDON_LOADED" and arg1 == "PPBBS" then
		if type(squad) ~= "table" then
			squad = {}
		end
		if type(bosses) ~= "table" then
		    bosses = {}
        end
	end
end)

local Death_EventFrame = CreateFrame("Frame")
Death_EventFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
Death_EventFrame:SetScript("OnEvent", function(_, _, _, event, _, _, _, _, _, _, destName, ...)
	if event == "UNIT_DIED" then
		for v,_ in pairs(squad) do
			if v == destName then
				squad[destName] = squad[destName] + 1
			end
		end
    end
end)

ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID", filter)