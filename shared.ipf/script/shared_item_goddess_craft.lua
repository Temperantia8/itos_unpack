-- shared_item_goddess_craft.lua, 가디스 장비 제작/계승 관련

local function replace(text, to_be_replaced, replace_with)
	local retText = text
	local strFindStart, strFindEnd = string.find(text, to_be_replaced)	
    if strFindStart ~= nil then
		local nStringCnt = string.len(text)		
		retText = string.sub(text, 1, strFindStart-1) .. replace_with ..  string.sub(text, strFindEnd+1, nStringCnt)		
    else
        retText = text
	end
	
    return retText
end

local parameter_list = nil
function make_parameter_list()
	if parameter_list ~= nil then
		return
	end

	parameter_list = {}

	parameter_list[440] = {} -- 440제부터 계승 가능하므로 440부터 시작
	parameter_list[440]['INHERIT_ITEM_USELV'] = 460 -- 계승 대상 아이템 UseLv
	parameter_list[450] = {} -- 
	parameter_list[450]['INHERIT_ITEM_USELV'] = 470 -- 계승 대상 아이템 UseLv
end
make_parameter_list()

function GET_INHERIT_TARGET_ITEM_LV(lv)
	if parameter_list[lv] == nil then
		return nil
	end
	
	if parameter_list[lv]['INHERIT_ITEM_USELV'] == nil then
		return nil
	end
	
	return parameter_list[lv]['INHERIT_ITEM_USELV']
end

local item_goddess_inherit_target_list = nil

function setting_lv460_inherit_target_list(list_by_lv)
	list_by_lv[460]['Weapon'] = {
		'EP13_RAID_SWORD',
		'EP13_RAID_THSWORD',
		'EP13_RAID_STAFF',
		'EP13_RAID_THBOW',
		'EP13_RAID_BOW',
		'EP13_RAID_MACE',
		'EP13_RAID_THMACE',
		'EP13_RAID_SHIELD',
		'EP13_RAID_SPEAR',
		'EP13_RAID_THSPEAR',
		'EP13_RAID_DAGGER',
		'EP13_RAID_THSTAFF',
		'EP13_RAID_PISTOL',
		'EP13_RAID_RAPIER',
		'EP13_RAID_CANNON',
		'EP13_RAID_MUSKET',
		'EP13_RAID_TRINKET',
	}

	list_by_lv[460]['Armor'] = {
		'EP13_RAID_CLOTH_TOP',
		'EP13_RAID_CLOTH_LEG',
		'EP13_RAID_CLOTH_FOOT',
		'EP13_RAID_CLOTH_HAND',
		'EP13_RAID_LEATHER_TOP',
		'EP13_RAID_LEATHER_LEG',
		'EP13_RAID_LEATHER_FOOT',
		'EP13_RAID_LEATHER_HAND',
		'EP13_RAID_PLATE_TOP',
		'EP13_RAID_PLATE_LEG',
		'EP13_RAID_PLATE_FOOT',
		'EP13_RAID_PLATE_HAND',
	}
end

function setting_lv470_acc_inherit_target_list(list_by_lv)
	list_by_lv[470]['Neck'] = {
		'EP13_NECK06_HIGH_001',
		'EP13_NECK06_HIGH_002',
		'EP13_NECK06_HIGH_003',
		'EP13_NECK06_HIGH_004',
		'EP13_NECK06_HIGH_005',
		'EP13_NECK06_HIGH_006',		
	}

	list_by_lv[470]['Ring'] = {
		'EP13_BRC06_HIGH_001',
		'EP13_BRC06_HIGH_002',
		'EP13_BRC06_HIGH_003',
		'EP13_BRC06_HIGH_004',
		'EP13_BRC06_HIGH_005',
		'EP13_BRC06_HIGH_006',		
	}
end

function make_goddess_inherit_target_list()
	item_goddess_inherit_target_list = {}
	item_goddess_inherit_target_list[460] = {}
	item_goddess_inherit_target_list[470] = {}

	local list_by_lv = {}
	
	list_by_lv[460] = {}
	list_by_lv[460]['Weapon'] = {}
	list_by_lv[460]['Armor'] = {}
	setting_lv460_inherit_target_list(list_by_lv)
	list_by_lv[470] = {}
	list_by_lv[470]['Neck'] = {}
	list_by_lv[470]['Ring'] = {}
	setting_lv470_acc_inherit_target_list(list_by_lv)

	for lv, _ in pairs(item_goddess_inherit_target_list) do
		if list_by_lv[lv]['Weapon'] ~= nil then
			item_goddess_inherit_target_list[lv]['Weapon'] = list_by_lv[lv]['Weapon']
		end
		if list_by_lv[lv]['Armor'] ~= nil then
			item_goddess_inherit_target_list[lv]['Armor'] = list_by_lv[lv]['Armor']
		end
		if list_by_lv[lv]['Neck'] ~= nil then
			item_goddess_inherit_target_list[lv]['Neck'] = list_by_lv[lv]['Neck']
		end
		if list_by_lv[lv]['Ring'] ~= nil then
			item_goddess_inherit_target_list[lv]['Ring'] = list_by_lv[lv]['Ring']
		end
	end
end
make_goddess_inherit_target_list()

item_goddess_craft = {}

-- 기본 체크
item_goddess_craft.check_enable_inherit_item = function(item)
	-- 최소 레전드는 되어야 계승 가능
	local grade = TryGetProp(item, 'ItemGrade', 0)
	if grade < 5 then
		return false, 'NeedLegendGrade'
	end

	-- 440제 부터 계승 가능
	local use_lv = TryGetProp(item, 'UseLv', 1)
	if use_lv < 440 then
		return false, 'Need440UseLv'
	end

	local class_type = TryGetProp(item, 'ClassType', 'None')
	local is_acc = false
	if class_type == 'Neck' or class_type == 'Ring' then
		is_acc = true
	end
	
	if is_acc == true then
		if use_lv <= 450 then
			local trans_value = TryGetProp(item, 'Transcend', 0)
			if trans_value < 8 and use_lv <= 460 then
				return false, 'Need8Transcend'
			end	
		else
			if grade < 6 then
				return false, 'NeedGoddessGrade'
			end
		end
	else
		-- 8초월 이상만 가능
		local trans_value = TryGetProp(item, 'Transcend', 0)
		if trans_value < 8 and use_lv <= 460 then
			return false, 'Need8Transcend'
		end
	end

	-- 계승 대상 아이템 그룹이 존재하는가
	local target_lv = GET_INHERIT_TARGET_ITEM_LV(use_lv)	
	if target_lv == nil then		
		return false
	end

	if item_goddess_inherit_target_list[target_lv] == nil then		
		return false
	end
	
	-- 무기/방어구인지 체크
	local equip_group = TryGetProp(item, 'EquipGroup', 'None')
	
	
	if is_acc == true then
		if TryGetProp(item, 'UseLv', 0) <= 450 then
			if TryGetProp(item, 'CharacterBelonging', 0) ~= 1 then
				return false, 'CanExecCuzCharacterBelonging'
			end
			if TryGetProp(item, 'StringArg', 'None') ~= 'Luciferi' then
				return false, 'NeedLuciferiType'
			end
		else
			if TryGetProp(item, 'ItemGrade', 0) < 6 then
				return false, 'NeedGoddessGrade'			
			end
		end
	else
		if equip_group ~= 'Weapon' and equip_group ~= 'THWeapon' and equip_group ~= 'SubWeapon' then
			local _type_list = { 'SHIRT', 'PANTS', 'GLOVES', 'BOOTS' }
			local equip_type = TryGetProp(item, 'EqpType', 'None')
			if table.find(_type_list, equip_type) == 0 then			
				return false
			end
		end
	end
	
	return true
end

-- 레전드 아이템 체크
item_goddess_craft.check_enable_inherit_legend_item = function(item)
	-- 이벤트 장비는 바로 계승 가능
	local is_event_item = TryGetProp(item, 'EventItem', 0)	
	if is_event_item == 1 then		
		return true	
	end

	-- 이벤트 장비가 아니면 아이커가 없어야 함
	if IS_ENABLE_RELEASE_OPTION_2(item) == false then				
		return true
	end

	-- [EP12] 무기이면 고정 아이커 여부와 상관없이 계승 가능
	local eventType = TryGetProp(item, "EventType", "None")
	local equipGroup = TryGetProp(item, "EquipGroup", "None")	
	if SHARED_IS_EVENT_ITEM_CHECK(item, "EP12REWARD") == true then		
		if equipGroup == 'Weapon' or equipGroup == 'THWeapon' or equipGroup == 'SubWeapon' then
			return true
		end
	end
	
	return false
end

-- 계승 수치
item_goddess_craft.get_inherit_option_value = function(item)
	if item == nil then
		return nil
	end

	local grade = TryGetProp(item, 'ItemGrade', 0)
	local is_acc = false
	if TryGetProp(item, 'ClassType', 'None') == 'Neck' or TryGetProp(item, 'ClassType', 'None') == 'Ring' then
		is_acc = true
	end

	if is_acc == false and grade < 6 then
		local trans_value = TryGetProp(item, 'Transcend', 0)
		if trans_value < 10 then
			return nil
		end
	end

	local reinf_value = 0
	if is_acc == false and grade < 6 then
		reinf_value = TryGetProp(item, 'Reinforce_2', 0)
		reinf_value = math.floor(reinf_value * 2 / 3)
		if reinf_value > 14 then
			reinf_value = 14
		end
	else
		reinf_value = TryGetProp(item, 'Reinforce_2', 0)
		reinf_value = math.floor(reinf_value * 0.5)		
	end
	
	local enchant_name = TryGetProp(item, 'RandomOptionRare', 'None')
	local enchant_value = TryGetProp(item, 'RandomOptionRareValue', 0)
	-- 이동속도/광공비 체크해서 해당 옵션이면 3일 경우에만 2로 계승, 그 외에는 제거
	if enchant_name == 'RareOption_MSPD' or enchant_name == 'RareOption_SR' then
		if enchant_value < 2 then
			enchant_name = 'None'
			enchant_value = 0
		elseif enchant_value == 2 then
			enchant_value = 1
		elseif enchant_value == 3 then
			enchant_value = 2
		end
	else
		enchant_value = math.floor(enchant_value * 2 / 3)
	end

	return reinf_value, enchant_name, enchant_value
end

-- 계승 가능 대상 목록
item_goddess_craft.get_inherit_target_item_list = function(item)
	if item == nil then
		return nil
	end

	local use_lv = TryGetProp(item, 'UseLv', 1)
	local target_lv = GET_INHERIT_TARGET_ITEM_LV(use_lv)
	if target_lv == nil then		
		return nil
	end

	if item_goddess_inherit_target_list[target_lv] == nil then	
		return nil
	end

	local group_name = TryGetProp(item, 'GroupName', 'None')
	if group_name == 'SubWeapon' then
		group_name = 'Weapon'
	end

	-- 방패 예외 처리
	local class_type = TryGetProp(item, 'ClassType', 'None')
	if class_type == 'Shield' then
		group_name = 'Weapon'
	end

	local is_acc = false
	if class_type == 'Neck' or class_type == 'Ring' then
		group_name = class_type
		is_acc = true
	end
	
	if item_goddess_inherit_target_list[target_lv][group_name] == nil then		
		return nil
	end

	if is_acc == false then
		return item_goddess_inherit_target_list[target_lv][group_name]
	else
		-- 액세서리는 같은 종류로만 가능하다
		local name = TryGetProp(item, 'ClassName', 'None')
		if name == 'None' then
			return nil
		end

		local token = StringSplit(name, '_')
		local suffix = ''
		for i = 2, #token do
			if i ~= #token then
				suffix = suffix .. token[i] .. '_'
			else
				suffix = suffix .. token[i]
			end
		end
		
		local ret = {}
		for k, v in pairs(item_goddess_inherit_target_list[target_lv][group_name]) do
			local token2 = StringSplit(v, '_')
			local suffix2= ''
			for i = 2, #token2 do
				if i ~= #token2 then
					suffix2 = suffix2 .. token2[i] .. '_'
				else
					suffix2 = suffix2 .. token2[i]
				end
			end

			if suffix == suffix2 then
				table.insert(ret, v)
			end
		end
		return ret
	end
end

item_goddess_craft.is_able_to_convert = function(mat_item, targetGruop)	
	if targetGruop == nil then
		return false, 'IMPOSSIBLE_ITEM'
	end

	if IS_EXCHANGE_WEAPONTYPE(targetGruop, TryGetProp(mat_item, 'ClassName', 'None')) == false then
        return false, 'IMPOSSIBLE_ITEM'
	end


	return true, 'None'
end

-- 바실리사 장비 귀속 해제
item_goddess_craft.is_able_to_unlock_vasilisa = function(scrollObj, itemObj)
	if TryGetProp(itemObj, 'CharacterBelonging', 0) == 0 then		
		return false, 'OnlyUseBelongingItem'
	end


	if TryGetProp(scrollObj, 'StringArg', 'None') ~= 'unlock_vasilisa_belonging' then
		return false, 'NotValidItem'
	end

	if TryGetProp(itemObj, 'StringArg', 'None') ~= 'Goddess_Vasilisa' then
		return false, 'NotValidItem'
	end
    
    return true, 'None'
end
-- 아크 스크롤 추출
item_goddess_craft.is_able_to_decompose_ark = function(scrollObj, itemObj)
	if TryGetProp(itemObj, 'CharacterBelonging', 0) == 0 then		
		return false, 'OnlyFromCabinetItemUsable'
	end

	if TryGetProp(scrollObj, 'StringArg', 'None') ~= 'ark_decomposition_scroll' then
		return false, 'NotValidItem'
	end

	if TryGetProp(itemObj, 'GroupName', 'None') ~= 'Ark' then
		return false, 'NotValidItem'
	end

	if TryGetProp(itemObj, 'ArkLevel', 0) ~= 10 then
		return false, 'NotValidItem'
	end
    
    return true, 'None'
end
-- 가디스 액세서리 귀속 해제
item_goddess_craft.is_able_to_unlock_acc = function(scrollObj, itemObj)
	if TryGetProp(itemObj, 'CharacterBelonging', 0) == 0 then		
		return false, 'OnlyUseBelongingItem'
	end


	if TryGetProp(scrollObj, 'StringArg', 'None') ~= 'unlock_acc_belonging' then
		return false, 'NotValidItem'
	end

	if TryGetProp(itemObj, 'ItemGrade', 0) ~= 6 then
		return false, 'NotValidItem'
	end

	local scroll_lv = TryGetProp(scrollObj, 'NumberArg1', 0)
	local item_lv = TryGetProp(itemObj, 'UseLv', 0)
	local class_type = TryGetProp(itemObj, 'ClassType', 'None')
	if class_type ~= 'Neck' and class_type ~= 'Ring' then
		return false , 'NotValidItem'
	end
	
	if scroll_lv < item_lv then
		return false, 'NotValidItem'
	end
    
    return true, 'None'
end
