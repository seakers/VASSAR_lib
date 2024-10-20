function RBES_fuzzy_attributes
global params
r = global_jess_engine();

if params.WATCH, fprintf('Fuzzy...\n');end
%     jess watch all
r.eval('(focus FUZZY)');
r.run();
%     jess unwatch all
if params.MEMORY_SAVE
    list_rules = r.listDefrules();
    while list_rules.hasNext()
        rule = list_rules.next().getName();
        if rule.startsWith('FUZZY')
            r.removeDefrule(rule);
        end
    end
    clear list_rules rule

end
end