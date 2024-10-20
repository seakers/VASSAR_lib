function [lvs,lv_pack_factors,lv_costs] = PACK_recompute_lvs(archs,results)
global params
instr_list = params.packaging_instrument_list;
narc = size(archs,1);
lvs = cell(narc,1);
lv_costs = zeros(narc,1);
for i = 1:narc
    fprintf('Recomputing launch vehicles of arch %d of %d\n',i,narc);
    arch = archs(i,:);
    orbits = results.orbits{i};
    nsat = length(orbits);
    cost_sats= zeros(nsat,1);
    tmp = cell(nsat,1);
    for s = 1:nsat
        sat_instrs = instr_list(arch==s);
        sat_name = [char(params.satellite_names)  num2str(s)];
        mission = create_test_mission(sat_name,sat_instrs,params.startdate,params.lifetime,get_orbit_struct_from_string(orbits{s}));  
        [~,~,~,~,~,~,cost_sats(s),~,~] = RBES_Evaluate_Mission(mission);
        [~,values] = my_jess_query('MANIFEST::Mission','launch-vehicle');
        tmp{s} = char(values{1});
        [~,values] = my_jess_query('MANIFEST::Mission','launch-cost#');
        lv_costs(i) = lv_costs(i) + str2double(char(values{1}));
    end
    lvs{i} = tmp;
    
end
lv_pack_factors = results.lv_pack_factors;
end
