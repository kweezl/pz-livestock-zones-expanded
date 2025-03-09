local function partition(list, left, right, comparator)
    local pivot = list:get(right);
    local i = left - 1;

    for j = left, right - 1  do
        local item = list:get(j);
        if comparator(item, pivot) then
            i = i + 1;
            local temp = list:get(i);
            list:set(i, item);
            list:set(j, temp);
        end
    end

    i = i + 1;
    list:set(right, list:get(i));
    list:set(i, pivot);

    return i;
end

local quicksort;
quicksort = function(list, left, right, comparator)
    if right - left <= 0 then
        return;
    end

    local pivot = partition(list, left, right, comparator)
    quicksort(list, left, pivot - 1, comparator)
    quicksort(list, pivot + 1, right, comparator)
end

--- @param list ArrayList<T>
--- @param comparator function
return function(list, comparator)
    quicksort(list, 0, list:size() - 1, comparator)
end;
