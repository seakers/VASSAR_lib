function [ret,labels] = in_ISS_orbit_filter(arch)
% Assign numerical values in increasing order set by labels
labels = {'no ISS','in ISS orbit'};% First level is ret = 0, second ret = 1 
tmp = arch.getPayloadInOrbit('LEO-600-ISS-NA');
if tmp.length>0 == 1
    ret = 1;
else
    ret = 0;
end
end