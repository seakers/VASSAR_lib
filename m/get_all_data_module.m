function [] = get_all_data_module(facts,att)
r = jess.Rete;
for i = 1:facts.size
    f = facts.get(i-1);
    fprintf('%s\n',char(f.getSlotValue(att).stringValue(r.getGlobalContext)))
end
    
end