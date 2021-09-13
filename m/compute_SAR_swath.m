function [sw,res,range] = compute_SAR_swath(h,off,scan,f,D,B)
%% 
% Usage: sw = compute_conical_swath(h,off,fov)
% sw in same units as h, off and fov in deg
dtheta = 3e8/f/D;
sw = h*(tan(off*pi/180+scan/2)-tan(off*pi/180-scan/2));

res = h*(tan(off*pi/180+dtheta/2)-tan(off*pi/180-dtheta/2));
range = 3e8/2/B/sin(off*pi/180);
end