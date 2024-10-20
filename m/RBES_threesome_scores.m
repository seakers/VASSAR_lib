%% RBES_threesome_scores.m
function special_subobjective_scores = RBES_threesome_scores(special_subobjective_scores,synergistic_instruments)
% synergistic_instruments = {'GACM_VIS','GACM_SWIR','GACM_MWSP','GACM_DIAL','GEO_STEER','GEO_GCR','GEO_WAIS','ACE_POL','ACE_LID'};
% n = length(synergistic_instruments);
global params
payloads = combnk(synergistic_instruments,3);% this is a (N*(N-1),2) cell
n = size(payloads,1);
for i = 1:n
    fprintf('Mission %d from %d\n',i,n);
    mission = create_test_mission(['ThreeSome' num2str(i)],payloads(i,:),params.startdate,params.lifetime,[]);
    [scor,panel_score,objective_scor,subobjective_scor2,data_continuity_score,data_continuity_matrix,cos] = RBES_Evaluate_Mission(mission);
    [names,full,partial,scores] = RBES_find_objectives_satisfied(subobjective_scor2,0);
    special_subobjective_scores.put(payloads(i,:),full);
end
end