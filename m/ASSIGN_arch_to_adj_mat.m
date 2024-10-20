function mat= ASSIGN_arch_to_adj_mat(arch)
% arch = [1 1 2 3 3];
% mat = [1 0;1 0;0 1;1 1;1 1]
global params
norb = length(params.orbit_list);
nins = length(params.assign_instrument_list);
mat = zeros(nins,norb);
for i = 1:nins
    mat(i,:) = de2bi(arch(i),norb);
    
end
end