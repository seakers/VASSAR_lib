function ret1 = find_facts( facts, slot, value )

    % facts = java.util.ArrayList<Fact>
    % slot = slot to make the match
    % value = value for the match

    ret1 = java.util.ArrayList;
    for i = 0:facts.size-1
        if strcmp( jess_str_value( facts.get(i).getSlotValue( slot ) ), value )
            ret1.add( facts.get(i) );
        end
    end

end