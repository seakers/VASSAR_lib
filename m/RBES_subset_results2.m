function [results2,archs2] = RBES_subset_results2(results,archs,indexes)
attrs = fieldnames(results);
for i = 1:length(attrs)
    tmp = results.(attrs{i});
    [a,b] = size(tmp);
    if a == 1 || b == 1
        results2.(attrs{i}) = tmp(indexes);
    elseif a==0 && b == 0
    else
        results2.(attrs{i}) = tmp(indexes,:);
    end
end
archs2 = archs(indexes);
end