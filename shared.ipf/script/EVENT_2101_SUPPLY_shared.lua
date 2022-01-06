-- 바이보라 합성 레벨 제한
function GET_EVENT_2101_SUPPLY_VIBORA_COMPOSITE_LEVEL()
    return 450;
end

-- 바이보라 합성에 필요한 티켓 수량
function GET_EVENT_2101_SUPPLY_VIBORA_COMPOSITE_TICKET_NEED_COUNT()
    return 1;
end

-- 왕국 재건단 보급관 NPC 생성 및 입구로 돌아가는 시간 늘리는 인던 
local npcmgamelist = {"ID_REMAINS_MINI_03", "ID_3CMLAKE_26_1", "ID_ZACHA_MINI", "ID_CMINE_MINI", "ID_HUEVILLAGE_MINI", "ID_CATACOMB_MINI", 
"ID_CASTLE_03_MINI", "ID_SIAULIAI_MINI", "ID_ROKAS_MINI", "RAID_VELCOPFFER_RARE_MINI", "LEGEND_RAID_WHITE_CROW", 
"LEGEND_RAID_WHITE_CROW_SOLO", "LEGEND_RAID_MORINGPONIA", "LEGEND_RAID_MORINGPONIA_EASY", "LEGEND_RAID_MORINGPONIA_HARD", 
"LEGEND_RAID_GLACIER_EASY", "LEGEND_RAID_GLACIER_NORMAL", "LEGEND_RAID_GLACIER_HARD", "LEGEND_RAID_MORINGPONIA_HARD_SOLO", 
"LEGEND_RAID_GILTINE", "LEGEND_RAID_GILTINE_AUTO", "M_GTOWER2_STAGE_40", "rift_10", "rift_11", 
"IRREDIAN1131_SRAID_A", "IRREDIAN1131_SRAID_B", "UNDERAQUEDUCT_NORMAL_MGAME", "UNDERAQUEDUCT_MGAME", "IRREDIAN1131_SRAID_C",
"MYTHIC_STARTOWER_MINI_AUTO","MYTHIC_FIRETOWER_MINI_AUTO","MYTHIC_CASTLE_MINI_AUTO","MYTHIC_STARTOWER_MINI_AUTO_HARD","MYTHIC_FIRETOWER_MINI_AUTO_HARD",
"MYTHIC_CASTLE_MINI_AUTO_HARD"
};
function IS_EVENT_2101_SUPPLY_NPC_CREATE_CONTENT(mgameName)
    for k, v in pairs(npcmgamelist) do 
        if v == mgameName then
            return true;
        end
    end

    return false;
end

local stagelist = {"END", "SUCCESS", "clear", "Success", "success", "Succ", "OUT", "End"}
function IS_EVENT_2101_SUPPLY_NPC_STAGE(curStage)
    for k, v in pairs(stagelist) do 
        if v == curStage then
            return true;
        end
    end

    return false;
end

-- npc 생성 했을 경우 마을 이동 제한시간, 초 단위 
function GET_EVENT_2101_SUPPLY_CONTENT_NPC_TIME()
    return 180;
end

function IS_EVENT_2101_SUPPLY_CONTENT_NPC(className)
    if className == "Event_supply_NPC_1" or className == "Event_supply_NPC_7" then
        return true;
    end

    return false;
end