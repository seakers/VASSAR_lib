function mission = create_test_Decadal_mission(mission_name,instrument_list,launchdate,lifetime)
mission.name = mission_name;
mission.orbit.altitude = 800;
mission.orbit.inclination = 'SSO';
mission.orbit.nplanes = 1;
mission.orbit.nsats_per_plane = 1;
% mission.instrument_list = {'BIOMASS','LORENTZ_ERB','CTECS','GRAVITY'};
mission.instrument_list = instrument_list;
mission.architecture = 'single-sat';
mission.launch_date = launchdate;
mission.lifetime = lifetime;


