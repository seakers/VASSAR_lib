function [sorted_elements,sorted_occurrences] = sort_array_elements_by_nocurrences(arr)
%% sort_array_elements_by_nocurrences.m
% This function counts the number of occurrences of each element in an
% array and sorts the elements from higher to lower
iter = arr.iterator;
MAX = 10000;
map = java.util.HashMap;
elements = cell(MAX,1);
occurrences = zeros(MAX,1);
i = 1;
while(iter.hasNext())
    elem = iter.next();
    if map.containsKey(elem)
        ind = map.get(elem);
%         map.put(elem,n+1);
        occurrences(ind) = occurrences(ind) + 1;
    else
        map.put(elem,i);
        elements{i} = elem;
        occurrences(i) = 1;
        i = i + 1;
    end
    
end
occurrences(i:end) = [];
elements(i:end) = [];

[sorted_occurrences,order] = sort(occurrences,'descend');
sorted_elements = elements(order);


end
