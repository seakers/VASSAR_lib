function [typ,h,inc,raan] = get_orbit_params(str)
tmp = regexp(str, '(?<type>\w*)-(?<h>\w*)-(?<inc>\w*)-(?<raan>\w*)', 'names');
typ = tmp.type;
h = tmp.h;
inc = tmp.inc;
raan = tmp.raan;
end