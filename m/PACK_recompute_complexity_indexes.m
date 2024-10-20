function [compl_indexes,compl_indexes2] = PACK_recompute_complexity_indexes(archs,results)
global params
r = global_jess_engine();
instr_list = params.packaging_instrument_list;
narc = size(archs,1);
compl_indexes = zeros(narc,1);
compl_indexes2 = zeros(narc,1);
for i = 1:narc
    fprintf('Recomputing complexity factors for arch %d of %d\n',i,narc);
    arch = archs(i,:);
    orbits = results.orbits{i};
    nsat = length(orbits);
    mass_at_penalties = zeros(nsat,7);
    mass_at_launch_costs = zeros(nsat,9);
    total_payload = 0;
    for s = 1:nsat
        sat_instrs = instr_list(arch==s);
        sat_name = [char(params.satellite_names)  num2str(s)];
        mission = create_test_mission(sat_name,sat_instrs,params.startdate,params.lifetime,get_orbit_struct_from_string(orbits{s}));  
        RBES_Evaluate_Mission(mission);
        r.eval(['(bind ?results (run-query* GUI::show-engineering-penalties ' sat_name '))']);
        jess ?results next;
        jess bind ?adcs (?results getDouble adcs);
        jess bind ?mech (?results getDouble mech);
        jess bind ?scan (?results getDouble sc);
        jess bind ?th (?results getDouble th);
        jess bind ?emc (?results getDouble emc);
        jess bind ?rb (?results getDouble rb);
        jess bind ?lv (?results getString lv);
        jess bind ?orb (?results getString orb);
        jess bind ?mass (?results getDouble mass);
        jess bind ?cost (?results getDouble cost);
        adcs = jess_value(r.eval('?adcs'));
        mech = jess_value(r.eval('?mech'));
        scan = jess_value(r.eval('?scan'));
        th = jess_value(r.eval('?th'));
        emc = jess_value(r.eval('?emc'));
        rb = jess_value(r.eval('?rb'));
        npenalties = adcs + mech + scan + th + emc + rb;
        [~,values] = my_jess_query('MANIFEST::Mission','payload-mass#');
        mass_at_penalties(s,npenalties+1) = mass_at_penalties(s,npenalties+1) + str2double(char(values{1}));
        [~,values2] = my_jess_query('MANIFEST::Mission','launch-vehicle');
        launch_vehicle = char(values2{1});
        if strcmp(launch_vehicle,'Atlas5-class')
            lv = 1;
        elseif strcmp(launch_vehicle,'Delta7920-class')
            lv = 2;
        elseif strcmp(launch_vehicle,'Delta7420-class')
            lv = 3;
        elseif strcmp(launch_vehicle,'Delta7320-class')
            lv = 4;
        elseif strcmp(launch_vehicle,'MinotaurIV-class')
            lv = 5;
        elseif strcmp(launch_vehicle,'Taurus-XL-class')
            lv = 6;
        elseif strcmp(launch_vehicle,'Taurus-class')
            lv = 7;
        elseif strcmp(launch_vehicle,'Pegasus-class')
            lv = 8;
        elseif strcmp(launch_vehicle,'Shuttle-class')
            lv = 9;
        end
        mass_at_launch_costs(s,lv) = mass_at_launch_costs(s,lv) + str2double(char(values{1}));
        total_payload = total_payload + str2double(char(values{1}));
    end
    compl_indexes(i) = (sum(mass_at_penalties,1)./total_payload)*[0 1 2 3 4 5 6]';
    compl_indexes2(i) = (sum(mass_at_launch_costs,1)./total_payload)*[110 65 55 45 35 30 20 15 500]';
end
end
