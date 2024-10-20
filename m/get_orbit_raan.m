function [raan,num] = get_orbit_raan(str)
tmp = regexp(str, '(?<type>\w*)-(?<h>\w*)-(?<inc>\w*)-(?<raan>\w*)', 'names');
raan = tmp.raan;
offset = 1.7595;%  ok for Jan 1 2013
switch raan
    case 'AM'
        num = offset + 7.5*pi/12;
    case 'PM'
        num = offset + 13.5*pi/12;
    case 'DD'
        num = offset + 6*pi/12;
    case 'NA'
        num = 0.0;
    otherwise
        error('raan unknown');
end
        
end
