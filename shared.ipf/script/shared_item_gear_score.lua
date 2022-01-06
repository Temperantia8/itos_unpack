-- shared_item_gear_score.lua

local check_slot_list = nil
local enchant_option_max_value = nil

function GET_RANDOM_ICOR_PORTION(item)
    if item == nil then
        return 0
    end

    local max = 4
    local cnt = 1
    local portion = 0
    for i = 1, 6 do
        if cnt > max then
            break
        end

        local name = TryGetProp(item, 'RandomOption_'..i, 'None')        
        if name ~= 'None' then			
            local value = TryGetProp(item, 'RandomOptionValue_'..i, 0)
            cnt = cnt + 1
            local _, max_value = GET_RANDOM_OPTION_VALUE_VER2(item, name)
            if max_value == nil or TryGetProp(item, 'UseLv', 1) < 430 then                
                max_value = 2000
            end
            
            if max_value <= 0 then
                max_value = 2000
            end
            local diff = (value / max_value)
            if diff < 0 then
                diff = 0
            end
            if diff > 1 then
                diff = 1
            end
            portion = portion + diff * 100
		end
    end
    
    return math.floor(portion / max + 0.5) / 100
end

function GET_ENCHANT_OPTION_PORTION(item)
    if item == nil then
        return 0
    end
    
    if enchant_option_max_value == nil then
        enchant_option_max_value = {}
        enchant_option_max_value['RareOption_MainWeaponDamageRate'] = 150
        enchant_option_max_value['RareOption_BossDamageRate'] = 150
        enchant_option_max_value['RareOption_PVPDamageRate'] = 150
        enchant_option_max_value['RareOption_CriticalDamage_Rate'] = 150

        enchant_option_max_value['RareOption_MagicReducedRate'] = 250
        enchant_option_max_value['RareOption_MeleeReducedRate'] = 250
        enchant_option_max_value['RareOption_PVPReducedRate'] = 250

        enchant_option_max_value['RareOption_CriticalHitRate'] = 250
        enchant_option_max_value['RareOption_CriticalDodgeRate'] = 250
        enchant_option_max_value['RareOption_HitRate'] = 250
        enchant_option_max_value['RareOption_DodgeRate'] = 250
        enchant_option_max_value['RareOption_BlockBreakRate'] = 250
        enchant_option_max_value['RareOption_BlockRate'] = 250

        enchant_option_max_value['RareOption_MSPD'] = 3
        enchant_option_max_value['RareOption_SR'] = 3
    end

    local portion = 0

    local name = TryGetProp(item, 'RandomOptionRare', 'None')    
    if name ~= 'None' then			
        local value = TryGetProp(item, 'RandomOptionRareValue', 0)
        local max_value = enchant_option_max_value[name]
        if max_value == nil then
            max_value = 250
        end
        
        local diff = (value / max_value)
        if diff < 0 then
            diff = 0
        end
        if diff > 1 then
            diff = 1
        end

        portion = diff * 100        
    end    
    
    return math.floor(portion + 0.5) / 100
end

function GET_GEAR_SCORE(item, pc)
    if TryGetProp(item, 'StringArg', 'None') == 'WoodCarving' then 
        return 0
    end

    if TryGetProp(item, 'GroupName', 'None') == 'Arcane' then
        return 0
    end

    if TryGetProp(item, 'StringArg', 'None') == 'TOSHeroEquip' then
        return 0
    end

	if string.find(TryGetProp(item, 'EnableEquipMap', 'None'), 'TOSHero_Straight') then
		return 0
	end

    if check_slot_list == nil then
        check_slot_list = {}
        check_slot_list['RING'] = 1
        check_slot_list['NECK'] = 1

        check_slot_list['SHIRT'] = 1
        check_slot_list['GLOVES'] = 1
        check_slot_list['BOOTS'] = 1
        check_slot_list['PANTS'] = 1
        check_slot_list['RH'] = 1
        check_slot_list['LH'] = 1
        check_slot_list['LH_SUB'] = 1
        check_slot_list['RH_SUB'] = 1
        check_slot_list['RH LH'] = 1
        check_slot_list['LH RH'] = 1

        check_slot_list['SEAL'] = 1
        check_slot_list['ARK'] = 1        
        --check_slot_list['RELIC'] = 1        
    end

    local type = TryGetProp(item, 'DefaultEqpSlot', 'None')
    local transcend = TryGetProp(item, 'Transcend', 0)
    local reinforce = TryGetProp(item, 'Reinforce_2', 0)
    local grade = TryGetProp(item, 'ItemGrade', 1)
    local use_lv = TryGetProp(item, 'UseLv', 1)
    local item_lv = TryGetProp(item, 'EvolvedItemLv', 0)

    use_lv = math.max(use_lv, item_lv)

    if check_slot_list[type] == nil then        
        return 0
    end

    local is_sub_slot = false
    if IsServerSection() == 1 then
        local guid = GetIESID(item)
        local sub = GetEquipItem(pc, 'LH_SUB');
        if sub ~= nil and GetIESID(sub) == guid then
            is_sub_slot = true
        end
        sub = GetEquipItem(pc, 'RH_SUB');
        if sub ~= nil and GetIESID(sub) == guid then
            is_sub_slot = true
        end        
    else        
        local guid = GetIESID(item)
        local sub = session.GetEquipItemBySpot(ES_LH_SUB)
        if sub ~= nil and sub:GetIESID() == guid then	
            is_sub_slot = true
        end

        sub = session.GetEquipItemBySpot(ES_RH_SUB)
        if sub ~= nil and sub:GetIESID() == guid then	
            is_sub_slot = true
        end        
    end


    if type == 'SEAL' then
        reinforce = GET_CURRENT_SEAL_LEVEL(item)        
        local ret = ((0.7 *(100*reinforce))+((1100*grade)+(1*use_lv)) * 0.3)*0.26        
        return math.floor(ret + 0.5)
    elseif type == 'RELIC' then        
        return 0
    elseif type == 'ARK' then
        local ark_lv = TryGetProp(item, 'ArkLevel', 1)
        local is_quest_ark = TryGetProp(item, 'StringArg2', 'None') == 'Quest_Ark'
        local quest_ark_penalty = 1.1
        if is_quest_ark == true then
            quest_ark_penalty = 0.95 -- 5% 패널티
        end
        local ret = (0.2*(50*ark_lv)+((100*grade)+(1*use_lv)) * 0.8)*0.6 * quest_ark_penalty
        return math.floor(ret + 0.5)
    else -- 무기/방어구/악세서리
        local icor_lv = use_lv
        local random_icor_lv = 0
        
        local enchant_portion = 1       -- 인챈트 쥬얼 비율(max치 대비)
        local random_option_penalty = 0
        local enchant_option_penalty = 0

        local gem_point = 0

        if type ~= 'RING' and type ~= 'NECK' then
            -- 고정 아이커 레벨 체크
            local name = TryGetProp(item, 'InheritanceItemName', 'None')
            local cls = nil
            if name ~= 'None' then
                cls = GetClass('Item', name)
                if cls ~= nil then
                    icor_lv = TryGetProp(cls, 'UseLv', 1)
                else
                    icor_lv = 0
                end
            else
                icor_lv = 0
            end
                        
            -- 랜덤 아이커 레벨 체크
            if IS_HAVE_RANDOM_OPTION(item) then
                local ran_name = TryGetProp(item, 'InheritanceRandomItemName', 'None')
                if ran_name ~= 'None' then -- 레겐다 계열
                    cls = GetClass('Item', ran_name)
                    if cls ~= nil then
                        random_icor_lv = TryGetProp(cls, 'UseLv', 1)
                    end
                else -- 세비노스 계열
                    random_icor_lv = use_lv
                end
            else
                -- 레겐다 계열
                random_icor_lv = 0
            end

            -- 랜덤 옵션 수치
            local random_option_portion = GET_RANDOM_ICOR_PORTION(item)
            local diff = 1 - random_option_portion
            random_option_penalty = 0.05 * diff -- 5% 비중

            -- 인챈트 수치
            local enchant_portion = GET_ENCHANT_OPTION_PORTION(item)            
            diff = 1 - enchant_portion
            enchant_option_penalty = 0.05 * diff -- 5% 비중

            -- 젬 소켓 수치
            local max_socket_count = TryGetProp(item, 'MaxSocket_COUNT', 0)
            local start_idx = 0
            local _lv = TryGetProp(item, 'UseLv', 1)
            if grade >= 6 then
                max_socket_count = GET_MAX_GODDESS_NORMAL_SOCKET_COUNT(_lv)
            end
            for start_idx = 0, max_socket_count do
                local gem_id = 0
                local gem_lv = 0
                if IsServerSection() == 1 then
                    gem_id, gem_lv = GetItemSocketInfo(item, start_idx)
                else
                    local inv_item = session.GetInvItemByGuid(GetIESID(item))
                    if inv_item == nil then
                        inv_item = session.GetEquipItemByGuid(GetIESID(item))
                    end
                    if inv_item ~= nil then
                        gem_id = inv_item:GetEquipGemID(start_idx)
                        gem_lv = inv_item:GetEquipGemLv(start_idx)                        
                    end
                end
                   
                if gem_id ~= 0 and gem_id ~= 643817 then
                    local gem_cls = GetClassByType('Item', gem_id)
                    if gem_cls ~= nil then
                        local gem_type = TryGetProp(gem_cls, 'GemType', 'None')                                
                        if gem_type == 'Gem_High_Color' then
                            gem_lv = math.ceil(gem_lv * 0.15)                        
                        end

                        if TryGetProp(gem_cls, 'StringArg', 'None') == 'SkillGem' then
                            gem_lv = 0
                        end

                        gem_point = gem_point + gem_lv
                    end
                end
            end
        end
                
        local avg_lv = math.floor((use_lv * 0.5) + ((icor_lv + use_lv + random_icor_lv) * 0.33334 * 0.5) + 0.5)
        local set_option = 1
        local set_advantage = 0.9

        local base_acc = false
        if use_lv == 1 and TryGetProp(item, 'ItemGrade', 1) == 5 then
            use_lv = math.floor(PC_MAX_LEVEL * 0.85)
            base_acc = true
        end

        local add_acc = 0
        if type == 'NECK' or type == 'RING' then            
            avg_lv = use_lv
            if base_acc == false then
                if TryGetProp(item, 'StringArg', 'None') == 'Luciferi' then
                    add_acc = 80
                elseif TryGetProp(item, 'StringArg', 'None') == 'Acc_EP12' then
                    add_acc = 70
                else
                    add_acc = 30
                end
            end
        else
            local prefix = TryGetProp(item, 'LegendPrefix', 'None')            
            if prefix ~= 'None' then                
                local set_cls = GetClass('LegendSetItem', prefix)
                if set_cls ~= nil then
                    local group = TryGetProp(set_cls, 'LegendGroup', 'None')
                    if group == 'Velcoffer' then
                        set_advantage = 0.91
                    elseif group == 'Savinose/Varna' or group == 'Varna' then
                        set_advantage = 0.93 
                    elseif group == 'Disnai' then
                        set_advantage = 1 
                    end

                    if TryGetProp(set_cls, 'ClassName', 'None') == 'Set_Ezera' or TryGetProp(set_cls, 'ClassName', 'None') == 'Set_Karys' then
                        set_advantage = 0.9
                    end
                end
            end

            if is_sub_slot == true then
                set_advantage = 1
            end
        end

        set_option = 1 - random_option_penalty - enchant_option_penalty        
        local ret = 0.5 * ( (4*transcend) + (3*reinforce)) + ( (30*grade) + (1.66*avg_lv) )*0.5
        ret = ret * set_option * set_advantage + add_acc + gem_point
        
        return math.floor(ret + 0.5)
    end

    return 0
end

function GET_PLAYER_GEAR_SCORE(pc)    
    local total = 13
    local score = 0

    if IsServerSection() ~= 1 then -- client
        local equipList = session.GetEquipItemList();        
        for j = 0, equipList:Count() - 1 do
            local equipItem = equipList:GetEquipItemByIndex(j);
            if equipItem ~= nil and equipItem:GetIESID() ~= '0' then
                local invitem = GET_ITEM_BY_GUID(equipItem:GetIESID());
                local itemobj = GetIES(invitem:GetObject());
                score = score + GET_GEAR_SCORE(itemobj, pc)
            end            
        end        
        
        local item_sub_rh = session.GetEquipItemBySpot(30) -- RH_SUB
        local item_sub_lh = session.GetEquipItemBySpot(31) -- LH_SUB

        if item_sub_rh ~= nil and item_sub_rh:GetIESID() == '0' then
            total = total - 1
        end

        if item_sub_lh ~= nil and item_sub_lh:GetIESID() == '0' then
            total = total - 1
        end

        if total < 1 then
            total = 1
        end

        return math.floor((score / total) + 0.5)
    else
        local equipList = GetEquipItemList(pc)        
        for i = 1, #equipList do
            local itemobj = equipList[i]
            if itemobj ~= nil then
                score = score + GET_GEAR_SCORE(itemobj, pc)
            end
        end

        if IsNoneItem(pc, "RH_SUB") == 1 then
            total = total - 1
        end

        if IsNoneItem(pc, "LH_SUB") == 1 then            
            total = total - 1
        end

        if total < 1 then
            total = 1
        end

        return math.floor((score / total) + 0.5)
    end
end


function GET_GEAR_SCORE_BY(type, transcend, reinforce, grade, use_lv, item_lv)
    if check_slot_list == nil then
        check_slot_list = {}
        check_slot_list['RING'] = 1
        check_slot_list['NECK'] = 1

        check_slot_list['SHIRT'] = 1
        check_slot_list['GLOVES'] = 1
        check_slot_list['BOOTS'] = 1
        check_slot_list['PANTS'] = 1
        check_slot_list['RH'] = 1
        check_slot_list['LH'] = 1
        check_slot_list['LH_SUB'] = 1
        check_slot_list['RH_SUB'] = 1
        check_slot_list['RH LH'] = 1
        check_slot_list['LH RH'] = 1        

        check_slot_list['SEAL'] = 1
        check_slot_list['ARK'] = 1        
        --check_slot_list['RELIC'] = 1        
    end
    
    use_lv = math.max(use_lv, item_lv)

    if check_slot_list[type] == nil then        
        return 0
    end

    if type == 'SEAL' then        
        local ret = ((0.7 *(100*reinforce))+((1000*grade)+(1*use_lv)) * 0.3)*0.26        
        return math.floor(ret + 0.5)
    elseif type == 'RELIC' then        
        return 0
    elseif type == 'ARK' then        
        return 0
    else -- 무기/방어구/악세서리
        local icor_lv = use_lv
        local random_icor_lv = 0
        
        local enchant_portion = 1       -- 인챈트 쥬얼 비율(max치 대비)
        local random_option_penalty = 0
        local enchant_option_penalty = 0

        if type ~= 'RING' and type ~= 'NECK' then            
                        
            -- 랜덤 아이커 레벨 체크
            if false then
                local ran_name = TryGetProp(item, 'InheritanceRandomItemName', 'None')
                if ran_name ~= 'None' then -- 레겐다 계열
                    cls = GetClass('Item', ran_name)
                    if cls ~= nil then
                        random_icor_lv = TryGetProp(cls, 'UseLv', 1)
                    end
                else -- 세비노스 계열
                    random_icor_lv = use_lv
                end
            else
                -- 레겐다 계열
                random_icor_lv = 0
            end

            -- 랜덤 옵션 수치
            local random_option_portion = 0
            local diff = 1 - random_option_portion
            random_option_penalty = 0.05 * diff -- 5% 비중

            -- 인챈트 수치
            local enchant_portion = 0
            diff = 1 - enchant_portion
            enchant_option_penalty = 0.05 * diff -- 5% 비중            
        end
                
        local avg_lv = math.floor((use_lv * 0.5) + ((icor_lv + use_lv + random_icor_lv) * 0.33334 * 0.5) + 0.5)
        local set_option = 1
        local set_advantage = 0.9

        if type == 'NECK' or type == 'RING' then            
            avg_lv = use_lv
        else
            local prefix = 'None'
            if prefix ~= 'None' then                
                local set_cls = GetClass('LegendSetItem', prefix)
                if set_cls ~= nil then
                    local group = TryGetProp(set_cls, 'LegendGroup', 'None')
                    if group == 'Velcoffer' then
                        set_advantage = 0.91
                    elseif group == 'Savinose/Varna' or group == 'Varna' then
                        set_advantage = 0.93 
                    elseif group == 'Disnai' then
                        set_advantage = 1 
                    end
                end
            end
        end        
        set_option = 1 - random_option_penalty - enchant_option_penalty        
        local ret = 0.5 * ( (4*transcend) + (3*reinforce)) + ( (30*grade) + (1.66*avg_lv) )*0.5
        ret = ret * set_option * set_advantage
        
        return math.floor(ret + 0.5)
    end

    return 0
end

function GET_PLAYER_ABILITY_SCORE(pc)
    local job_list = GetJobHistoryList(pc)

    local total_score_list = {}
    table.insert(total_score_list, 600000)
    table.insert(total_score_list, 600000)
    table.insert(total_score_list, 600000)
    table.insert(total_score_list, 600000)

    for i = 1, #job_list do
        local ability_point_score = GetClassByType('ability_point_score', job_list[i])
        if ability_point_score ~= nil then
            local require_score = TryGetProp(ability_point_score, 'RequireScore', 600000)
            total_score_list[i] = require_score
        end
    end

    local total_score = 0
    for i = 1, #total_score_list do
        total_score = total_score + total_score_list[i]
    end

    if total_score <= 0 then
        total_score = 1
    end

    local use_point = 0
    
    if IsServerSection() == 1 then
        local abilList = GetAbilityNames(pc)
        for i = 1, #abilList do
            local abil_obj = GetAbilityIESObject(pc, abilList[i]);            
            local name = TryGetProp(abil_obj, 'ClassName', 'None') -- 특성 이름
            local score = GET_MAX_REQUIRED_ABILITY_POINT(pc, name)                
            if score ~= nil then
                local now = GET_ABILITY_POINT_BY_NAME(pc, name)
                use_point = use_point + now
            end 
        end
    else
        pc = GetMyPCObject()

        local abilList = session.GetAbilityList();
        local abilListCnt = abilList:Count();
            
        for i = 0, abilListCnt - 1 do
            local abil = session.GetAbilityByIndex(i);
            if abil ~= nil then
                local abil_obj = GetIES(abil:GetObject());
                local name = TryGetProp(abil_obj, 'ClassName', 'None') -- 특성 이름
                local score = GET_MAX_REQUIRED_ABILITY_POINT(pc, name)                
                if score ~= nil then
                    local now = GET_ABILITY_POINT_BY_NAME(pc, name)
                    use_point = use_point + now
                end                
            end
        end
    end    

    local ret = use_point / total_score * 100
        if ret >= 100 then
            ret = 100
        end
    return string.format('%.2f', ret)
end
