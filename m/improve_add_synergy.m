function new_arch = improve_add_synergy(varargin)
global params
arch = cell2mat(varargin);
missing_synergies = PACK_get_missing_synergies(arch);
new_arch = arch;
n = size(missing_synergies,1);
if n > 0
    synergy_to_add = missing_synergies(randi(n),:);
    instr1 = strcmp(params.packaging_instrument_list,synergy_to_add{1});
    instr2 = strcmp(params.packaging_instrument_list,synergy_to_add{2});
    new_arch(instr2) = new_arch(instr1);
    new_arch = PACK_fix(new_arch);
else
end
end