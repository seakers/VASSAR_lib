%% RBES_Init_params_common.m
function RBES_Init_params_common(varargin)
global params
if isempty(params) || nargin > 0
    fprintf('Im in Dropbox\n');
    %% Paths for Java classes
    params.javaaddpath = cell(1,3);
    params.javaaddpath{1} = '.\java\jess.jar';
    params.javaaddpath{2} = '.\java\EOLanguage.jar';
    params.javaaddpath{3} = '.\java\matlabcontrol-4.0.0.jar';
    % params.javaaddpath{3} = 'C:\Users\dani\Documents\NetBeansProjects\EOLanguage\build\classes\';


    %% Paths for common xls files 
    params.template_definition_xls          = '.\xls\AttributeSet';
    params.attribute_inheritance_rules_xls  = '.\xls\Attribute Inheritance Rules.xlsx';
    params.mission_analysis_database_xls    = '.\xls\Mission Analysis Database4.xlsx';
    params.data_continuity_xls              = '.\xls\Data Continuity Requirements.xlsx';
    params.synergy_rules_xls                = '.\xls\Synergy Rules.xlsx';
    params.precursor_missions_xls_path      = '.\xls\misc\CEOS timelines 1993-2024\';

    %% Paths for common (all) clp files
    params.module_definition_clp        = '.\\clp\\modules.clp';
    params.attribute_inheritance_clp    = '.\\clp\\attribute_inheritance_rules.clp';
    params.capability_rules_clp         = '.\\clp\\capability_rules.clp';
    params.synergy_rules_clp            = '.\\clp\\synergy_rules.clp';
    params.explanation_rules_clp        = '.\\clp\\explanation_rules.clp';
    params.fuzzy_attribute_clp          = '.\\clp\\fuzzy_attribute_rules.clp';
    params.assimilation_rules_clp       = '.\\clp\\assimilation_rules.clp';
    params.orbit_selection_rules_clp    = '.\\clp\\orbit_selection_rules.clp';
    params.launch_vehicle_selection_rules_clp    = '.\\clp\\launch_vehicle_selection_rules_new.clp';
    params.standard_bus_selection_rules_clp    = '.\\clp\\standard_bus_selection_rules.clp';
    params.EPS_design_rules_clp         = '.\\clp\\eps_design_rules.clp';
    params.mass_budget_rules_clp        = '.\\clp\\mass_budget_rules.clp';
    params.adcs_design_rules_clp        = '.\\clp\\adcs_design_rules.clp';
    params.propulsion_design_rules_clp        = '.\\clp\\propulsion_design_rules.clp';
    params.subsystem_mass_budget_rules_clp        = '.\\clp\\subsystem_mass_budget_rules.clp';
    params.deltaV_budget_rules_clp        = '.\\clp\\deltaV_budget_rules.clp';
    params.cost_estimation_rules_clp    = '.\\clp\\cost_estimation_rules.clp';
    params.cost_estimation_rules_standard_bus_clp    = '.\\clp\\cost_estimation_rules_standard_bus.clp';
    params.enumeration_rules_selection_clp        = '.\\clp\\enumeration_rules_sel.clp';
    params.enumeration_rules_packaging_clp        = '.\\clp\\enumeration_rules_pack.clp';
    params.enumeration_rules_scheduling_clp        = '.\\clp\\enumeration_rules_sched.clp';
    params.enumeration_rules_assigning_clp        = '.\\clp\\enumeration_rules_assign.clp';
    params.search_heuristic_rules_selection_clp   = '.\\clp\\search_heuristic_rules_sel.clp';
    params.search_heuristic_rules_packaging_clp   = '.\\clp\\search_heuristic_rules_pack.clp';
    params.search_heuristic_rules_scheduling_clp   = '.\\clp\\search_heuristic_rules_sched.clp';
    params.search_heuristic_rules_assigning_clp   = '.\\clp\\search_heuristic_rules_assign.clp';
    
    params.down_selection_rules_selection_clp     = '.\\clp\\down_selection_rules_sel.clp';
    params.down_selection_rules_packaging_clp     = '.\\clp\\down_selection_rules_pack.clp';
    params.down_selection_rules_scheduling_clp     = '.\\clp\\down_selection_rules_sched.clp';
    params.down_selection_rules_assigning_clp     = '.\\clp\\down_selection_rules_assign.clp';
    
    params.template_definition_clp                = '.\\clp\\templates.clp';
    params.aggregation_rules_clp                 = '.\\clp\\aggregation_rules.clp';

    %% Data continuity params
    
    params.timestep     = (2/12);% 1 month

    params.CEOS_to_RBES_measurements_map = create_CEOS_to_RBES_measurements_map(params);
    timeframe = (params.enddate - params.startdate)/params.timestep + 1;

    % Create HashMap containing list of Measurements
    [num,txt] = xlsread(params.template_definition_xls,'Measurement');
    txt = txt(:,2:end);
    ind_param = find(strcmp(txt,'Parameter'));
    nmeas = num(ind_param-1,3) - 1;
    params.map_of_measurements = java.util.HashMap;
    measurements = txt(ind_param,5:5+nmeas-1)';
    for i = 1:nmeas
        params.map_of_measurements.put(measurements{i},i);
    end

    [num,~,~] = xlsread(params.data_continuity_xls,'Measurement Importance');
    params.measurement_weights_for_data_continuity = num(:,1)';% want row vector

    [num,~,~] = xlsread(params.data_continuity_xls,'Discounting Scheme');
    timeframe = (params.enddate - params.startdate)/params.timestep + 1;
    params.data_continuity_weighting_scheme = num(2:timeframe+1,2);

    meas = params.map_of_measurements.keySet.iterator;
    params.list_of_measurements_for_data_continuity = java.util.HashMap;
    params.reverse_map_of_measurements = java.util.HashMap;
    n = 0;
    while meas.hasNext()
        m = meas.next();
        id = params.map_of_measurements.get(m);
        im = params.measurement_weights_for_data_continuity(id);
        params.reverse_map_of_measurements.put(id,m);
        if im > 0

            n = n + 1;
            params.list_of_measurements_for_data_continuity.put(n,m);
        end
    end

    % Create or load precursor missions data continuity matrix
    % params.missions_to_be_considered = 'NASA only, no Decadal';
    


    load HashMapPrecursorMatrices
    [num,~,raw] = xlsread(params.data_continuity_xls,'Missions to consider');
    option = find(strcmp(raw(1,:),params.missions_to_be_considered));
    list_of_missions_tbc = raw(logical([0;num(:,option-1)]),1);% -1 because num does not contain first column, 0 because it does not contain first row
    params.list_of_missions_tbc = java.util.ArrayList;
    for i = 1:length(list_of_missions_tbc)
        params.list_of_missions_tbc.add(list_of_missions_tbc{i});
    end

    FORCE_RECOMPUTE = 0;
    need_recompute = ~HashMapPrecursorMatrices.containsKey(params.list_of_missions_tbc);
    if FORCE_RECOMPUTE || need_recompute
        disp('Precursor missions continuity matrix not found or not up-to-date. (Re)computing matrix...'); 
        Compute_precursors_data_continuity_matrix();% computes params.precursors_data_continuity_matrix
        HashMapPrecursorMatrices.put(params.list_of_missions_tbc,params.precursors_data_continuity_matrix)
        save HashMapPrecursorMatrices HashMapPrecursorMatrices
        disp('Added new matrix to HashMapPrecursorMatrices');
    else
        disp('Precursor missions continuity matrix found. Reusing matrix...');
        params.precursors_data_continuity_matrix = cell(HashMapPrecursorMatrices.get(params.list_of_missions_tbc));
        params.precursors_data_continuity_boolean_matrix = not(cellfun(@isEmpty,params.precursors_data_continuity_matrix));
        params.precursors_data_continuity_integer_matrix = cellfun(@size,params.precursors_data_continuity_matrix);
    end
    
    %% Watch
    params.WATCH = 0;

    % Memory management
    clearvars -except r params arch instr
    params.MEMORY_SAVE = 1;

    
end
end