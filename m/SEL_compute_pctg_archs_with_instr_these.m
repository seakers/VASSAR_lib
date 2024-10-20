%% SEL_compute_pctg_archs_with_instr.m
function [pctgs,dsm] = SEL_compute_pctg_archs_with_instr_these(archs,instruments)
narc = size(archs,1);
pctgs = (sum(archs,1)./narc)';
ninstr = length(instruments);
dsm = zeros(ninstr,ninstr);
for i = 1:ninstr-1
    for j = i+1:ninstr
        dsm(i,j) = SEL_compute_pctg_archs_with_instrs(archs,{instruments{i},instruments{j}});
    end
end
end