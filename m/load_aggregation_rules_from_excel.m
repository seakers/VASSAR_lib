function load_aggregation_rules_from_excel
%% load_aggregation_rules_from_excel.m
global params
r = global_jess_engine();

% load_rules_from_excel('C:\Documents and Settings\Dani\My Documents\PhD\research\projects\Rule-based System Architecting\Decadal Objective Rule Definition.xlsx','Weather');
[num,txt,~]= xlsread(params.aggregation_rules_xls,'Aggregation rules');

%% One of a kind rules (new measurements)
r.eval(['(bind ?aggreg_rules_clp "' params.aggregation_rules_clp '")']);
r.eval('(batch ?aggreg_rules_clp)');

%% 0th level of decomposition: Panels and panel weights
tmp = num(:,1);
tmp = tmp(~isnan(tmp));
params.npanels = length(tmp) - 1; % minus 1 for total 100%
params.panel_weights = tmp(1:params.npanels);
params.panel_names = cell(params.npanels,1);
call = '(deffacts AGGREGATION::init-aggregation-facts ';
for i = 1:params.npanels
    params.panel_names{i} = txt{i+2,2};
    call = [call ' (AGGREGATION::VALUE (sh-scores (create$ ' num2str(-1.0*ones(1,params.npanels),'%1.1f ') ' )) (weights (create$ ' num2str(params.panel_weights') '))) '];
end

%% 1st level of decomposition: panel objectives and objective weights
% ind1 = 4;
% ind2 = ind1 + nobj_panels(1) - 1;
ind = num(:,6);
change = diff(isnan(ind));
pos = find(change==-1) + 1;% index of row of 1st subobjective of each objective in num matrix
pos2 = find(change == 1) - 1; % index of row of last subobjective of each objective in num matrix
params.obj_weights = cell(params.npanels,1);
for p = 1:params.npanels
    params.obj_weights{p} = num(pos(p):pos2(p),6);
    call = [call ' (AGGREGATION::STAKEHOLDER (id ' params.panel_names{p} ' ) (index ' num2str(p) ' ) (obj-scores (create$ ' num2str(-1.0*ones(1,length(params.obj_weights{p})),'%1.1f ') ' )) (weights (create$ ' num2str(params.obj_weights{p}') '))) '];
end
params.num_objectives_per_panel = cellfun(@length,params.obj_weights);

%% 2nd level of decomposition: subobjectives and subobjective weights
% ind2 = -1;% init pa que cuadre p = 1

params.subobj_weights = cell(params.npanels,1);


for p = 1:params.npanels
    params.subobj_weights{p} = cell(params.num_objectives_per_panel(p),1);
    col = num(:,11+ 5*(p-1));
    change = diff(isnan(col));
    pos = find(change==-1) + 1;% index of row of 1st subobjective of each objective in num matrix
    pos2 = find(change == 1) - 1; % index of row of last subobjective of each objective in num matrix
       
    for o = 1:params.num_objectives_per_panel(p)
        params.subobj_weights{p}{o} = num(pos(o):pos2(o),11+ 5*(p-1));
        call = [call ' (AGGREGATION::OBJECTIVE (id ' params.panel_names{p} num2str(o) ' ) (subobj-scores (create$ ' num2str(-1.0*ones(1,length(params.subobj_weights{p}{o})),'%1.1f ') ' )) (index ' num2str(o) ' ) (parent ' params.panel_names{p} ') (weights (create$ ' num2str(params.subobj_weights{p}{o}') '))) '];
%         for so = 1:length(params.subobj_weights{p}{o})
%             call = [call ' (AGGREGATION::SUBOBJECTIVE (satisfaction 0.0) (id ' params.panel_names{p} num2str(o) '-' num2str(so) ' ) (index ' num2str(so) ' ) (parent ' params.panel_names{p} num2str(o) ') ) '];
%         end
    end
end
params.subobj_weights_map = subobj_weight_map();

%% Prepare for calculations
params.subobjectives = cell(params.npanels,1);
nobj = 1;
for p = 1:params.npanels
    params.subobjectives{p} = cell(params.num_objectives_per_panel(p),1);
    for o = 1:params.num_objectives_per_panel(p)
        params.subobjectives{p}{o} = params.subobj_names(nobj,1:length(params.subobj_weights{p}{o}));
        nobj = nobj + 1;
    end
end
call = [call ')'];
r.eval(call);

return
