-- skill_exprop_ratetable.lua
-- FINAL_DAMAGECALC() -> SCR_EXPROP_RATETABLE_UPDATE(self, from, skill, atk, ret, rateTable);

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_EXPROP_RATETABLE_ITEM_VIBORA_MACE_BINATIO(self, from, skill, atk, ret, rateTable, propName)
    if GetExProp(from, propName) ~= 0 then
        if IsBuffApplied(from, "Binatio_Buff") == "YES" and CHECK_SKILL_KEYWORD(skill, "NormalSkill") == 1 then
            local Add = TryGetProp(from, "Add_Damage_Atk") * 0.01
            if Add >= 1000 then
                Add = 1000
            end
            rateTable.AddSkillFator = rateTable.AddSkillFator + Add
        end
    end
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_EXPROP_RATETABLE_ITEM_VIBORA_STAFF_FIREPILLAR(self, from, skill, atk, ret, rateTable, propName)
    if GetExProp(from, propName) ~= 0 and TryGetProp(skill, "ClassName", "None") == "Pyromancer_FirePillar" then
        rateTable.ItemDamageRate = rateTable.ItemDamageRate + 1
    end
end