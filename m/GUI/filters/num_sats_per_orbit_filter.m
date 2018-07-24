function [ret,labels] = num_sats_per_orbit_filter(arch)
% Assign numerical values in increasing order set by labels
global params
ret = arch.getNsats;
labels = cellfun(@num2str,num2cell(1:1:params.nsats(end)),'UniformOutput', false);
	
end