function RBES_explain_score(instr,subobjs,panel_scores,type)
global params
r = global_jess_engine();
%% Global scores
score = RBES_get_score_from_subobj_struct(subobjs);
fprintf('Overall scores for instrument %s = %f\n',instr,score);

fprintf('*******************************************\n');
fprintf('Explanation of scores for instrument %s\n',instr);
fprintf('*******************************************\n');
[names,full,partial,scores] = RBES_find_objectives_satisfied(subobjs,0);
for p = 1:params.npanels
    psc = panel_scores(p);
    pan = params.panel_names{p};
    if psc > 0
    fprintf('Panel %s has a score of %f because the following subobjectives are satisfied:\n',pan,psc);
    for j = 1:names.size
        subobj = names.get(j-1);
        tmp = params.subobjectives_to_measurements.get(strcat('?*subobj-',subobj,'*'));
        meas = char(tmp.get(0));
        if strncmp(subobj,pan,3)
            fprintf('%s through %s\n',subobj,meas);
        end
    end
    fprintf('\n');
    else
        fprintf('Panel %s has a score of 0\n',pan);
    end
end
R = input('Press any key to continue\n');

%% Fully satisfied
fprintf('*******************************************\n');
fprintf('Subobjectives fully satisfied:\n');
fprintf('*******************************************\n');


for i = 1:full.size
    sb = full.get(i-1);

    tmp = params.subobjectives_to_measurements.get(strcat('?*subobj-',sb,'*'));
    fprintf('Fully satisfies %s because it measures %s\n',char(sb), char(tmp.get(0)));
end
R = input('Press any key to continue\n');
%% Partially satisfied
fprintf('*******************************************\n');
fprintf('Partially satisfied subobjectives by %s:\n',instr);
fprintf('*******************************************\n');

for i = 1:partial.size
    sb = partial.get(i-1);
        % explain why
    tmp = params.subobjectives_to_measurements.get(strcat('?*subobj-',sb,'*'));
    fprintf('Partially satisfies %s (score = %f) because it measures %s\n',char(sb), scores.get(char(sb)), char(tmp.get(0)));
    [facts,values] = my_jess_query(['REASONING::partially-satisfied (subobjective ' char(sb) ' )'],'attribute');
end
R = input('Press any key to continue\n');
%% Potential
fprintf('*******************************************\n');
fprintf('Potential but completely missed subobjectives by %s:\n',instr);
fprintf('*******************************************\n');

if strcmp(type,'instrument')
    potential = params.instruments_to_subobjectives.get(instr);
elseif strcmp(type,'mission')
    [~,values] = my_jess_query('CAPABILITIES::Manifested-instrument','Name');
    potential = params.instruments_to_subobjectives.get(values{1});
    for j = 2:length(values)
       potential.addAll(params.instruments_to_subobjectives.get(values{j})); 
    end
end
for i = 1:potential.size
    sb = potential.get(i-1);
    if ~names.contains(sb)
        % explain why
        tmp = params.subobjectives_to_measurements.get(strcat('?*subobj-',sb,'*'));
        meas = char(tmp.get(0));
        fprintf('Could satisfy %s because it measures %s but it completely misses it\n',char(sb), meas);
        str = jess_value(r.eval(['(ppdefrule REQUIREMENTS::subobjective-' char(sb) '-nominal)']));
        tmp2 = regexp(str,'SameOrBetter (?<att>\S+)\s(?<var>\S+)\s(?<thr>\S+)','names');
        
        for j = 1:length(tmp2)
            thr = tmp2(j).thr;
            fprintf('Required: %s = %s\n',tmp2(j).att,thr);
            [facts,values] = my_jess_query(['REQUIREMENTS::Measurement (Parameter ' meas ')'],tmp2(j).att);
        end
        clear facts values;
        tmp3 = regexp(str,'\(defrule (?<lhs>.+) (not (REASONING::fully-satisfied (?<rest>.+)\)','names');
        tmp2 = regexp(tmp3.lhs,'\((?<att>\S+)\s(?<thr>\S+)\)','names');
        for j = 1:length(tmp2)
            thr = tmp2(j).thr;
            if ~strncmp(thr,'?',1)
                fprintf('*************\n');
                fprintf('Required: %s = %s\n',tmp2(j).att,thr);
            end
            [facts,values] = my_jess_query(['REQUIREMENTS::Measurement (Parameter ' meas ')'],tmp2(j).att);
            fprintf('*************\n');
        end
        R = input('Press any key to continue\n');

    end
end
end