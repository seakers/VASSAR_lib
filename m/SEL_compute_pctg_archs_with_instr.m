%% SEL_compute_pctg_archs_with_instr.m
function pctg = SEL_compute_pctg_archs_with_instr(archs,instrument)
global params
mask = strcmp(params.instrument_list,instrument)';
narc = size(archs,1);
mat = archs.*repmat(mask,[size(archs,1) 1]);
tmp = sum(mat,2);
pctg = sum(tmp==1)/narc;
end