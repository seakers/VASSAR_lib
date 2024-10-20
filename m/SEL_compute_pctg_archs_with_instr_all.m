%% SEL_compute_pctg_archs_with_instr.m
function [pctgs,dsm] = SEL_compute_pctg_archs_with_instr_all(archs)
global params
narc = size(archs,1);
pctgs = (sum(archs,1)./narc)';
ninstr = length(params.instrument_list);
dsm = zeros(ninstr,ninstr);
for i = 1:ninstr-1
    for j = i+1:ninstr
        dsm(i,j) = SEL_compute_pctg_archs_with_instrs(archs,{params.instrument_list{i},params.instrument_list{j}});
    end
end
end