function results = RBES_Evaluate_Manifest
%% RBES_Evaluate_Manifest.m
% This function assumes that missions have been manifested and evaluates
% them, giving a single score to them as a whole

global params
r = global_jess_engine();

%% COMMON SCIENCE AND COST
RBES_assert_instruments;% assert instruments and inherit their attributes

% Find optimal orbits
orbit = RBES_Select_Orbit;% with orbit selection rules
% orbit = RBES_Select_Orbit2;% with optimization of orbits

%% COST
if params.ESTIMATE_COST
    jess undefadvice (create$ >= <= < > sqrt + * **);
   
    % Assign a preliminary launch vehicle based on payload for spacecraft configuration
    RBES_Select_LaunchVehicle;

    % Assign a standard bus
    if strcmp(params.BUS,'STANDARD')
        RBES_Select_StandardBus;
    end
    
    % Power budget
    RBES_design_EPS;

    % Mass budget
    [mass,bus] = RBES_mass_budget;
    
    % Assign a final launch vehicle
    clean_launch_vehicle_selections;
    [lv,lv_pack_factor] = RBES_Select_LaunchVehicle;
    
    % Lifecycle cost
    [total_cost,nsat] = RBES_cost_estimate;
    
    
end

%% SCIENCE
if params.ESTIMATE_SCIENCE
    jess bind ?*science-multiplier* 1.0;
    jess defadvice before (create$ >= <= < >) (foreach ?xxx $?argv (if (eq ?xxx nil) then (return FALSE)));
    jess defadvice before (create$ sqrt + * **) (foreach ?xxx $?argv (if (eq ?xxx nil) then (bind ?xxx 0)));
%% Assert instruments and get their properties
    jess focus MANIFEST;
    jess run;

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
%         RBES_fuzzy_attributes;
%         RBES_precompute_science;
%         RBES_synergies;
        RBES_measurement_assimilation2;
        RBES_fuzzy_attributes;
        RBES_synergies;
    else
        RBES_fuzzy_attributes;
%         [r,params] = RBES_science_requirements(r,params);% Focus REQUIREMENTS and run to get value
%         RBES_precompute_science;
        num = RBES_synergies;
        if num==20000
            disp('Warning: Synergy rules stopped prematurely');
        end
    end
    
%     [r,params] = RBES_science_requirements(r,params);% Focus REQUIREMENTS and run to get value
    RBES_science_requirements;
    jess undefadvice (create$ >= <= < > sqrt + * **);
    RBES_aggregation;
    
    [score,panel_scores,objective_scores,subobjective_scores] = compute_scientific_benefit;
%     if strcmp(params.MODE,'SCHEDULING') || strcmp(params.MODE,'PACKAGING')
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
    %jess undefadvice (create$ >= <= < > sqrt + * **);
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
    results.orbit                       = orbit;
    results.cost                        = total_cost;
    results.nsat                        = nsat;
    results.lv_pack_factor              = lv_pack_factor;
    results.launch_vehicle              = lv;
    results.satellite_mass              = mass;
    results.standard_bus                = bus;
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