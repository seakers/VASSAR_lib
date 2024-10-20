%% create_test_Iridium_mission_set.m
mission_set = cell(6,1);
mission_set{1} = create_test_mission({'BIOMASS'},2013,5);
mission_set{2} = create_test_mission({'LORENTZ_ERB'},2014,5);
mission_set{3} = create_test_mission({'CTECS'},2014,5);
mission_set{4} = create_test_mission({'GRAVITY'},2015,5);
mission_set{5} = create_test_mission({'SPECTROM'},2015,5);
mission_set{6} = create_test_mission({'MICROMAS'},2015,5);