-- item_awakening.lua


function GET_ITEM_AWAKENING_PRICE(obj) -- 여기 각성 가루 아이템의 클래스 네임과 개수 공식을 써주십쇼    
	local count = 1;
--    if obj ~= nil then
--        count = obj.ItemStar * obj.ItemGrade;
--    end
    
	return "misc_wakepowder", count;
end

function IS_ITEM_AWAKENING_STONE(obj)
	if obj.ClassName == "misc_awakeningStone1" then
		return true;
	elseif obj.ClassName == "Premium_awakeningStone" or obj.ClassName == "Premium_awakeningStone14" or obj.ClassName == "Premium_awakeningStone_TA" or
		   obj.ClassName == "Premium_awakeningStone14_Team" or obj.ClassName == "Event_awakeningStone_1" or obj.ClassName == "Event_awakeningStone_2"
		   or obj.ClassName == "Event_awakeningStone_3" or obj.ClassName == "Event_awakeningStone_4" or obj.ClassName == "Event_awakeningStone_5"
		   or obj.ClassName == "Event_awakeningStone_6" or obj.ClassName == "Event_awakeningStone_7" or obj.ClassName == "Event_awakeningStone_8" 
		   or obj.ClassName == "Event_awakeningStone_200" or obj.ClassName == "Event_awakeningStone_9" or obj.ClassName == "Event_awakeningStone_201"
		   or obj.ClassName == "Event_awakeningStone_202" or obj.ClassName == "Event_awakeningStone_10" or obj.ClassName == "Event_awakeningStone_11" 
		   or obj.ClassName == "Event_awakeningStone_12" or obj.ClassName == "Event_awakeningStone_13" or obj.ClassName == "Event_awakeningStone_14" 
		   or obj.ClassName == "Event_awakeningStone_15" or obj.ClassName == "Event_awakeningStone_16" or obj.ClassName == "Event_awakeningStone_18"
		   or obj.ClassName == "Event_awakeningStone_19" or obj.ClassName == "Event_awakeningStone_20" or obj.ClassName == "Event_awakeningStone_205"
		   or obj.ClassName == "Event_awakeningStone_33" or obj.ClassName == "Event_awakeningStone_39" or obj.ClassName == "Event_awakeningStone_limit"
		   or obj.ClassName == "Event_awakeningStone_limit_1" or obj.ClassName == "Event_awakeningStone_limit_2" then
		return true;
	end

	return false;
end