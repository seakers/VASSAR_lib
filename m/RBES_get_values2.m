function values = RBES_get_values2(fact_id,slots)
values = cell(length(slots),1);
f = jess(['fact-id ' num2str(fact_id)]);
for i = 1:length(slots)
    tmp = jess_value(f.getSlotValue(slots{i}));
    if ischar(tmp)
%         fprintf('%s = %s\n',slots{i},tmp);
    else
%         fprintf('%s = %f\n',slots{i},tmp);
    end
    values{i} = tmp;
end
end