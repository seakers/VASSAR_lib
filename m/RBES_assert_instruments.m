function RBES_assert_instruments
% 1) assert instruments of each mission (salience 20)
% 2) inherit instrument attributes from instrument database (salience 10, not needed )
% 3) inherit instrument attributes from mission (e.g orbit) (salience 10,  not needed)
% ==> note that it will all be single satellite orbits at this point
global params
r = global_jess_engine();

%% Count missions
params.MissionIds = java.util.HashMap;
params.MissionFromIds = java.util.HashMap;
facts = r.listFacts(); % iterator
nn = 0;
while facts.hasNext()
    f = facts.next();
    if ~strcmp(f.getDeftemplate,'[deftemplate MANIFEST::Mission]')
        continue
    end
    nn = nn + 1;
    str = f.getSlotValue('Name').stringValue(r.getGlobalContext());% Mission name
    params.MissionIds.put(str,nn);
    params.MissionFromIds.put(nn,str);
end
% jess defquery MANIFEST::find-missions (MANIFEST::Mission (Name ?n))
% 
% params.NumberOfMissions = jess_value(r.eval('(count-query-results MANIFEST::find-missions)'));
params.NumberOfMissions = nn;

%% Assert instruments and get their properties
if params.WATCH, fprintf('Manifest...\n');end
r.eval('(focus MANIFEST)');
r.run(10000);

if params.MEMORY_SAVE
    % remove manifest rules, not needed anymore
    list_rules = r.listDefrules();
    while list_rules.hasNext()
        rule = list_rules.next().getName();
        if rule.startsWith('MANIFEST')
            r.removeDefrule(rule)
        end
    end
end

end