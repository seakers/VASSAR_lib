function results = RBES_Evaluate_Manifest3
%% RBES_Evaluate_Manifest3.m
% This function assumes that missions and instruments have been manifested and evaluates
% them, giving a single score to them as a whole

global params
r = global_jess_engine();


%% COST
if params.ESTIMATE_COST
    jess focus MANIFEST;
    jess run;
    
    masses = RBES_design_spacecraft;
    
    jess focus SAT-CONFIGURATION;
    jess run;
  
    [lv,lv_pack_factor] = RBES_Select_LaunchVehicle;
    [total_cost,nsat] = RBES_cost_estimate;
end

%% SCIENCE
if params.ESTIMATE_SCIENCE
    jess bind ?*science-multiplier* 1.0;
    jess defadvice before (create$ >= <= < >) (foreach ?xxx $?argv (if (eq ?xxx nil) then (return FALSE)));
    jess defadvice before (create$ sqrt + * **) (foreach ?xxx $?argv (if (eq ?xxx nil) then (bind ?xxx 0)));
%% Assert instruments and get their properties
%     jess focus MANIFEST;
%     jess run;

    if params.MEMORY_SAVE
        % remove manifest rules, not needed anymore
        list_rules = r.listDefrules();
        while list_rules.hasNext()
            rule = list_rules.next().getName();
            if rule.startsWith('MANIFEST')
                r.removeDefrule(rule);
            end
        end
    end
    RBES_assert_measurements;% Focus CAPABILITIES and run to get REQUIREMENTS::measurements
    
    if params.ASSIMILATION % Synergy-assimilation-fuzzy iterative sequence
        RBES_measurement_assimilation2;
        RBES_fuzzy_attributes;
        RBES_synergies;
    else
        RBES_fuzzy_attributes;
        num = RBES_synergies;
        if num==20000
            disp('Warning: Synergy rules stopped prematurely');
        end
    end
    
    RBES_science_requirements;
    jess undefadvice (create$ >= <= < > sqrt + * **);
    RBES_aggregation;
    
    [score,panel_scores,objective_scores,subobjective_scores] = compute_scientific_benefit;
    if params.DATA_CONTINUITY == 1
        [data_continuity_score,data_continuity_matrix,dcmatrix_without_precursors] = check_data_continuity2;
    else
        data_continuity_score = [];
        data_continuity_matrix = [];
        dcmatrix_without_precursors = [];
    end

    if params.EXPLANATION
        clear explanation_facility;
        RBES_explanations;
    end
end



%% RESULTS

if params.ESTIMATE_SCIENCE
    results.score                       = score;
    results.panel_scores                = panel_scores;
    results.objective_scores            = objective_scores;
    results.subobjective_scores         = subobjective_scores;
    results.data_continuity_score       = data_continuity_score;
    results.data_continuity_matrix      = data_continuity_matrix;
    results.dcmatrix_without_precursors = dcmatrix_without_precursors;
else
    results.score                       = 0;
    results.panel_scores                = [];
    results.objective_scores            = [];
    results.subobjective_scores         = [];
    results.data_continuity_score       = [];
    results.data_continuity_matrix      = [];
    results.dcmatrix_without_precursors = [];   
end

if params.ESTIMATE_COST
%     results.orbit                       = orbit;
    results.cost                        = total_cost;
    results.nsat                        = nsat;
    results.lv_pack_factor              = lv_pack_factor;
    results.launch_vehicle              = lv;
    results.satellite_mass              = masses;
%     results.standard_bus                = bus;
else
    results.cost                        = 0;
    results.nsat                        = 0;
    results.orbit                      = [];
    results.lv_pack_factor              = 0;
    results.launch_vehicle              = [];
    results.satellite_mass              = 0;
    results.standard_bus                = [];
end


end