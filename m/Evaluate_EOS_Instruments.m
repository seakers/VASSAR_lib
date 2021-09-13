%% Evaluate_EOS_Instruments.m
% RBES_Init_Params_EOS;
% [r,params] = RBES_Init_WithRules(params);

% mission_set{1} = create_test_mission('ACRIM',{'ACRIM'},1990,8,[]);
% mission_set{2} = create_test_mission('SOUNDERS',{'AIRS','AMSU-A','HSB'},1990,8,[]);
% 
% orbit.altitude = 1300;
% orbit.i = 'near-polar';
% orbit.raan = 'NA';
% orbit.nsatsperplane = 2;
% orbit.nplanes = 1;
% orbit.type = 'LEO';
% mission_set{3} = create_test_mission('ALTIMETRY',{'ALT-SSALT' 'TMR' 'GGI' 'DORIS'},1990,8,orbit);
% mission_set{4} = create_test_mission('AMSR-E',{'AMSR-E'},1990,8,[]);
% % mission_set{5} = create_test_mission('AMSU-A',{'AMSU-A'},1990,8);
% mission_set{5} = create_test_mission('ASTER',{'ASTER'},1990,8,[]);
% mission_set{6} = create_test_mission('CERES',{'CERES','CERES-B','CERES-C'},1990,8,[]);
% % mission_set{8} = create_test_mission('DORIS',{'DORIS'},1990,8);
% mission_set{7} = create_test_mission('EOSP',{'EOSP'},1990,8,[]);
% % mission_set{10} = create_test_mission('GGI',{'GGI'},1990,8);
% 
% mission_set{8} = create_test_mission('GLAS',{'GLAS'},1990,8,[]);
% mission_set{9} = create_test_mission('HIRDLS',{'HIRDLS'},1990,8,[]);
% % mission_set{13} = create_test_mission('HSB',{'HSB'},1990,8);
% mission_set{10} = create_test_mission('MISR',{'MISR'},1990,8,[]);
% mission_set{11} = create_test_mission('MLS',{'MLS'},1990,8,[]);
% mission_set{12} = create_test_mission('MODIS',{'MODIS','MODIS'},1990,8,[]);
% mission_set{13} = create_test_mission('MOPITT',{'MOPITT'},1990,8,[]);
% mission_set{14} = create_test_mission('OMI',{'OMI'},1990,8,[]);
% % mission_set{19} = create_test_mission('SCANSCAT',{'SCANSCAT'},1990,8);
% mission_set{15} = create_test_mission('SEAWIFS',{'SEAWIFS'},1990,8,[]);
% 
% mission_set{16} = create_test_mission('STIKSCAT',{'STIKSCAT'},1990,8,[]);
% mission_set{17} = create_test_mission('TES',{'TES'},1990,8,[]);
% % mission_set{23} = create_test_mission('TMR',{'TMR'},1990,8);

N = length(params.instrument_list);% num of instruments
kk = 1;% we are interested in pairs
mission_set = cell(N,1);
for i = 1:N
    mission_set{i} = create_test_mission(['EOSSingles' num2str(i)],params.instrument_list(i),1990,8,[]);
end

jess unwatch all
[r,single_scores,panel_scores_mat1,data_continuity_score_vec1,lists1,single_costs] = RBES_Evaluate_MissionSet(r,mission_set,params);

save EOS_single_instrument_scores
% params.SYNERGIES = 0;
% [r,score_vec2,panel_scores_mat2,data_continuity_score_vec2,lists2] = RBES_Evaluate_MissionSet(r,mission_set,params);


