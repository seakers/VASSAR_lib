function [i,num] = get_orbit_inclination(str)
tmp = regexp(str, '(?<type>\w*)-(?<h>\w*)-(?<inc>\w*)-(?<raan>\w*)', 'names');
i = tmp.inc;
if isnumeric(i)
    num = i;
else
    if strcmp(i,'SSO')
        num = SSO_h_to_i(str2double(tmp.h));
    elseif strcmp(i,'polar')
        num = 90;
    elseif strcmp(i,'ISS')
        num = 51.6;
    elseif strcmp(i,'tropical')
        num = 30;
    elseif strcmp(i,'equat')
        num = 0;
    else
        error('Unknown inclination');
    end
end
end