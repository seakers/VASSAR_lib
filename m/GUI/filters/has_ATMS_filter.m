function [ret,labels] = has_ATMS_filter(arch)
global params
% Assign numerical values in increasing order set by labels
labels = {'no ATMS','has ATMS'};% First level is ret = 0, second ret = 1 
hasATMS = false;
for j = 1:length(params.orbit_list)
    tmp = arch.getPayloadInOrbit(params.orbit_list(j));
    for k=1:tmp.length
        if strcmp(char(tmp(k)),'EON_ATMS_1');
            hasATMS=true;
            break;
        end
    end
end
if hasATMS
    ret = 1;
else
    ret = 0;
end
end