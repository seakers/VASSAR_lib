function results = RBES_science_assessment(r,params)
%% RBES_science_assessment.m
% This function computes the scientific benefit and data continuity score
% of all the manifested missions
% Assumes missions already manifested

%% Focus MANIFEST and run to assert manifested instruments and get their attributes
[r,params] = RBES_assert_instruments(r,params); % also attribute inheritance

%% Focus CAPABILITIES and run to get measurements and their attributes
[r,params] = RBES_assert_measurements(r,params); % also attribute inheritance

%% Synergy-assimilation-fuzzy iterative sequence
if params.ASSIMILATION
    [r,params] = RBES_synergies(r,params);
    [r,params] = RBES_measurement_assimilation(r,params);
    [r,params] = RBES_fuzzy_attributes(r,params);
else
    [r,params] = RBES_fuzzy_attributes(r,params);
    [r,params] = RBES_synergies(r,params);
end

%% Focus REQUIREMENTS and run to get value
[r,params] = RBES_science_requirements(r,params);

[score,panel_scores,objective_scores,subobjective_scores] = compute_scientific_benefit(r,params);
if params.SCHEDULING
    [data_continuity_score,data_continuity_matrix,dcmatrix_without_precursors] = check_data_continuity2(r,params);
end


%% Print results
if params.EXPLANATION
    [r,params] = RBES_explanations(r,params);
end

%% Gather results
results.score                       = score;
results.panel_scores                = panel_scores;
results.objective_scores            = objective_scores;
results.subobjective_scores         = subobjective_scores;
if params.SCHEDULING
    results.data_continuity_score       = data_continuity_score;
    results.data_continuity_matrix      = data_continuity_matrix;
    results.dcmatrix_without_precursors = dcmatrix_without_precursors;
end
end