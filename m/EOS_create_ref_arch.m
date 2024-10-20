%% EOS_create_ref_arch.m
% This version of the reference architecture repeats several instruments to
% simulate cross-registration. It is not suitable for cost estimation.
% Daniel Selva Jan 8th 2012
ref_missions{1} = create_test_mission('ALT',{'ALT-SSALT','TMR','GGI'},1990,8,[]);
ref_missions{2} = create_test_mission('TERRA',{'ASTER','MODIS','MISR','MOPITT','CERES','CERES-B','CERES-C'},1990,8,[]); % TERRA
ref_missions{3} = create_test_mission('AQUA',{'AIRS','AMSU-A','HSB','CERES-C','AMSR-E','MODIS'},1990,8,[]); % AQUA
ref_missions{4} = create_test_mission('AURA',{'OMI','HIRDLS','MLS','TES','GLAS','MODIS'},1990,8,[]); % AURA science = 0.206609, cost = 1130.322189
ref_missions{5} = create_test_mission('SEAWINDS',{'SEAWINDS'},1990,8,[]);% SEAWINDS
ref_missions{6} = create_test_mission('SEAWIFS',{'SEAWIFS'},1990,8,[]);% SEAWIFS
% ref_missions{7} = create_test_mission('SAR',{'SAR'},1990,8,[]);% SAR
% full_set{8} = create_test_mission('POL',{'EOSP'},1990,8,[]);% POL
ref_missions{7} = create_test_mission('SORCE',{'ACRIM','SOLSTICE','LIS'},1990,8,[]);% ACRIM
% ref_missions{8} = create_test_mission('WIND',{'MISR'},1990,8,[]);% WIND
ref_missions{8} = create_test_mission('ICE',{'GLAS','MODIS','AMSR-E'},1990,8,[]);% ICE
ref_missions{9} = create_test_mission('SAGE',{'SAGE-III'},1990,8,[]);
ref_arch.selection = SEL_ref_arch;% 25 instruments
ref_arch.packaging = PACK_fix([7 3 1 3 3 2 2 1 8 4 3 7 2 4 2 2 4 9 6 5 7 4 1 2 3]); % 1 x 25 array of integers 
% disp('done');
% [science,total_cost] = PACK_evaluate_architecture3(ref_arch)
% 
% science =
% 
%     0.9025
% 
% 
% total_cost =
% 
%   5.3969e+003