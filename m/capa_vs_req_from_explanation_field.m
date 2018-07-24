function [ret,ret2] = capa_vs_req_from_explanation_field(res,subobj,AE,params)
%capa_vs_req Compares capabilities with requirements for a certain subobj
%   Detailed explanation goes here

ret = {};
ret2 = {};

rule = params.requirement_rules.get(subobj);
ret(1,1:2) = {'Id','taken by'};

exp = res.getExplanations.get(subobj);
theparam = params.subobjectives_to_measurements.get(subobj);

%check to see if architecture can even take measurement
hasCapability = false;
for i = 1:exp.size
    if ~strcmp(char(exp.get(i-1).getSlotValue('satisfied-by')),'nil')
        hasCapability = true;
    end
end
if ~hasCapability
    ret2 = cell(1,4);
    ret2{1} = subobj;
    ret2{2} = theparam;
    ret2{3} = num2str(0);
    ret2{4} = 'no one';
    
    return
end

list_of_attributes = jess_value(exp.get(0).getSlotValue('attributes'));
i=0;
while isempty(list_of_attributes)
    list_of_attributes = jess_value(exp.get(i).getSlotValue('attributes'));
    i=i+1;
end
list_of_thresholds = cell(1,rule.size);
list_of_scores = cell(1,rule.size);
for i=1:length(list_of_attributes)
    attrib = list_of_attributes{i};
    tmp = rule.get(attrib);
    thresholds = tmp.get(1);
    scores = tmp.get(2);
    list_of_thresholds{i} = thresholds;
    list_of_scores{i} = scores;
end
ret(2:3,2) = {'{Thresholds)';'(Scores)'};
ret(1,3:2+rule.size) = list_of_attributes;
ret{1,3+rule.size} = 'Data Product Score';
ret(2,3:2+rule.size) = list_of_thresholds;
ret(3,3:2+rule.size) = list_of_scores;


capas = res.getCapabilities;

OFF = 3;
empty_rows = 0;
max_subobj_score = 0;
max_subobj_fact = 'no one';
for i = 1:exp.size
    
    score = jess_value(exp.get(i-1).getSlotValue('satisfaction'));
    attrib_scores = jess_value(exp.get(i-1).getSlotValue('attrib-scores'));
    attrib_vals = jess_value(exp.get(i-1).getSlotValue('attrib-vals'));
    if ~isempty(attrib_vals)
        ret{i+OFF-empty_rows,1} = jess_value(capas.get(i-1).getSlotValue('Id'));
        taken_by = jess_value(capas.get(i-1).getSlotValue('taken-by'));
        ret{i+OFF-empty_rows,2} = taken_by;
        for j=1:rule.size()
            ret{i+OFF-empty_rows,j+2} = [num2str(attrib_vals{j}) ' (' num2str(attrib_scores{j}) ')'];
        end
        
        ret{i+OFF-empty_rows,end} = score;
    else
        empty_rows = empty_rows + 1;
    end
    
    if score > max_subobj_score
        max_subobj_score = score;
        max_subobj_fact = taken_by;
    end
end
ret2 = cell(1,4);
ret2{1} = subobj;
ret2{2} = theparam;
ret2{3} = num2str(max_subobj_score);
ret2{4} = max_subobj_fact;

end
