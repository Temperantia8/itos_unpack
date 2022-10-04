function GET_LIMITATION_TO_BUY(tpItemID)
    local tpItemObj = GetClassByType('TPitem', tpItemID);
    if IS_SEASON_SERVER() == 'YES' then
        tpItemObj = GetClassByType('TPitem_SEASON', tpItemID);
    end
    
    if tpItemObj == nil then
        return 'NO', 0;
    end

    local accountLimitCount = TryGetProp(tpItemObj, 'AccountLimitCount');
    if accountLimitCount ~= nil and accountLimitCount > 0 then
        return 'ACCOUNT', accountLimitCount;
    end

    local monthLimitCount = TryGetProp(tpItemObj, 'MonthLimitCount');    
    if monthLimitCount ~= nil and monthLimitCount > 0 then
        return 'MONTH', monthLimitCount;
    end

    local weeklyCount = TryGetProp(tpItemObj, 'AccountLimitWeeklyCount', 0)    
    if weeklyCount > 0 then
        return 'WEEKLY', weeklyCount
    end

    local customCount = TryGetProp(tpItemObj, 'AccountLimitCustomCount', 0)    
    if customCount > 0 then
        return 'CUSTOM', customCount
    end

    return 'NO', 0;
end

function GET_LIMITATION_TO_BUY_WITH_SHOPTYPE(tpItemID, shopType)
    local tpItemObj = nil
    -- shopType normal(0), return User(1), newbie(2)
    if shopType == 1 then
        tpItemObj = GetClassByType('TPitem_Return_User', tpItemID);
    elseif shopType == 2 then
        tpItemObj = GetClassByType('TPitem_User_New', tpItemID);
    else
        tpItemObj = GetClassByType('TPitem', tpItemID);
        if IS_SEASON_SERVER() == 'YES' then
            tpItemObj = GetClassByType('TPitem_SEASON', tpItemID);
        end
    end
    
    if tpItemObj == nil then
        return 'NO', 0;
    end
    
    local accountLimitCount = TryGetProp(tpItemObj, 'AccountLimitCount');
    if accountLimitCount ~= nil and accountLimitCount > 0 then
        return 'ACCOUNT', accountLimitCount;
    end

    local monthLimitCount = TryGetProp(tpItemObj, 'MonthLimitCount');
    if monthLimitCount ~= nil and monthLimitCount > 0 then
        return 'MONTH', monthLimitCount;
    end

    local weeklyCount = TryGetProp(tpItemObj, 'AccountLimitWeeklyCount', 0)
    if weeklyCount > 0 then
        return 'WEEKLY', weeklyCount
    end

    local customCount = TryGetProp(tpItemObj, 'AccountLimitCustomCount', 0)    
    if customCount > 0 then
        return 'CUSTOM', customCount
    end

    return 'NO', 0;
end

itemOptCheckTable = nil;
function CREATE_ITEM_OPTION_TABLE()
    --추가할 프로퍼티가 존재한다면 밑에다가 추가하면 됨.
    itemOptCheckTable = {
    "Reinforce_2", -- 강화
    "Transcend", -- 초월
    "IsAwaken", -- 각성
    "RandomOptionRareValue",
    }
end

function IS_MECHANICAL_ITEM(itemObject)
    if itemOptCheckTable == nil then
        CREATE_ITEM_OPTION_TABLE();
    end

    if itemOptCheckTable == nil or #itemOptCheckTable == 0 then
        return false;
    end 

    for i = 1, #itemOptCheckTable do
        local itemProp = TryGetProp(itemObject, itemOptCheckTable[i]);
        if itemProp ~= nil then
            if itemProp > 0 then
                return true;
            end
        end
    end

    local maxSocketCnt = TryGetProp(itemObject, 'MaxSocket', 0);
    if maxSocketCnt > 0 then
        if IsServerSection() == 0 then
            local invitem = GET_INV_ITEM_BY_ITEM_OBJ(itemObject);
            if invitem == nil then
                return false;
            end

            if itemObject.MaxSocket > 100 then itemObject.MaxSocket = 0 end
            for i = 0, itemObject.MaxSocket - 1 do
                if invitem:IsAvailableSocket(i) == true then
                    return true;
                end                
            end
        else
            if itemObject.MaxSocket > 100 then itemObject.MaxSocket = 0 end
            for i = 0, itemObject.MaxSocket - 1 do
                local equipGemID = GetItemSocketInfo(itemObject, i);
                if equipGemID ~= nil then
                    return true;
                end
            end
        end    
    end

    return false;
end

function GET_COMMON_SOCKET_TYPE()
	return 5;
end

local _anitiqueCache = {}; -- key: itemClassName, value: groupKey
local function _RETURN_ANTIQUE_INFO(itemClassName, groupKey, group, exchangeItemList, giveItemList, giveItemCntList, matItemList, matItemCntList)
    if groupKey == nil then
        return nil;
    end

    local anitiqueCacheKey = group..'_'..itemClassName;
    _anitiqueCache[anitiqueCacheKey] = groupKey;
    local giveList = {};
    for i = 1, #giveItemList do
        giveList[#giveList + 1] = {
            Name = giveItemList[i],
            Count = giveItemCntList[i]
        };
    end

    local matList = {};
    for i = 1, #matItemList do
        matList[#matList + 1] = {
            Name = matItemList[i],
            Count = matItemCntList[i]
        };
    end

    return {
        GroupKey = groupKey,
        ExchangeGroup = group,
        AddGiveItemList = giveList,
        ExchangeItemList = exchangeItemList,
        MatItemList = matList,
    };
end

function GET_EXCHANGE_ANTIQUE_INFO(exchangeGroupName, itemClassName)
    if itemClassName == nil then
        return nil;
    end

    local anitiqueCacheKey = exchangeGroupName..'_'..itemClassName;
    if _anitiqueCache[anitiqueCacheKey] ~= nil then
        return _RETURN_ANTIQUE_INFO(itemClassName, GetExchangeAntiqueInfoByGroupKey(_anitiqueCache[anitiqueCacheKey]));
    end
    return _RETURN_ANTIQUE_INFO(itemClassName, GetExchangeAntiqueInfoByItemName(exchangeGroupName, itemClassName));
end

function IS_ENABLE_EXCHANGE_ANTIQUE(srcItem, dstItem)
    if srcItem == nil or dstItem == nil then
        return false;
    end
    
    if srcItem.ClassID == dstItem.ClassID then
        return false;
    end

    if dstItem.ClassName == 'CAN05_101' or dstItem.ClassName == 'CAN05_102' then
        return false;
    end
    return true;
end

-- exchangeWeaponType : Check Data
function IS_EXCHANGE_WEAPONTYPE(exchangeGroupName, itemClassName)
    if exchangeGroupName == nil or itemClassName == nil then
        return false;
    end

    return IsExchangeWeaponType(exchangeGroupName, itemClassName);
end

-- exchangeWeaponType : Get Material / return materialNameList, materialCountList
function GET_EXCHANGE_WEAPONTYPE_MATERIAL(exchangeGroupName, itemClassName)
    if exchangeGroupName == nil or itemClassName == nil then
        return nil, nil;
    end

    return GetExChangeMeterialList(exchangeGroupName, itemClassName);
end

-- exchangeWeaponType : exchange enable check
function IS_ENABLE_EXCHANGE_WEAPONTYPE(scrItem, destItemID)
    if scrItem == nil or destItemID == nil then 
        return false; 
    end

    if scrItem.ClassID == destItemID then 
        return false; 
    end
    
    local scrItemGroup = TryGetProp(scrItem, "ExchangeGroup", "None");
    if IsExchangeWeaponType(scrItemGroup, scrItem.ClassName) == false or IsExchangeWeaponTypeByClassID(destItemID) == false then 
        return false; 
    end
    return true;
end

function IS_ICOR_ITEM(item)
	if TryGetProp(item, 'GroupName', 'None') == 'Icor' then
		return true;
	end
	return false;
end

function GET_GEM_PROTECT_NEED_COUNT(gemObj)
    if gemObj == nil then
        return 999999
    end
    
    local lv = TryGetProp(gemObj, "NumberArg1", 0)
    local cls = GetClassByType("item_gem_Extract_Protect", lv)
    return TryGetProp(cls, 'NeedCount', 999999)
end

function SCR_PRECHECK_TEST_DUMMY_SCR_USE_SCROLL(self)
    if OnKnockDown(self) == 'YES' then
        return 0;
	end
	
	local currentZone = GetZoneName(self)
	if currentZone ~= "c_Klaipe" and currentZone ~= "c_orsha" and currentZone ~= "c_fedimian" then
		SendAddOnMsg(self, "NOTICE_Dm_!", ScpArgMsg("AllowedInTown"), 3);
		return 0;
	end

	if IsMyPCFriendlyFighting(self) == 1 then
		SendAddOnMsg(self, "NOTICE_Dm_!", ScpArgMsg("Card_Summon_check_PVP"), 3);
		return 0;
	end

	local sObj = GetSessionObject(self, 'ssn_klapeda')
	if sObj == nil then
		return 0;
	end
	return 1;
end

-- goddess
function GET_GODDESS_EVOLVED_EFFECT_FACTOR_OFFSET(item_cls)
    local factor_offset = 0.0;
    if item_cls ~= nil then
        local item_class_name = TryGetProp(item_cls, "ClassName", "None");
        if item_class_name == "EP13_Artefact_040" then
            factor_offset = 4.0;
        elseif item_class_name == "EP13_Artefact_039" then
            factor_offset = 4.0;
        elseif item_class_name == "EP13_Artefact_047" then
            factor_offset = 2.0;
        end
    end
    return factor_offset;
end

function SET_GODDESS_EVOLVED_EFFECT_INFO(self, guid, equip)
    if IsServerSection() == 1 then
        if equip == true then
            local factor_offset = 0.0;
            local item = GetEquipItemByGuid(self, guid);
            if item ~= nil then
                local briquetting_index = TryGetProp(item, "BriquettingIndex", 0);
                if briquetting_index > 0 then
                    local briquetting_item_cls = GetClassByType("Item", briquetting_index);
                    if briquetting_item_cls ~= nil then
                        factor_offset = GET_GODDESS_EVOLVED_EFFECT_FACTOR_OFFSET(briquetting_item_cls);
                    end
                end
            end
            SetAuraInfoByItem(self, guid, "Goddess_Evolved_Color_Green", factor_offset);
        else
            SetAuraInfoByItem(self, guid, "");
        end
    end
end

-- dress room
function IS_REGISTER_ENABLE_COSTUME(item)
    if item == nil then
        return false
    end

    if TryGetProp(item, "TeamBelonging", 0) == 1 then
        return false, "CantRegisterCuzTeamBelonging"
    end

    return true
end