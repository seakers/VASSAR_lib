%% assert_test_mission.m
function assert_test_mission(mission_name,instrument_list,launchdate,lifetime)
r = global_jess_engine();
% mission.name = mission_name;
% mission.orbit.altitude = 700;
% mission.orbit.inclination = 98;
% mission.orbit.nplanes = 1;
% mission.orbit.nsats_per_plane = 1;
% % mission.instrument_list = {'BIOMASS','LORENTZ_ERB','CTECS','GRAVITY'};
% mission.instrument_list = instrument_list;
% mission.architecture = 'single-sat';
% mission.launch_date = launchdate;
% mission.lifetime = lifetime;

     
call = ['(assert (MANIFEST::Mission (Name ' mission_name ')' ...
        ' (instruments ' StringArraytoStringWithSpaces(instrument_list) ')' ...
        ' (lifetime ' num2str(lifetime) ')' ...
        ' (launch-date ' num2str(launchdate) ')' ...
        '))'];
    
    
r.eval(call);
    
end


