function LEGENDCARD_GET_REINFORCE_CLASS(cardLv,reinforceType,namespace)
	local legendCardReinforceList, cnt = GetClassList(namespace)
	for i = 0, cnt - 1 do
		local cls = GetClassByIndexFromList(legendCardReinforceList,i);
		if cardLv == TryGetProp(cls, "CardLevel") and reinforceType == TryGetProp(cls, "ReinforceType") then
			return cls
		end
	end
	return nil
end

function LEGENDCARD_REINFORCE_GET_MAIN_CARD_NAMESPACE(obj)
	if obj.CardGroupName == nil then
		return nil
	end
	if obj.CardGroupName == 'LEG' then
		return "legendCardReinforce"
	elseif obj.CardGroupName == 'GODDESS' then
		return "goddessCardReinforce"
	elseif obj.CardGroupName == 'REINFORCE_GODDESS_CARD' then
		return "goddessCardReinforce"
	end
	return nil
end

function LEGENDCARD_REINFORCE_GET_MATERIAL_CARD_NAMESPACE(mainObj,materialObj)
	if mainObj == nil or mainObj.CardGroupName == nil then
		return nil
	end
	if materialObj.CardGroupName == nil then
		return nil
	end
	if mainObj.CardGroupName == 'LEG' then
		local validTypeList = {"LegendCard","Card","ReinForceCard"}
		-- 레티샤의 강화용 보루타 카드
		for i = 1,8 do
			local reinforceType = string.format("ReinForceCard_Leticia_Lv%s",i)
			table.insert(validTypeList,reinforceType)
		end
		if table.find(validTypeList,materialObj.Reinforce_Type) ~= 0 then
			return "legendCardReinforce"
		end
	elseif mainObj.CardGroupName == 'GODDESS' then
		local validTypeList = {"GoddessReinForceCard"}
		if table.find(validTypeList,materialObj.Reinforce_Type) ~= 0 then
			return "goddessCardReinforce"
		end
	elseif mainObj.CardGroupName == 'REINFORCE_GODDESS_CARD' then
		local validTypeList = {"GoddessReinForceCard","LegendCard"}
		if table.find(validTypeList,materialObj.Reinforce_Type) ~= 0 then
			return "goddessCardReinforce"
		end
	end
	
	return nil
end


function CALC_LEGENDCARD_REINFORCE_PERCENTS(legendCardObj,materialCardObjList)
	if legendCardObj == nil then
		return 0,0,0
	end

	local legendCardType = TryGetProp(legendCardObj, 'Reinforce_Type')
	local legendCardLv = GET_ITEM_LEVEL(legendCardObj)
	local namespace = LEGENDCARD_REINFORCE_GET_MAIN_CARD_NAMESPACE(legendCardObj)
	local legendCardCls = LEGENDCARD_GET_REINFORCE_CLASS(legendCardLv,legendCardType,namespace)
	local needPoint = TryGetProp(legendCardCls, "NeedPoint",0)
	local totalGivePoint = 0

	for i = 1,#materialCardObjList do
		local materialCardObj = materialCardObjList[i]
		local materialType = materialCardObj.Reinforce_Type
		local materialCardLv = GET_ITEM_LEVEL(materialCardObj)
		local matterialNamespace = LEGENDCARD_REINFORCE_GET_MATERIAL_CARD_NAMESPACE(legendCardObj,materialCardObj)
		local materialCls = LEGENDCARD_GET_REINFORCE_CLASS(materialCardLv,materialType,matterialNamespace)
		local givePoint = TryGetProp(materialCls, "GivePoint",0)
		if materialCls.ReinforceType == "LegendCard" and legendCardCls.ReinforceType == "GoddessCard" then
			givePoint = 0
		end
		totalGivePoint = totalGivePoint + givePoint
	end

	local givePerNeedPoint = 0
	if needPoint ~= 0 then
		givePerNeedPoint = totalGivePoint / needPoint
	end
	
	local successPercent = math.floor(givePerNeedPoint * 100 + 0.5)
	local failPercent = math.floor((1 - givePerNeedPoint) * 0.4 * 100 + 0.5)
	local brokenPercent = 100 - (successPercent + failPercent)

	if givePerNeedPoint >= 0.995 then
		successRatio = 100
	end
	

	successPercent = math.max(0,math.min(100,successPercent))
	failPercent = math.max(0,math.min(100,failPercent))
	brokenPercent = math.max(0,math.min(100,brokenPercent))

	return successPercent, failPercent, brokenPercent, needPoint, totalGivePoint
end

function GET_CARD_REINFORCE_NEED_ITEM_STRARG(cls,cardObj)
	return cardObj.StringArg
end

-- 여신카드 경험치 복사
function IS_GODDESS_LEGEND_CARD(item)
	if item == nil then
		return false
	end

	if TryGetProp(item, 'EquipXpGroup', 'None') == 'Goddess_Card' then
		return true
	end

	return false
end

function IS_VALID_COND_LEGEND_GODDESS_CARD(src, target)
	if IS_GODDESS_LEGEND_CARD(src) == false or IS_GODDESS_LEGEND_CARD(target) == false then
		return false, 'NotGoddessCard'
	end

	if TryGetProp(src, 'ClassName', 'None') ~= TryGetProp(target, 'ClassName', 'None') then
		return false, 'OnlySameCardType'
	end

	local lv = GET_ITEM_LEVEL(src)

	if lv < 2 then
		return false, 'LessLevelofSourceCard'
	end

	local target_lv = GET_ITEM_LEVEL(target)
	if target_lv >= lv then
		return false, 'GreaterLevelofTargetCardThanSourceCard'
	end

	return true, 'None'
end

function GET_COPY_COST_LEGEND_GODDESS_CARD(src)
	if IS_GODDESS_LEGEND_CARD(src) == true then
		local lv = GET_ITEM_LEVEL(src)
		if lv > 1 then
			return 'REPUTATION_COIN_EP13', lv * 1000
		end
	end

	return 'None', 999999999
end
-- end of 여신카드 경험치 복사