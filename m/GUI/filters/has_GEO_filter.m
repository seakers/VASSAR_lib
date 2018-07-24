function [ret,labels] = has_GEO_filter(arch)
% Assign numerical values in increasing order set by labels
labels = {'LEO only','has GEO'};% First level is ret = 0, second ret = 1 
tmp = arch.getPayloadInOrbit('GEO-35788-equat-NA');
if tmp.length>0 == 1
    ret = 1;
else
    ret = 0;
end
end