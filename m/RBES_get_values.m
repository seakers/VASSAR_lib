function values = RBES_get_values(fact_id,slots)
f = jess(['fact-id ' num2str(fact_id)]);
values = cell(length(slots),1);
for i = 1:length(slots)
    tmp = jess_value(f.getSlotValue(slots{i}));
    values{i} = tmp;
    if ischar(tmp)
        fprintf('%s = %s\n',slots{i},tmp);
    else
        fprintf('%s = %f\n',slots{i},tmp);
    end
end
end