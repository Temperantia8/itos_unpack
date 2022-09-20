-- shared_item_aether.lua
function get_solo_dungeon_clear_stage(self)
    local clear_stage = nil;
    if IsServerSection() == 0 then
        local account_obj = GetMyAccountObj();
        if account_obj ~= nil then
            clear_stage = TryGetProp(account_obj, "SOLO_DUNGEON_MINI_CLEAR_STAGE");
        end
    else
        local account_obj = GetAccountObj(self);
        if account_obj ~= nil then
            clear_stage = TryGetProp(account_obj, "SOLO_DUNGEON_MINI_CLEAR_STAGE");
        end
    end
    return clear_stage;
end

function get_solo_dungeon_etc_clear_stage(self)
    local clear_stage = nil;
    if IsServerSection() == 0 then
        local etc_object = GetMyEtcObject();
        if etc_object ~= nil then
            clear_stage = TryGetProp(etc_object, "BerniceShard_Dungeon_Save_Stage");
        end
    else
        local etc_object = GetETCObject(self);
        if etc_object ~= nil then
            clear_stage = TryGetProp(etc_object, "BerniceShard_Dungeon_Save_Stage");
        end
    end
    return clear_stage;
end

-- by gem item
function get_ratio_success_aether_gem(self, item)
    if item ~= nil then
        local value = 0;
        if IsServerSection() == 0 then
            local level = TryGetProp(item, "AetherGemLevel");
            local clear_stage = get_solo_dungeon_etc_clear_stage();
            if level ~= nil and clear_stage ~= nil then
                value = clear_stage - level; 
            end
        else
            local level = TryGetProp(item, "AetherGemLevel");
            local clear_stage = get_solo_dungeon_etc_clear_stage(self);
            if level ~= nil and clear_stage ~= nil then
                value = clear_stage - level;
            end
        end

        if value >= 10 then -- 100%
            return 100;
        elseif value == 9 then -- 90%
            return 90;
        elseif value == 8 then -- 80%
            return 80;
        elseif value == 7 then -- 70%
            return 70;
        elseif value == 6 then -- 60%
            return 60;
        elseif value <= 5 and value >= 0 then -- 50%
            return 50;
        elseif value == -1 then -- 25%
            return 25;
        elseif value == -2 then -- 12%
            return 12;
        elseif value == -3 then -- 6%
            return 6;
        elseif value == -4 then -- 3%
            return 3;
        elseif value == -5 then -- 2%
            return 2;
        elseif value <= -6 and value >= -10 then -- 1%
            return 1;
        elseif value <= -11 then -- 0%
            return 0;
        end
    end
    return 0;
end

-- by gem level
function get_ratio_success_aether_gem_equip(self, level)
    local value = 0;
    if IsServerSection() == 0 then
        local clear_stage = get_solo_dungeon_etc_clear_stage();
        if level ~= nil and clear_stage ~= nil then
            value = clear_stage - level; 
        end
    else
        local clear_stage = get_solo_dungeon_etc_clear_stage(self);
        if level ~= nil and clear_stage ~= nil then
            value = clear_stage - level;
        end
    end

    if value >= 10 then -- 100%
        return 100;
    elseif value == 9 then -- 90%
        return 90;
    elseif value == 8 then -- 80%
        return 80;
    elseif value == 7 then -- 70%
        return 70;
    elseif value == 6 then -- 60%
        return 60;
    elseif value <= 5 and value >= 0 then -- 50%
        return 50;
    elseif value == -1 then -- 25%
        return 25;
    elseif value == -2 then -- 12%
        return 12;
    elseif value == -3 then -- 6%
        return 6;
    elseif value == -4 then -- 3%
        return 3;
    elseif value == -5 then -- 2%
        return 2;
    elseif value <= -6 and value >= -10 then -- 1%
        return 1;
    elseif value <= -11 then -- 0%
        return 0;
    end
    return 0;
end

-- by gem item
function is_max_aether_gem_level(item)
    if item == nil then return false; end
    local max_level = 0;
    local use_level = TryGetProp(item, "NumberArg1",0);
    if use_level == 460 then
        max_level = 120
    elseif use_level == 480 then
        max_level = 150
    else
        return false;
    end
    
    local cur_level = TryGetProp(item, "AetherGemLevel", 1);
    if cur_level >= max_level then return true;
    else return false; end
    return false;
end

-- by gem level
function is_max_aether_gem_level_equip(level)
    if item == nil then return false; end
    local max_level = 120;
    if level >= max_level then return true;
    else return false; end
    return false;
end

function is_max_aether_gem_level_equip_new(level,NumberArg)
    if item == nil then return false; end
    local max_level = 0;
    local use_level = NumberArg
    if use_level == 460 then
        max_level = 120
    elseif use_level == 480 then
        max_level = 150
    else
        return false;
    end
    if level >= max_level then return true;
    else return false; end
    return false;
end


function get_current_aether_gem_level(item)
    if item == nil then return 0; end
    local cur_level = TryGetProp(item, "AetherGemLevel", 1);
    return cur_level;
end

-- 에테르 젬 강화 Count 설정
function tx_set_aether_gem_reinforce_count(self, count)
    if self == nil then return; end
    if IsServerSection() == 1 then
        local tx = TxBegin(self);
        if tx ~= nil then
            local etc_object = GetETCObject(self);
            if etc_object ~= nil then
                TxSetIESProp(tx, etc_object, "AetherGemReinforceCount", count);
                --Lv480 에테르 젬 추가로 강화 etc_prop 추가
                TxSetIESProp(tx, etc_object, "AetherGemReinforceCount_460", 0);
                TxSetIESProp(tx, etc_object, "AetherGemReinforceCount_480", 0);
            end
            local ret = TxCommit(tx);
            return ret;
        end
    end
    return "FAIL";
end

-- 에테르 젬 강화 Base Count 가져오기
function get_aether_gem_reinforce_count(self)
    local reinforce_count = 0;
    if IsServerSection() == 0 then
        local etc_object = GetMyEtcObject();
        if etc_object ~= nil then
            reinforce_count = TryGetProp(etc_object, "AetherGemReinforceCount", 0);
        end
    else
        if self ~= nil then
            local etc_object = GetETCObject(self);
            if etc_object ~= nil then
                reinforce_count = TryGetProp(etc_object, "AetherGemReinforceCount", 0);
            end
        end
    end
    return reinforce_count;
end


function get_aether_gem_reinforce_count_total(self)
    local reinforce_count_total = 0;
    if IsServerSection() == 0 then
        local etc_object = GetMyEtcObject();
        if etc_object ~= nil then
            local reinforce_count     = TryGetProp(etc_object, "AetherGemReinforceCount", 0);
            local reinforce_count_460 = TryGetProp(etc_object, "AetherGemReinforceCount_460", 0);
            local reinforce_count_480 = TryGetProp(etc_object, "AetherGemReinforceCount_480", 0);
            reinforce_count_total = reinforce_count + reinforce_count_460 + reinforce_count_480
        end
    else
        if self ~= nil then
            local etc_object = GetETCObject(self);
            if etc_object ~= nil then
                local reinforce_count     = TryGetProp(etc_object, "AetherGemReinforceCount", 0);
                local reinforce_count_460 = TryGetProp(etc_object, "AetherGemReinforceCount_460", 0);
                local reinforce_count_480 = TryGetProp(etc_object, "AetherGemReinforceCount_480", 0);
                reinforce_count_total = reinforce_count + reinforce_count_460 + reinforce_count_480
            end
        end
    end
    return reinforce_count_total;
end

-- 에테르 젬 강화 460Lv Count 가져오기
function get_aether_gem_reinforce_count_460(self)
    local reinforce_count = 0;
    if IsServerSection() == 0 then
        local etc_object = GetMyEtcObject();
        if etc_object ~= nil then
            reinforce_count = TryGetProp(etc_object, "AetherGemReinforceCount_460", 0);
        end
    else
        if self ~= nil then
            local etc_object = GetETCObject(self);
            if etc_object ~= nil then
                reinforce_count = TryGetProp(etc_object, "AetherGemReinforceCount_460", 0);
            end
        end
    end
    return reinforce_count;
end

-- 480Lv 에테르 젬 강화 Count 가져오기
function get_aether_gem_reinforce_count_480(self)
    local reinforce_count = 0;
    if IsServerSection() == 0 then
        local etc_object = GetMyEtcObject();
        if etc_object ~= nil then
            reinforce_count = TryGetProp(etc_object, "AetherGemReinforceCount_480", 0);
        end
    else
        if self ~= nil then
            local etc_object = GetETCObject(self);
            if etc_object ~= nil then
                reinforce_count = TryGetProp(etc_object, "AetherGemReinforceCount_480", 0);
            end
        end
    end
    return reinforce_count;
end

-- 에테르 젬 강화 MaxCount 설정
function exprop_set_aether_gem_reinforce_max_count(self, count)
    if self == nil then return; end
    if IsServerSection() == 1 then
        SetExProp(self, "aether_gem_reinforce_max_count", count);
    end
end

-- 에테르 젬 강화 MaxCount 가져오기
function exprop_get_aether_gem_reinforce_max_count(self)
    if self == nil then return; end
    if IsServerSection() == 1 then
        return GetExProp(self, "aether_gem_reinforce_max_count");
    end
    return 0;
end

-- 에테르 젬(힘) --
function get_aether_gem_STR_prop(level)
    return "STR", level * 2, true; -- prop_name, prop_value, use_operator   
end

-- 에테르 젬(지능) --
function get_aether_gem_INT_prop(level)
    return "INT", level * 2, true; -- prop_name, prop_value, use_operator   
end

-- 에테르 젬(민첩) --
function get_aether_gem_DEX_prop(level)
    return "DEX", level * 2, true; -- prop_name, prop_value, use_operator   
end

-- 에테르 젬(정신) --
function get_aether_gem_MNA_prop(level)
    return "MNA", level * 2, true; -- prop_name, prop_value, use_operator   
end

-- 에테르 젬(체력) --
function get_aether_gem_CON_prop(level)
    return "CON", level * 2, true; -- prop_name, prop_value, use_operator   
end

-- 테스트
function test_reset_aether_gem_reinforce_count(self)
    exprop_set_aether_gem_reinforce_max_count(self, 5);
    SendAddOnMsg(self, "AETHER_GEM_REINFORCE_MAX_COUNT", "", 5);
    if IsRunningScript(self, "tx_set_aether_gem_reinforce_count") ~= 1 then
        RunScript("tx_set_aether_gem_reinforce_count", self, 5);
    end
end