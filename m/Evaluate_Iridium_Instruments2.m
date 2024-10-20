%% Evaluate_Iridium_Instruments2.m
% RBES_Init_Params_Iridium;
% [r,params] = RBES_Init_WithRules(params);
%% Iridium orbit

% orbit.altitude = 800;
% orbit.i = 'polar';
% orbit.raan = 'NA';
% orbit.type = 'LEO';
% orbit.nsatsperplane = 11;
% orbit.nplanes = 6;
orbit = get_Iridium_orbit();
%% Mission set
mission_set{1} = create_test_mission('BIOMASS',{'BIOMASS'},2015,5,orbit);
mission_set{2} = create_test_mission('LORENTZ_ERB',{'LORENTZ_ERB'},2015,5,orbit);
mission_set{3} = create_test_mission('CTECS',{'CTECS'},2015,5,orbit);
mission_set{4} = create_test_mission('GRAVITY',{'GRAVITY'},2015,5,orbit);
mission_set{5} = create_test_mission('SPECTROM',{'SPECTROM'},2015,5,orbit);
mission_set{6} = create_test_mission('MICROMAS',{'MICROMAS'},2015,5,orbit);
mission_set{7} = create_test_mission('REFLECTOM',{'REFLECTOM'},2015,5,orbit);
% mission_set{9} = create_test_mission('ALL_SYSTEM',{'ALL_SYSTEM'},2015,5,orbit);

params.SYNERGIES = 1;
[score_vec,panel_scores_mat,data_continuity_score_vec,lists,cost_vec,subobjective_scores,dc_matrices,orbits] = RBES_Evaluate_MissionSet(mission_set);

% params.SYNERGIES = 0;
% [r,score_vec2,panel_scores_mat2,data_continuity_score_vec2,lists2] = RBES_Evaluate_MissionSet(r,mission_set,params);


