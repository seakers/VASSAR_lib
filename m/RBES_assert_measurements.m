function RBES_assert_measurements
global params
r = global_jess_engine();
if params.WATCH, fprintf('Capabilities...\n');end

%% Run
r.eval('(focus CAPABILITIES)');
r.run(10000);

%% Cross-register all measurements at the platform level
facts = r.listFacts(); % iterator
% measurement_list = java.util.ArrayList;
[ns,MissionIds] = RBES_count_missions;% or params.number_of_missions from Evaluate_architecture

measurement_list_str = cell(1,ns);
measurement_list_array = cell(1,ns);
for i = 1:ns
    measurement_list_array(i) = java.util.ArrayList;

end


while facts.hasNext()
    f = facts.next();
    if ~strcmp(f.getDeftemplate,'[deftemplate REQUIREMENTS::Measurement]')
        continue
    end
%     measurement_list.add(f.getSlotValue('Id').stringValue(r.getGlobalContext()));
    str = char(f.getSlotValue('flies-in').stringValue(r.getGlobalContext()));
%     s = str2num(str(end));
    s = MissionIds.get(str);% this needs to be added to RBES_Iridium_Params!!
    id_str = f.getSlotValue('Id').stringValue(r.getGlobalContext());
    if ~measurement_list_array{s}.contains(id_str)
        measurement_list_array{s}.add(id_str);
        measurement_list_str{s} = [measurement_list_str{s} ' ' char(id_str)];
    end
end
if params.CROSS_REGISTER
    for s = 1:ns
        call = ['(assert (SYNERGIES::cross-registered '...
            ' (measurements ' measurement_list_str{s} ') '...
            ' (degree-of-cross-registration spacecraft) '...
            ' (platform ' char(params.satellite_names) '-' num2str(s) ' ) '...
            '))' ];
        r.eval(call);
    end
end
if params.MEMORY_SAVE
    % remove Capabilities rules, not needed anymore
    list_rules = r.listDefrules();
    while list_rules.hasNext()
        rule = list_rules.next().getName();
        if rule.startsWith('CAPABILITIES')
            r.removeDefrule(rule)
        end
    end
end
end
