%% Decadal_create_full_set.m
full_set{1} = create_test_mission('ALT',{'ALT-SSALT','TMR','GGI','DORIS'},1990,8,[]);
full_set{2} = create_test_mission('TERRA',{'ASTER','MODIS','MISR','MOPITT','CERES','CERES-B','CERES-C'},1990,8,[]); % TERRA
full_set{3} = create_test_mission('AQUA',{'AIRS','AMSU-A','HSB','CERES-C','AMSR-E','MODIS'},1990,8,[]); % AQUA
full_set{4} = create_test_mission('AURA',{'OMI','HIRDLS','MLS','TES','GLAS','EOSP','MODIS'},1990,8,[]); % AURA science = 0.206609, cost = 1130.322189
full_set{5} = create_test_mission('SEAWINDS',{'SEAWINDS'},1990,8,[]);% SEAWINDS
full_set{6} = create_test_mission('SEAWIFS',{'SEAWIFS'},1990,8,[]);% SEAWIFS
full_set{7} = create_test_mission('SAR',{'SAR'},1990,8,[]);% SAR
% full_set{8} = create_test_mission('POL',{'EOSP'},1990,8,[]);% POL
full_set{8} = create_test_mission('SORCE',{'ACRIM','SOLSTICE'},1990,8,[]);% ACRIM
full_set{9} = create_test_mission('WIND',{'LAWS','MISR','SWIRLS'},1990,8,[]);% WIND
full_set{10} = create_test_mission('ICE',{'GLAS','MODIS','AMSR-E'},1990,8,[]);% ICE
full_set{11} = create_test_mission('TRMM',{'LIS'},1990,8,[]);% ICE
disp('done');