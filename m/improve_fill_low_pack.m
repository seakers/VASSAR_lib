function new_arch = improve_fill_low_pack(varargin)
global params
ninstr = length(params.packaging_instrument_list);
arch = cell2mat(varargin(1:ninstr));
if length(varargin)>ninstr
    pack_factors = cell2mat(varargin(ninstr+1:end));
    empty_lv = find(pack_factors < 0.66,1);
    new_arch = arch;
    if ~isempty(empty_lv)
        instrs = find(arch ~= empty_lv);
        tmp = randi(length(instrs));
        ind = instrs(tmp);%this instr to be moved to empty_lv
        new_arch(ind) = empty_lv;
    end
    new_arch = PACK_fix(new_arch);
else
    new_arch = arch;
end
end