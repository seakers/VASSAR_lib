function  RBES_science_requirements
global params
r = global_jess_engine();

if params.WATCH, fprintf('Requirements...\n');end
r.eval('(focus REQUIREMENTS)');
r.run(20000);
if params.MEMORY_SAVE
    list_rules = r.listDefrules();
    while list_rules.hasNext()
        rule = list_rules.next().getName();
        if rule.startsWith('REQUIREMENTS')
            if ~rule.startsWith('REQUIREMENTS::search-all-measurements-by-parameter')    
                r.removeDefrule(rule);
            end
        end
    end
    clear list_rules rule
end

end