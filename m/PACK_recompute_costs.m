function [costs0,costs1] = PACK_recompute_costs(archs,results)
global params
instr_list = params.packaging_instrument_list;
costs0 = results.costs;
costs1 = zeros(size(costs0));
narc = size(archs,1);
for i = 1:narc
    fprintf('Recomputing costs of arch%d of %d\n',i,narc);
    arch = archs(i,:);
    orbits = results.orbits{i};
    nsat = length(orbits);
    cost_sats= zeros(nsat,1);
    for s = 1:nsat
        sat_instrs = instr_list(arch==s);
        sat_name = [char(params.satellite_names)  num2str(s)];
        mission = create_test_mission(sat_name,sat_instrs,params.startdate,params.lifetime,get_orbit_struct_from_string(orbits{s}));  
        [~,~,~,~,~,~,cost_sats(s),~,~] = RBES_Evaluate_Mission(mission);
    end
    costs1(i) = sum(cost_sats);
end
plot(costs0,costs1,'bx');
end
