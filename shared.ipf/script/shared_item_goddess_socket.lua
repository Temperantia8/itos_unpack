-- shared_item_goddess_socket.lua, 가디스 장비 소켓 관련

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

	parameter_list[460] = {} -- 460레벨용
	parameter_list[460]['MAX_NORMAL_SOCKET_COUNT'] = 2 -- 에테르 젬 소켓 최대 개수
	parameter_list[460]['MAX_AETHER_SOCKET_COUNT'] = 1 -- 에테르 젬 소켓 최대 개수
end
make_parameter_list()

function GET_MAX_GODDESS_NORMAL_SOCKET_COUNT(lv)
	if parameter_list[lv] == nil then
		return 2
	end

	if parameter_list[lv]['MAX_NORMAL_SOCKET_COUNT'] == nil then
		return 2
	else
		return parameter_list[lv]['MAX_NORMAL_SOCKET_COUNT']
	end
end

function GET_MAX_GODDESS_AETHER_SOCKET_COUNT(lv)
	if parameter_list[lv] == nil then
		return 1
	end

	if parameter_list[lv]['MAX_AETHER_SOCKET_COUNT'] == nil then
		return 1
	else
		return parameter_list[lv]['MAX_AETHER_SOCKET_COUNT']
	end
end

function GET_EQUIP_GEM_TYPE(gem)
	if gem == nil then
		return nil
	end

	local group_name = TryGetProp(gem, 'GroupName', 'None')
	if group_name == 'Gem' then
		local str_arg = TryGetProp(gem, 'StringArg', 'None')
		if str_arg == 'SkillGem' then
			return 'skill'
		else
			return 'normal'
		end
	elseif group_name == 'Gem_High_Color' then
		return 'aether'
	end

	return nil
end

item_goddess_socket = {}

local item_goddess_normal_socket_material_list = nil

function setting_lv460_normal_socket_material(mat_list_by_lv)
	local season_coin = 'GabijaCertificate' -- 여신의 증표(가비야)

	mat_list_by_lv[460][1][season_coin] = 450

	mat_list_by_lv[460][2][season_coin] = 1050
end

function make_item_goddess_normal_socket_material_list()
	if item_goddess_normal_socket_material_list ~= nil then
		return
	end

	item_goddess_normal_socket_material_list = {}
	item_goddess_normal_socket_material_list[460] = {}

	local classtype_list = {}
	table.insert(classtype_list, 'Sword')
	table.insert(classtype_list, 'THSword')
	table.insert(classtype_list, 'Staff')
	table.insert(classtype_list, 'THStaff')
	table.insert(classtype_list, 'Bow')
	table.insert(classtype_list, 'THBow')
	table.insert(classtype_list, 'Mace')
	table.insert(classtype_list, 'THMace')
	table.insert(classtype_list, 'Spear')
	table.insert(classtype_list, 'THSpear')	

	table.insert(classtype_list, 'Rapier')
	table.insert(classtype_list, 'Cannon')
	table.insert(classtype_list, 'Musket')
	table.insert(classtype_list, 'Dagger')
	table.insert(classtype_list, 'Pistol')
	table.insert(classtype_list, 'Shield')
	table.insert(classtype_list, 'Trinket')

	table.insert(classtype_list, 'Gloves')
	table.insert(classtype_list, 'Boots')
	table.insert(classtype_list, 'Pants')
	table.insert(classtype_list, 'Shirt')

	for lv, v1 in pairs(item_goddess_normal_socket_material_list) do
		for _, class_type in pairs(classtype_list) do
			item_goddess_normal_socket_material_list[lv][class_type] = {}
			for i = 1, GET_MAX_GODDESS_NORMAL_SOCKET_COUNT(lv) do
				item_goddess_normal_socket_material_list[lv][class_type][i] = {}
			end
		end
	end

	local mat_list_by_lv = {}
	mat_list_by_lv[460] = {}
	for i = 1, GET_MAX_GODDESS_NORMAL_SOCKET_COUNT(460) do
		mat_list_by_lv[460][i] = {}
	end
	setting_lv460_normal_socket_material(mat_list_by_lv)

	for class_type, v in pairs(item_goddess_normal_socket_material_list[460]) do		
		for lv, dic in pairs(v) do			
			for i = 1, GET_MAX_GODDESS_NORMAL_SOCKET_COUNT(460) do
				item_goddess_normal_socket_material_list[460][class_type][i] = mat_list_by_lv[460][i]
			end
		end
	end
end

make_item_goddess_normal_socket_material_list()

item_goddess_socket.get_normal_socket_material_list = function(use_lv, class_type, index)
	if item_goddess_normal_socket_material_list[use_lv] == nil then
		return nil
	end

	if item_goddess_normal_socket_material_list[use_lv][class_type] == nil then
		return nil
	end

	return item_goddess_normal_socket_material_list[use_lv][class_type][index + 1]
end

-- 에테르 젬 소켓 개방용 아이템 체크
item_goddess_socket.is_aether_socket_material = function(item)
	if item == nil then
		return false
	end

	local str_arg = TryGetProp(item, 'StringArg', 'None')
	if str_arg == 'Ether_Gem_Socket' then
		return true
	end

	return false
end

-- 확장 가능한 일반 소켓 인덱스인가
item_goddess_socket.enable_normal_socket_add = function(item, index)
	if item == nil then
		return false
	end

	local lv = TryGetProp(item, 'UseLv', 0)
	if lv < 460 then
		return false
	end

	local grade = TryGetProp(item, 'ItemGrade', 0)
	if grade < 6 then
		return false
	end

	local normal_max_cnt = GET_MAX_GODDESS_NORMAL_SOCKET_COUNT(lv)
	if index >= normal_max_cnt then
		return false
	end

	if IsServerSection() == 1 then
		local normal_max_gem_id = GetItemSocketInfo(item, index)
		if normal_max_gem_id ~= nil then
			return false
		end
	else
		local inv_item = GET_INV_ITEM_BY_ITEM_OBJ(item)
		if inv_item:IsAvailableSocket(index) == true then
			return false
		end
	end

	return true
end

-- 에테르 젬 소켓 개방 가능한 상태인가
item_goddess_socket.enable_aether_socket_add = function(item)
	if item == nil then
		return false
	end

	-- 에테르 젬 소켓은 무기류만 허용
	local equip_group = TryGetProp(item, 'EquipGroup', 'None')
	if equip_group ~= 'Weapon' and equip_group ~= 'SubWeapon' and equip_group ~= 'THWeapon' then
		return false
	end

	local grade = TryGetProp(item, 'ItemGrade', 0)
	local lv = TryGetProp(item, 'UseLv', 0)
	if lv < 460 or grade < 6 then
		return false
	end

	local normal_max_cnt = GET_MAX_GODDESS_NORMAL_SOCKET_COUNT(lv)
	local full_normal_socket = false -- 일반 소켓 최대 개방 상태인가
	local enable_aether_socket = false -- 에테르 젬 소켓 개방 상태인가
	if IsServerSection() == 1 then
		local normal_max_gem_id = GetItemSocketInfo(item, normal_max_cnt - 1)
		if normal_max_gem_id ~= nil then
			full_normal_socket = true
		end
		
		local aether_gem_id = GetItemSocketInfo(item, normal_max_cnt)
		if aether_gem_id ~= nil then
			enable_aether_socket = true
		end
	else
		local inv_item = GET_INV_ITEM_BY_ITEM_OBJ(item)
		full_normal_socket = inv_item:IsAvailableSocket(normal_max_cnt - 1)
		enable_aether_socket = inv_item:IsAvailableSocket(normal_max_cnt)
	end
	
	-- 일반 소켓 최대 개방 && 에테르 젬 아직 개방 안한 상태만 허용
	if full_normal_socket == false or enable_aether_socket == true then
		return false
	end

	return true
end

-- 장착 가능한 일반 젬인가
item_goddess_socket.check_equipable_normal_gem = function(item, gem, index)
	local use_lv = TryGetProp(item, 'UseLv', 0)
	-- 슬롯 인덱스 체크
    if index >= GET_MAX_GODDESS_NORMAL_SOCKET_COUNT(use_lv) then
        return false
	end

	local gem_type = GET_EQUIP_GEM_TYPE(gem)
	if gem_type == nil or gem_type == 'aether' then
		return false
	end

	-- 무기 - 컬러 젬, 방어구 - 스킬 젬
	local group_name = TryGetProp(item, 'GroupName', 'None')
	local equip_group = TryGetProp(item, 'EquipGroup', 'None')
	if (equip_group == 'Weapon' or equip_group == 'SubWeapon' or equip_group == 'THWeapon') and gem_type == 'normal' then
		return true
	end

	if equip_group ~= 'SubWeapon' and group_name == 'Armor' and gem_type == 'skill' then
		return true
	end
	
	return false
end

-- 장착 가능한 에테르 젬인가
item_goddess_socket.check_equipable_aether_gem = function(item, gem, index)
	local use_lv = TryGetProp(item, 'UseLv', 0)
	-- 슬롯 인덱스 체크
	if index < GET_MAX_GODDESS_NORMAL_SOCKET_COUNT(use_lv) then
        return false
	end

	local gem_type = GET_EQUIP_GEM_TYPE(gem)
	if gem_type == nil or gem_type ~= 'aether' then
		return false
	end

	-- 무기에만 장착 가능
	local equip_group = TryGetProp(item, 'EquipGroup', 'None')
	if equip_group ~= 'Weapon' and equip_group ~= 'SubWeapon' and equip_group ~= 'THWeapon' then
		return false
	end
	
	-- NumberArg1값으로 대상 장비 UseLv 값 체크
	local gem_num_arg = TryGetProp(gem, 'NumberArg1', 0)
	if gem_num_arg ~= use_lv then
		return false
	end

	return true
end

-- 스킬 젬 추출 패널티 제거 케어 기간 입력
function IS_GEM_EXTRACT_CARE_20211125()
	local startTimeStr = "2021-12-29 09:00:00"
	local endTimeStr = "2022-02-16 08:59:59"
	
	return date_time.is_between_time(startTimeStr, endTimeStr)
end