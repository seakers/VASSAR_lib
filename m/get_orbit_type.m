function type = get_orbit_type(str)
tmp = regexp(str, '(?<type>\w*)-(?<h>\w*)-(?<inc>\w*)-(?<raan>\w*)', 'names');
type = tmp.type;
end