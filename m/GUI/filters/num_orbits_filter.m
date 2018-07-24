function [ret,labels] = num_orbits_filter(arch)
% Assign numerical values in increasing order set by labels
global params
norb = 0;
for i = 1:length(params.orbit_list)
    tmp = arch.getPayloadInOrbit(params.orbit_list(i));
    if tmp.length>0 == 1
        norb = norb + 1;
    end
end
ret = norb;
labels = cellfun(@num2str,num2cell(0:1:length(params.orbit_list)),'UniformOutput', false);
	
end