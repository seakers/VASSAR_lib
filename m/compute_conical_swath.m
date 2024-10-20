function [sw,res,range] = compute_conical_swath(h,off,fov,f,D,B)
%% 
% Usage: sw = compute_conical_swath(h,off,fov)
% sw in same units as h, off and fov in deg
sw = 2*h*(tan(pi/180*(off+fov/2)));
dtheta = 3e8/f/D;
res = h*(tan(off*pi/180+dtheta/2)-tan(off*pi/180-dtheta/2));
range = 3e8/2/B/sin(off*pi/180);
end