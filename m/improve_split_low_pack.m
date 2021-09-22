function new_arch = improve_split_low_pack(varargin)
global params
ninstr = length(params.packaging_instrument_list);
arch = cell2mat(varargin(1:ninstr));
if length(varargin)>ninstr
    pack_factors = cell2mat(varargin(ninstr+1:end));
    
    sats = PACK_arch2sats(arch);

    empty_lv = find(pack_factors < 0.66);
    if ~isempty(empty_lv)
        ind = randi(length(empty_lv));
        sat = empty_lv(ind);% this sat index to be broken up
        sats = break_sat(sats,sat);
    end
    new_arch = PACK_fix(PACK_sats2arch(sats));
else
    new_arch = arch;
end
end