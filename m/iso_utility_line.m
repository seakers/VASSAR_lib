function [x,y] = iso_utility_line(u0,w_dc,dvmin,dvmax,dcmin,dcmax)
% returns the two vectors [x1 x2] [y1 y2] such that the line that passess
% through (x1,y1) and (x2,y2) is the iso-utility u0
udv1 = (u0)/ (1 - w_dc);
x1 = u_to_mag(udv1,dvmin,dvmax);
y1 = dcmin;

udc2 = (u0)/w_dc;
y2 = u_to_mag(udc2,dcmin,dcmax);
x2 = dvmin;

x = [x1 x2];
y = [y1 y2];
end