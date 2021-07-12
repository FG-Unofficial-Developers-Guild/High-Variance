-- 	Author: Ryan Hagelstrom
--	Copyright � 2021
--	This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License.
--	https://creativecommons.org/licenses/by-sa/4.0/
local RulesetEffectManager
local handleResolution

function onInit()	
	if Session.IsHost then 
		OptionsManager.registerOption2(
			"HVDICE",
			false,
			"option_header_high_variance",
			"option_label_hv_dice",
			"option_entry_cycler",
			{
				labels = "option_high_variance_dice|option_blessed_dice|option_cursed_dice|option_crit_fumble_dice",
				values = "hv|b|c|cf",
				baselabel = "option_value_hv_off",
				baseval = "off",
				default = "off"
			}
		)
		OptionsManager.registerOption2(
			"HVACTOR",
			false,
			"option_header_high_variance",
			"option_label_hv_actors",
			"option_entry_cycler",
			{
				labels = "option_value_hv_friend|option_value_hv_foe",
				values = "friend|foe",
				baselabel = "option_value_hv_all",
				baseval = "all",
				default = "all"
			}
		)
		OptionsManager.registerOption2(
			"HVROLLS",
			false,
			"option_header_high_variance",
			"option_label_hv_rolls",
			"option_entry_cycler",
			{
				labels = "option_value_hv_damage|option_value_hv_attack|option_value_hv_all|option_value_hv_d20",
				values = "dmgheal|atk|all|d20",
				baselabel = "option_value_hv_attack_damage",
				baseval = "atkdmgheal",
				default = "atkdmgheal"
			}
		)
		OptionsManager.registerOption2(
			"HVCRITFUM",
			false,
			"option_header_high_variance",
			"option_label_hv_critfum",
			"option_entry_cycler",
			{
				labels = "11|12|13|14|15|16|17|18|19|1|2|3|4|5|6|7|8|9",
				values = "11|12|13|14|15|16|17|18|19|1|2|3|4|5|6|7|8|9",
				baselabel = "option_value_hv_critfum",
				baseval = "10",
				default = "10"
			}
		)
	end

	handleResolution = ActionsManager.handleResolution
	ActionsManager.handleResolution = customHandleResolution

	RulesetEffectManager = EffectManager

	if User.getRulesetName() == "5E" then
		RulesetEffectManager = EffectManager5E
	end
	if User.getRulesetName() == "4E" then
		RulesetEffectManager = EffectManager4E
	end
	if User.getRulesetName() == "3.5E" or User.getRulesetName() == "PFRPG" then
		RulesetEffectManager = EffectManager35E
	end
	if User.getRulesetName() == "2E" then
		RulesetEffectManager = EffectManagerADND
	end
	if User.getRulesetName() == "PFRPG2" then
		RulesetEffectManager = EffectManagerPFRPG2
	end
end

function onClose()
	ActionsManager.handleResolution = handleResolution
end

function customHandleResolution(rRoll, rSource, aTargets)
	if rSource ~= nil then
		local tOptions = getHVOptions(rSource)
		if tOptions.sHVDice ~= "off" and (tOptions.sHVRoll == "all" or tOptions.sHVRoll == "d20" or
			((tOptions.sHVRoll == "atk" or tOptions.sHVRoll == "atkdmgheal") and rRoll.sType == "attack") or
			((tOptions.sHVRoll == "dmgheal" or tOptions.sHVRoll == "atkdmgheal") and rRoll.sType == "damage") or
			((tOptions.sHVRoll == "dmgheal" or tOptions.sHVRoll == "atkdmgheal") and rRoll.sType == "heal")) then
			local nodeCT = ActorManager.getCTNode(rSource)
			local sFaction = DB.getValue(nodeCT, "friendfoe", "")
			if (tOptions.sHVActor == "all" or (tOptions.sHVActor == sFaction)) then
				if tOptions.sHVDice == "hv" then
					highVarianceDice(rRoll, tOptions.sHVRoll)
				end
				if tOptions.sHVDice == "b" then
					blessedDice(rRoll)
				elseif tOptions.sHVDice == "c" then
					cursedDice(rRoll);
				elseif tOptions.sHVDice == "cf" then
					criticalFumble(rRoll, tOptions.nHVCritFum)
				end
			end
		end
	end
	handleResolution(rRoll, rSource, aTargets)
end

function getEffect(rSource)
	local tHVOptions = {}
	local nodeCT = ActorManager.getCTNode(rSource);
	if nodeCT and (RulesetEffectManager.hasEffect(rSource, "HighVariance") or
		RulesetEffectManager.hasEffect(rSource, "BlessedDice") or
		RulesetEffectManager.hasEffect(rSource, "CursedDice") or
		RulesetEffectManager.hasEffect(rSource, "CritFumble")) then
		tHVOptions.sHVActor = DB.getValue(nodeCT, "friendfoe", "")
		for _,nodeEffect in pairs(DB.getChildren(nodeCT, "effects")) do
			local sEffect = DB.getValue(nodeEffect, "label", "")
			local aEffectComps = EffectManager.parseEffect(sEffect)
			for kEffectComp,sEffectComp in ipairs(aEffectComps) do
				local sLower = string.lower(sEffectComp)
				if sLower == "highvariance" then
					tHVOptions.sHVDice = "hv"
				elseif sLower == "blesseddice" then
					tHVOptions.sHVDice = "b"
				elseif sLower == "curseddice" then
					tHVOptions.sHVDice = "c"
				elseif sLower == "critfumble" then
					tHVOptions.sHVDice = "cf"
				end
				local rEffectComp = EffectManager.parseEffectCompSimple(sEffectComp)
				if rEffectComp.type == "HVROLL" and rEffectComp.remainder[1] then
					local sLower = string.lower(rEffectComp.remainder[1])
					if sLower == "dmgheal" or sLower == "atk" or sLower == "atkdmgheal" or sLower == "d20" or sLower == "all" then
						tHVOptions.sHVRoll = sLower
					end
				end
				if rEffectComp.type == "CRITLINE" and rEffectComp.mod then
					local nValue = tonumber(rEffectComp.mod)
					if nValue ~= nil and nValue >= 1 and nValue <= 19 then
						tHVOptions.nHVCritFum = nValue
					end
				end
			end
		end
	end
	return tHVOptions
end

function getHVOptions(rSource)
	local tHVOptions = {}
	tHVOptions.sHVDice =  OptionsManager.getOption("HVDICE")
	tHVOptions.sHVRoll =  OptionsManager.getOption("HVROLLS")
	tHVOptions.sHVActor =  OptionsManager.getOption("HVACTOR")
	tHVOptions.nHVCritFum =  tonumber(OptionsManager.getOption("HVCRITFUM"))

	local tEffectOptions = getEffect(rSource)
	if tEffectOptions.sHVDice then
		tHVOptions.sHVDice = tEffectOptions.sHVDice
		tHVOptions.sHVActor = tEffectOptions.sHVActor
		if tEffectOptions.nHVCritFum then
			tHVOptions.nHVCritFum = tEffectOptions.nHVCritFum
		end
		if tEffectOptions.sHVRoll then
			tHVOptions.sHVRoll = tEffectOptions.sHVRoll
		end
	end
	return tHVOptions
end

function criticalFumble(rRoll, nValue)
	if nValue >= 0 and nValue <= 19 then 
		for k, die in pairs(rRoll.aDice) do
			if die.result ~= nil and die.type == "d20" then
				if die.result >= nValue then
					die.result = 20
				else
					die.result = 1
				end
				die.value = die.result
			end
		end
	end
end	

function cursedDice(rRoll)
	for k, die in pairs(rRoll.aDice) do
		if die.result ~= nil and die.type == "d20" then
			if die.result == 20 then
				die.result = 1
				die.value = die.result
			end
		end
	end
end

function blessedDice(rRoll)
	for k, die in pairs(rRoll.aDice) do
		if die.result ~= nil and die.type == "d20" then
			if die.result == 1 then
				die.result = 20
				die.value = die.result
			end
		end
	end
end

function highVarianceDice(rRoll, sType)
	local nTotal = 0
	for k, die in pairs(rRoll.aDice) do
		if die.result ~= nil then
			if die.type == "d20" and sType ~= "dmgheal" then
				if die.result == 7 or die.result == 10 then
					die.result = 1
				elseif die.result == 14 or die.result == 9 then
					die.result = 20
				elseif die.result == 8 then
					die.result = 2
				elseif die.result == 13 then
					die.result = 19
				elseif die.result == 11 then
					die.result = 3
				elseif die.result == 12 then
					die.result = 18
				end
			elseif die.type == "d12" and not (sType == "d20" or sType == "atk") then
				if die.result == 8 then
					die.result = 12
				elseif die.result == 5 then
					die.result = 1
				elseif die.result == 6 then
					die.result = 11
				elseif die.result == 7 then
					die.result = 2
				end
			elseif die.type == "d10" and not (sType == "d20" or sType == "atk") then
				if die.result == 7 then
					die.result = 10
				elseif die.result == 4 then
					die.result = 1
				elseif die.result == 6 then
					die.result = 2
				elseif die.result == 5 then
					die.result = 9
				end
			elseif die.type == "d8" and not (sType == "d20" or sType == "atk") then
				if die.result == 4 then
					die.result = 8
				elseif die.result == 5 then
					die.result = 1
				end
			elseif die.type == "d6" and not (sType == "d20" or sType == "atk") then
				if die.result == 4 then
					die.result = 6
				elseif die.result == 5 then
					die.result = 1
				end
			elseif die.type == "d4" and not (sType == "d20" or sType == "atk") then
				if die.result == 2 then
					die.result = 4
				elseif die.result == 3 then
					die.result = 1
				end
			end
			die.value = die.result
		end
	end
end