-- shared_event_new_season_server.lua

season_server_no_sell_item_list = {}

-- 20.08 여름 시즌서버
function IS_SEASON_SERVER(pc)
    local acc = nil
    if IsServerSection() == 1 and pc ~= nil then
        acc = GetAccountObj(pc)
    elseif IsServerSection() ~= 1 then
        acc = GetMyAccountObj()
    end

    if acc ~= nil then
        local marker = TryGetProp(acc, 'SeasonServerMarker', 'None')
        if marker == '2022-06-09' then
            return --[[ 'YES' ]]"NO";
        end
    end

    local groupid = GetServerGroupID();
    
    -- qa 1006, 스테이지 8001/8002
    if (GetServerNation() == "KOR" and (groupid == 1006 or groupid == 8002)) then
        return --[[ "YES" ]]"NO";
    end

    if (GetServerNation() == "KOR" and groupid == 3002) then
        return --[[ "YES" ]]"NO";
    end

    if (GetServerNation() == "GLOBAL" and (groupid == 10001 or groupid == 10003 or groupid == 10004 or groupid == 10005)) then
        return --[[ "YES" ]]"NO";
    end

    return "NO";
end

-- 시즌서버 출신?? 플레이어 체크시에 해당 함수를 사용할 것
function IS_SEASON_SERVER_PLAYER(pc)
    if pc ~= nil then
        local accObj = nil;
        if IsServerObj(pc) == 1 then
            accObj = GetAccountObj(pc);
        else
            accObj = GetMyAccountObj();
        end

        if accObj == nil then
            return "NO";
        end
        
        local value = TryGetProp(accObj, "EVENT_NEW_SEASON_SERVER_ACCOUNT", 0);     
        if value == GET_SEASON_SERVER_CHECK_PROP_VALUE() then
            return "YES";
        else
            return "NO";
        end
    end

    return 'NO'
end

function IS_SEASON_SERVER_OPEN()
    local now_time = date_time.get_lua_now_datetime_str();
    local end_time = "2020-08-06 06:00:00";
    
    return date_time.is_later_than(now_time, end_time);
end

function GET_SEASON_SERVER_CHECK_PROP_VALUE()
    if GetServerNation() == "KOR" then
        return 1;
    end

    if GetServerNation() == "GLOBAL" then
        return 2;
    end
end

function GET_SEASON_SERVER_OPEN_DATE()
    return '2022-06-09'
end

--[[
    스페셜 생성권 지급 기간 여부 및 지급 수량 체크용
    기존 계정의 경우 DB작업을 통해 일괄 지급 가능하지만
    신규 팀 생성시에는 DbBarrackNameSave.cpp 에서 이 스크립트를 통해 체크하여 지급한다.
]]
function GET_SPECIAL_CREATE_TICKET_INFO()
    local startTime = '2022-06-09 06:00:00'
    local endTime = '2022-07-28 05:59:59'
    local setCount = '1'

    return startTime, endTime, setCount
end

function IS_ABLE_SPECIAL_CREATE_TICKET(pc)
    if pc == nil then
        return false, nil
    end

    local accObj = nil
    local etcObj = nil
    if IsServerObj(pc) == 1 then
        accObj = GetAccountObj(pc)
        etcObj = GetETCObject(pc)
    else
        accObj = GetMyAccountObj()
        etcObj = GetMyEtcObject()
    end

    local ticket_count = TryGetProp(accObj, 'SPECIAL_CREATE_TICKET_COUNT', 0)
    if accObj == nil or ticket_count <= 0 then
        if etcObj == nil or TryGetProp(etcObj, 'SettingProgressState', 0) == 0 or TryGetProp(etcObj, 'SettingProgressState', 0) >= 5 then
            return false, 'HaveNoSpecialCreateTicket'
        end
    end

    -- 카운트가 1이면 기간제로 무상 제공
    -- 1보다 큰 양의 정수이면 아이템 사용해서 얻은 것
    if ticket_count == 1 then
        local startTime, endTime = GET_SPECIAL_CREATE_TICKET_INFO()
        local nowTime = date_time.get_lua_now_datetime_str()
        if IsServerSection() == 0 then
            local server_time = geTime.GetServerSystemTime()
            nowTime = date_time.lua_datetime_to_str(date_time.get_lua_datetime(server_time.wYear, server_time.wMonth, server_time.wDay, server_time.wHour, server_time.wMinute, server_time.wSecond))
        end
    
        if date_time.is_later_than(startTime, nowTime) == true or date_time.is_later_than(nowTime, endTime) == true then
            return false, 'SpecialCreateTicketExpired'
        end
    end

    return true
end

function SEASON_SERVER_MAX_LEVEL_UP_REWARD(self, tx, level)
    if GetServerNation() == 'KOR' and IS_SEASON_SERVER(self) == 'YES' and level == 470 then
        local acc = GetAccountObj(self)
        if TryGetProp(acc, 'SEASON_SERVER_2022_06_09', 0) == 0 then
            TxSetIESProp(tx, acc, 'SEASON_SERVER_2022_06_09', 1);
            TxGiveItem(tx, 'SeasonServerOpen_MaxLevel_Box', 1, 'LevelUp')
        end
    end
end

function costume_boss_map_check(map_name)
    local cls = GetClass('Map', map_name)
    if TryGetProp(cls, 'MapType', 'None') == "Field" and TryGetProp(cls, 'RewardEXPBM', 0)  > 0.1 then
        if TryGetProp(cls, 'QuestLevel', 0) >= 150 then            
            return true
        end
    end
    
    return false
end

function ep14_field_boss_map_check(map_name)
    if map_name == 'ep14_2_d_castle_3' then        
        return true
    else
        return false
    end
end