function num = RBES_synergies
% 1) Modify measurements in the presence of others (does retract and assert) from xls database (salience -5)
% 2) spatial-disaggregation, space/time averaging
% 3) Assert new measurements from combinations of others
global params
r = global_jess_engine();

if params.SYNERGIES
    if params.WATCH, fprintf('Synergies...\n');end
    if strcmp(params.WATCH_ONLY,'synergies')
        jess unwatch all;
        jess watch rules;
    end
    r.eval('(focus SYNERGIES)');
    num = r.run(20000);
    if strcmp(params.WATCH_ONLY,'synergies')
        jess unwatch all;
    end
    if params.MEMORY_SAVE
        % remove SYNERGIES rules, not needed anymore
        list_rules = r.listDefrules();
        while list_rules.hasNext()
            rule = list_rules.next().getName();
            if rule.startsWith('SYNERGIES')
                r.removeDefrule(rule)
            end
        end
    end
end
end
