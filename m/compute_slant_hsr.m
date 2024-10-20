function dx = compute_slant_hsr(h,off,fov)
%% 
% Usage: dx = compute_slant_hsr(h,off,fov)
% dx in same units as h, off and fov in deg
dx = h*(tan(pi/180*(off+fov/2))-tan(pi/180*(off-fov/2)));
end