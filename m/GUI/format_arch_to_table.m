function ret1 = format_arch_to_table( arch )
    global params
    % Initialize the variables
    ret1 = cell(10,10);
    for i = 1:10
        for j = 1:10
            ret1{i,j} = '';
        end
    end
    orbits = params.orbit_list;
%     ret1(1,1:2) = {'Num sats per plane' num2str(arch.getNsats())};
    ret1{1,1} = ['Architecture ' num2str(arch.getId)];
    ret1{2,1} = ['Benefit = ' num2str(arch.getResult.getScience)];
    ret1{3,1} = ['Cost = ' num2str(arch.getResult.getCost)];
    ret1(4,1:8) = {'Orbit' 'Num sats in orbit' 'Instrument 1' 'Instrument 2' 'Instrument 3' 'Instrument 4' 'Instrument 5' 'Instrument 6'};
    for o = 1:length(orbits)
        ret1{o+4,1} = char(params.orbit_list(o));
        ret1{o+4,2} = num2str(arch.getNsats());
        tmp= arch.getPayloadInOrbit(params.orbit_list(o));
        for j = 1:length(tmp)
            ret1{o+4,j+2} = char(tmp(j));
        end
    end
end
