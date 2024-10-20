%% SEL_compute_pctg_archs_with_instr.m
function pctg = SEL_compute_pctg_archs_with_instrs(archs,instruments)
global params
masks = cellfun(@(x)strcmp(params.instrument_list,x),instruments,'UniformOutput',false);
mask = or(masks{1},masks{2})';
narc = size(archs,1);
mat = archs.*repmat(mask,[size(archs,1) 1]);
pctg = sum(sum(mat,2)==2)/narc;
end