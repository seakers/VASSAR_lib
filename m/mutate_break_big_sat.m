function new_arch = mutate_break_big_sat(varargin)
arch = cell2mat(varargin);
sats = PACK_arch2sats(arch);
ninstrxsat = cellfun(@length,sats);
bigsats = find(ninstrxsat > 3);
if ~isempty(bigsats)
    ind = randi(length(bigsats));
    sat = bigsats(ind);% this sat index to be broken up
    sats = break_sat(sats,sat);
end
new_arch = PACK_fix(PACK_sats2arch(sats));
end