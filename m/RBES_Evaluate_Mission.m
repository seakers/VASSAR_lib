%% RBES_Evaluate_Mission.m
function [score,panel_scores,objective_scores,subobjective_scores,data_continuity_score,data_continuity_matrix,cost,orbit,lv_pack] = RBES_Evaluate_Mission(mission)
global params
r = global_jess_engine();
n = length(mission.instrument_list);
if n == 0
    score = 0;
    panel_scores = [];
    objective_scores = [];
    subobjective_scores = [];
    data_continuity_score = [];
    data_continuity_matrix = [];
    orbit = [];
    lv_pack = [];
    cost = 0;
    return;
end

if n>2 || params.USE_LOOKUP_TABLES == 0 %% (Option by default)
    %% Reset 
    clear explanation_facility
    jess reset;

    %% Assert Mission

    if iscell(mission.instrument_list)
        instr_list_str = StringArraytoStringWithSpaces(mission.instrument_list);
    else
        instr_list_str = mission.instrument_list;
    end

    call = ['(assert (MANIFEST::Mission (Name ' char(mission.name) ')' ...
            ' (instruments ' instr_list_str ')' ...
            ' (lifetime ' num2str(mission.lifetime) ')' ...
            ' (launch-date ' num2str(mission.launch_date) ')' ...
            ' (select-orbit yes)'];

    if ~isfield(mission.orbit,'altitude')
        call = [call ' (mission-architecture ' char(mission.architecture) ')' ...
            ' (num-of-planes# ' num2str(mission.orbit.nplanes) ')' ...
            ' (num-of-sats-per-plane# ' num2str(mission.orbit.nsats_per_plane) ')' ...
            ' (select-orbit yes) '];
    else 
        call = [call ' (mission-architecture ' char(mission.architecture) ')' ...
            ' (num-of-planes# ' num2str(mission.orbit.nplanes) ')' ...
            ' (num-of-sats-per-plane# ' num2str(mission.orbit.nsats_per_plane) ')' ...
            ' (orbit-type ' char(mission.orbit.type) ')' ...
            ' (orbit-altitude# ' num2str(mission.orbit.altitude) ')' ...
            ' (orbit-RAAN ' char(mission.orbit.raan) ')' ...
            ' (orbit-inclination ' char(mission.orbit.inclination) ')' ...
            ' (orbit-eccentricity ' num2str(mission.orbit.e) ')' ...
            ' (select-orbit no) '];
    end
    
    if ~isempty(mission.partnership)
        call = [call ' (partnership-type (create$ ' num2str(de2bi(mission.partnership)) ' ))'];
    else
        
    end
    
    call = [call '))'];% close Mission and assert
    r.eval(call);

    if params.CROSS_REGISTER
        call = ['(assert (SYNERGIES::cross-registered-instruments '...
            ' (instruments ' instr_list_str ') '...
            ' (degree-of-cross-registration spacecraft) '...
            ' (platform ' char(mission.name) ' ) '...
            '))' ];
        r.eval(call);
    end
    results = RBES_Evaluate_Manifest3;
%     orbit = results.orbit;
    score = results.score;
    cost = results.cost;
    lv_pack = results.lv_pack_factor;
    panel_scores = results.panel_scores;
    objective_scores = results.objective_scores;
    subobjective_scores = results.subobjective_scores;
    data_continuity_score = results.data_continuity_score;
%     data_continuity_matrix = results.data_continuity_matrix;
    data_continuity_matrix = results.dcmatrix_without_precursors;

elseif n == 2 %% && params.USE_LOOKUP_TABLES == 1
    pairs_subobjective_scores = RBES_get_parameter('pairs_subobjective_scores');
    subobj = pairs_subobjective_scores.get(mission.instrument_list);
    score = RBES_get_score_from_subobj_struct(subobj);
    cost = 0;
    panel_scores = 0;
    
else %% n == 1 && params.USE_LOOKUP_TABLES == 1
    subobjective_scores_singles = RBES_get_parameter('subobjective_scores_singles');
    subobj = subobjective_scores_singles.get(mission.instrument_list);
    cost = 0;
end

end
