local function recap()
	-- Calculate sum of everyone's deaths
	local sumBags = 0
	for name,bags in pairs(squad) do
		sumBags = sumBags + bags
	end
	
	-- Calculate sum of boss deaths
	local sumBosses = 0
	for boss,deaths in pairs(bosses) do
	    sumBosses = sumBosses + deaths
    end

	-- Find the maximum number of deaths
	local maxBags = 0
	for name,bags in pairs(squad) do
		if bags > maxBags then
			maxBags = bags
		end
	end

	-- Find who has this number of deaths
	local maxNames = {}
	for name,bags in pairs(squad) do
		if bags == maxBags then
			table.insert(maxNames, name)
		end
	end

	local nameString = ""
	local listSize = table.getn(maxNames)
	if listSize == 1 then
		nameString = maxNames[1]
		remainderString = ", with a whopping " .. maxBags .. " deaths!"
	elseif listSize == 2 then
		nameString = maxNames[1] .. " and " .. maxNames[2]
		remainderString = " are tied with a remarkable " .. maxBags .. " deaths!"
	elseif listSize >= 3 then
		for i=1,listSize-1,1 do
			nameString = nameString .. maxNames[i] .. ", "
		end
		nameString = nameString .. "and " .. maxNames[listSize]
		remainderString = " are all tied with an extraordinary " .. maxBags .. " deaths!"
	end

	SendChatMessage("PPBBS Recap:", CHANNEL, nil, channelID)
	SendChatMessage("Total bodybags this tier: " .. sumBags, CHANNEL, nil, channelID)
	SendChatMessage("Most frequent contributor of bag stuffing: " .. nameString .. remainderString, CHANNEL, nil, channelID)
	SendChatMessage("Total bosses killed: " .. sumBosses, CHANNEL, nil, channelID)
	SendChatMessage("Bodybag to boss ratio: " .. sumBosses/sumBags, CHANNEL, nil, channelID)
end

SLASH_PPBBS1 = "/ppbbs"
SlashCmdList["PPBBS"] = function(msg, editbox)
	local command, name = msg:match("^(%S*)%s*(.-)$")
	local channelID, channelName = GetChannelName("Pandatest")
	if command == "add" and name ~= "" then
		squad[name] = 0
		SendChatMessage("PPBBS: " .. name .. " has been added to the roster.", CHANNEL, nil, channelID)
	elseif command == "remove" and name ~= "" then
		squad[name] = nil
		SendChatMessage("PPBBS: " .. name .. " has been removed from the roster.", CHANNEL, nil, channelID)
	elseif command == "register" and name ~= "" then
	    bosses[name] = 0
	    SendChatMessage("PPBBS: " .. name .. " has been registered as a boss.", CHANNEL, nil, channelID)
	elseif command == "recap" then
        recap()
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
Death_EventFrame:SetScript("OnEvent", function(self, gameEvent, timestamp, event, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, ...)
	if event == "UNIT_DIED" then
		for v,_ in pairs(squad) do
			if v == destName then
				squad[destName] = squad[destName] + 1
			end
		end
        for v,_ in pairs(bosses) do
            if v == destName then
                bosses[destName] = bosses[destName] + 1
            end
        end
    end
end)

local Chat_EventFrame = CreateFrame("Frame")
Chat_EventFrame:RegisterEvent("CHAT_MSG_CHANNEL")
Chat_EventFrame:SetScript("OnEvent", function(self, gameEvent, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, ...)
    if arg1 == "!ppbbs" then
        message("arg1: " .. arg1 .. " // arg2: " .. arg2 .." // arg3: " .. arg3 .." // arg4: " .. arg4 .." // arg5: " .. arg5 .." // arg6: " .. arg6 .." // arg7: " .. arg7 .." // arg8: " .. arg8 .." // arg9: " .. arg9 .." // arg10: " .. arg10 .." // arg11: " .. arg11 .." // arg12: " .. arg12)
    end
end)
        