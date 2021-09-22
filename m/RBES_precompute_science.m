function RBES_precompute_science
global params
r = global_jess_engine();
if params.WATCH, fprintf('Precomputing science...\n');end
r.eval('(focus PRECOMPUTE-SCIENCE)');
r.run(10000);

if params.MEMORY_SAVE
    % remove SYNERGIES rules, not needed anymore
    list_rules = r.listDefrules();
    while list_rules.hasNext()
        rule = list_rules.next().getName();
        if rule.startsWith('PRECOMPUTE-SCIENCE')
            r.removeDefrule(rule);
        end
    end
end

end