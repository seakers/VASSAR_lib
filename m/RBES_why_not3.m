function RBES_why_not3(subobj)
global params
%% Get subobj score
[facts,values] = my_jess_query(['AGGREGATION::SUBOBJECTIVE (id ' subobj ' )'],'satisfaction',0);

score = -1;
index = -1;
for i = 1:length(values)
    val = str2double(char(values{i}));
    if val>score
        score = val;
        index = i;
    end
end
if score == 1
    fprintf('Subobj %s gets a perfect score \n',subobj);
    return;  
else
    tmp = params.subobjectives_to_measurements.get(['?*subobj-' subobj '*']);
    meas = tmp.get(0);
    [facts2,values2] = my_jess_query(['REQUIREMENTS::Measurement (Parameter ' meas ' )'],'Parameter',0);
    if isempty(facts2)       
        fprintf('Subobj %s gets a score of 0  because no measurement of parameter %s is found:\n',subobj,meas);
        return;
    else
        lost = params.subobj_weights_map.get(subobj)*(1-score);
        fprintf('Subobj %s (meas %s) gets a score of %f (loss of %.3f value) because:\n',subobj,meas,score,lost);
    end
    
end


%% Get explanations
attribs = jess_value(facts{index}.getSlotValue('attributes'));
reasons = jess_value(facts{index}.getSlotValue('reasons'));

att_scores = cell2mat(jess_value(facts{index}.getSlotValue('attrib-scores')));
for i=1:length(att_scores)
    if att_scores(i) < 1.0
        fprintf('Atribute %s gets a score of %f because of %s\n',attribs{i},att_scores(i),reasons{i})
    end
end
 
end