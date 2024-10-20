function [nplanes,nsatsperplane] = Iridium_satellite_id_to_orbit(sats)
%% Iridium_satellite_id_to_orbit.m
% 
% Usage:
% sats = find(arch == 1);% = [1 3 5 7 9 66];
% [nplanes,nsatsperplane] = Iridium_satellite_id_to_orbit(sats)
% Note that this function assumes that all planes have identical number of
% satellites
%

% Iridium satellites ids
Iridium_sat_orbit_params(:,1) = [1:66]';
Iridium_sat_orbit_params(:,2) = ceil(Iridium_sat_orbit_params(:,1)/11);
Iridium_sat_orbit_params(:,3) = mod(Iridium_sat_orbit_params(:,1)-1,11) + 1;

planeId = Iridium_sat_orbit_params(sats,2);
inPlaneId = Iridium_sat_orbit_params(sats,3);
nplanes = length(unique(planeId));

% assume all planes have equal #sats
nsatsperplane = length(inPlaneId(planeId == 1));
return

