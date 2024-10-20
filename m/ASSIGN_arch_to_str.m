function str = ASSIGN_arch_to_str(arch)
orbits = RBES_get_parameter('orbit_list');
norb = length(orbits);
rhs_nodes = cell(2^norb - 1,1);
for dec = 1:2^norb - 1
    bi = de2bi(dec,norb);
    rhs_nodes{dec} = StringArraytoStringWith(orbits(logical(bi)),'&');
end
str = StringArraytoStringWithSpaces(rhs_nodes(arch));
end