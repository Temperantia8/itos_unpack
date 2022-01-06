-- shared_pvp_mine_shop_overbuy.lua

function GET_OVERBUY_NEED_COUNT(base, over_count, ratio)  
    base = base + (((base * ratio) * over_count) / 10000)
    return math.floor(base)
end
function IS_OVERBUY_ITEM(shopType, recipecls, aObj)
    if shopType ~= 'PVPMine' then
        return false
    end
    
    local need_acc_property = TryGetProp(recipecls, 'AccountNeedProperty', 'None')

    if shopType == 'PVPMine' and need_acc_property ~= 'None' and TryGetProp(aObj, need_acc_property, 0) <= 0 then
        if TryGetProp(recipecls, 'MaxOverBuyCount', 0) > 0 then
            local overbuy_prop = TryGetProp(recipecls, 'OverBuyProperty', 'None')  
            if overbuy_prop ~= 'None' then
                return true
            end
        end
    end

    return false
end
function IS_EXCEED_OVERBUY_COUNT(shopType, acc, cls, itemCnt)  -- 아이템을 추가적으로 얻게 되면 개수를 초과하게 되는가?
    if shopType ~= 'PVPMine' then
        return true
    end

    local max = TryGetProp(cls, 'MaxOverBuyCount', 100)
    local prop_name = TryGetProp(cls, 'OverBuyProperty', 'None')
    if prop_name == 'None' then
        return true
    end
    local now = TryGetProp(acc, prop_name, 0)
    now = now + itemCnt
    
    if now > max then
        return true
    end

    return false
end
function GET_CURRENT_OVERBUY_COUNT(shopType, base_value, recipecls, aObj)    
    local need_acc_property = TryGetProp(recipecls, 'AccountNeedProperty', 'None')

    if shopType == 'PVPMine' and need_acc_property ~= 'None' and TryGetProp(aObj, need_acc_property, 0) <= 0 then                    
        if TryGetProp(recipecls, 'MaxOverBuyCount', 0) > 0 then
            local overbuy_prop = TryGetProp(recipecls, 'OverBuyProperty', 'None')  
            if overbuy_prop ~= 'None' then
                local current_overbuy = TryGetProp(aObj, overbuy_prop, TryGetProp(recipecls, 'MaxOverBuyCount', 0))                
                local over_count = GET_OVERBUY_NEED_COUNT(base_value, current_overbuy + 1, tonumber(TryGetProp(recipecls, 'OverBuyRatio', 5000)))                            
                base_value = over_count
                return base_value
            end
        end
    end

    return base_value
end
function GET_TOTAL_AMOUNT_OVERBUY(shopType, base_value, recipecls, aObj, count) 
    if shopType ~= 'PVPMine' then
        return base_value
    end

    local need_acc_property = TryGetProp(recipecls, 'AccountNeedProperty', 'None')

    if (shopType == 'PVPMine' or shopType == 'GabijaCertificate') and need_acc_property ~= 'None' and TryGetProp(aObj, need_acc_property, 0) <= 0 then
        if TryGetProp(recipecls, 'MaxOverBuyCount', 0) > 0 then
            local overbuy_prop = TryGetProp(recipecls, 'OverBuyProperty', 'None')  
            if overbuy_prop ~= 'None' then                
                local current_overbuy = TryGetProp(aObj, overbuy_prop, TryGetProp(recipecls, 'MaxOverBuyCount', 0))                
                local over_count = 0
                local idx = current_overbuy

                for idx = current_overbuy, current_overbuy + count - 1 do                                        
                    over_count = over_count + GET_OVERBUY_NEED_COUNT(base_value, idx + 1, tonumber(TryGetProp(recipecls, 'OverBuyRatio',  5000)))
                end
                
                return over_count
            end
        end
    end

    return base_value
end