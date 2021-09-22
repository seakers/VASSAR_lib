function h = get_orbit_altitude(str)
tmp = regexp(str, '(?<type>\w*)-(?<h>\w*)-(?<inc>\w*)-(?<raan>\w*)', 'names');
h = tmp.h;
end