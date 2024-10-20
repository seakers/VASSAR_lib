function load_aggregation_rules()
global params
r = global_jess_engine();
[num,txt,~] = xlsread(params.value_aggregation_xls);

%% Level 1: Stakeholders
tmp = num(:,1);
tmp = tmp(~isnan(tmp));
params.num_stakeholders = length(tmp) - 1; % minus 1 for total 100%
params.sh_names = cell(params.num_stakeholders,1);
params.sh_weights = tmp(1:params.num_stakeholders);
params.obj_weights = cell(params.num_stakeholders,1);
params.subobj_weights = cell(params.num_stakeholders,1);

call = '(deffacts AGGREGATION::STAKEHOLDERS "All stakeholders" (AGGREGATION::VALUE (satisfaction nil)) '; 
rule = '(defrule AGGREGATION::compute-total-benefit "Total benefit" ?val <- (AGGREGATION::VALUE (satisfaction nil)) '; 
add_to_rule = '(bind ?x (+ ';   
for i = 1:params.num_stakeholders
    params.sh_names{i} = txt{i+2,2};
    call = [call ' (AGGREGATION::STAKEHOLDER (name ' params.sh_names{i} ')) '];
    rule = [rule ' (AGGREGATION::STAKEHOLDER (name ' params.sh_names{i} ') (satisfaction ?sat' num2str(i) '&~nil)) '];
    add_to_rule = [add_to_rule '(* ' num2str(params.sh_weights(i)) ' ?sat' num2str(i) ') '];
end
call = [call ')'];
rule = [rule ' => ' add_to_rule ')) (modify ?val (satisfaction ?x)))'];%%% FINISH THIS CALCULATION DO WEIGHTED AVERAGE HERE AND IN OTHER RULES
r.eval(call);
r.eval(rule);

%% Level 2: Stakeholder needs / objectives
ind = num(:,6);
change = diff(isnan(ind));
pos = find(change==-1) + 1;% index of row of 1st subobjective of each objective in num matrix
pos2 = find(change == 1) - 1; % index of row of last subobjective of each objective in num matrix
call = '(deffacts AGGREGATION::STAKEHOLDER_OBJECTIVES "Stakeholder needs" '; 

for p = 1:params.num_stakeholders
    rule = ['(defrule AGGREGATION::compute-benefit-stakeholder-' params.sh_names{p} ' "Benefit of stakeholder " ?sh <- (AGGREGATION::STAKEHOLDER (name ' params.sh_names{p} ') (satisfaction nil)) ']; 
    add_to_rule = '(bind ?x (+ ';   
    params.obj_weights{p} = num(pos(p):pos2(p),6); 
    for o = 1:length(params.obj_weights{p})
        call = [call ' (AGGREGATION::OBJECTIVE (id ' params.sh_names{p} '-' num2str(o) ') (owner ' params.sh_names{p} ')) '];
        rule = [rule ' (AGGREGATION::OBJECTIVE (id ' params.sh_names{p} '-' num2str(o) ') (satisfaction ?sat' num2str(o) '&~nil)) '];
        add_to_rule = [add_to_rule '(* ' num2str(params.obj_weights{p}(o)) ' ?sat' num2str(o) ') '];
    end 
    
    rule = [rule ' => ' add_to_rule ')) (modify ?sh (satisfaction ?x)))'];
   
    r.eval(rule);
end
call = [call ')'];
r.eval(call);
params.num_objectives_per_sh = cellfun(@length,params.obj_weights);
params.num_objectives = sum(params.num_objectives_per_sh);

%% Level 3: Requirements

nsubobj = 0;

for p = 1:params.num_stakeholders
    params.subobj_weights{p} = cell(params.num_objectives_per_sh(p),1);
    col = num(:,11+ 5*(p-1));
    change = diff(isnan(col));
    pos = find(change==-1) + 1;% index of row of 1st subobjective of each objective in num matrix
    pos2 = find(change == 1) - 1; % index of row of last subobjective of each objective in num matrix
    if length(pos)>length(pos2)
        pos2(end+1) = size(num,1)-1;
    end
    for o = 1:params.num_objectives_per_sh(p)
        params.subobj_weights{p}{o} = num(pos(o):pos2(o),11+ 5*(p-1));
        add_to_rule = '(bind ?x (+ ';   
        rule = ['(defrule AGGREGATION::compute-benefit-objective-' params.sh_names{p} '-' num2str(o) ' "Benefit of objective " ?obj <- ( AGGREGATION::OBJECTIVE (id ' params.sh_names{p} '-' num2str(o) ') (satisfaction nil)) ']; 
        for so = 1:length(params.subobj_weights{p}{o})
            rule = [rule ' (REQUIREMENTS::Measurement (satisfaction ?sat' num2str(so) '&~nil)) '];
            add_to_rule = [add_to_rule '(* ' num2str(params.subobj_weights{p}{o}(so)) ' ?sat' num2str(so) ') '];
        end
        rule = [rule ' => ' add_to_rule ')) (modify ?obj (satisfaction ?x)))'];%%% FINISH THIS CALCULATION DO WEIGHTED AVERAGE HERE AND IN OTHER RULES
        r.eval(rule);
    end
    nsubobj = nsubobj + sum(cellfun(@length,params.subobj_weights{p}));
end
params.num_subobjectives = nsubobj;
end