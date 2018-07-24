function ret1 = get_facts_values( facts, values )

    % facts = ArrayList<Fact>
    % values = {'value1','value2',...}

    ret1 = cell( length(values), facts.size );
    for i = 0:facts.size-1
        for j = 1:length(values)
            ret1{j,i+1} = jess_str_value( facts.get(i).getSlotValue( values{j} ) );
        end
    end

end

