-- skill_exprop_aftercalc.lua
-- CALC_FINAL_DAMAGE() -> SCR_EXPROP_AFTERCALC_UPDATE(self, from, skill, atk, ret);

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_EXPROP_AFTERCALC_ATK_ITEM_VIBORA_THMACE_GODSMASH(self, from, skill, atk, ret, rateTable, propName)
    if GetExProp(from, "ITEM_VIBORA_THMACE_GODSMASH") ~= 0 and TryGetProp(skill, "ClassName", "None") == "Inquisitor_GodSmash" then
        if ret.AddBlow == 1 then
            return 1
        end
        TakeDamageAddBlow(from, self, "Inquisitor_GodSmash", atk, 0.1, "Melee", "Strike", "Melee", HIT_BASIC, HITRESULT_BLOW)
    end
end