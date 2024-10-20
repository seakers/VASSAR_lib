function new_arch = mutate_combine_small_sats(varargin)
MAX_ITS = 20;
arch = cell2mat(varargin);
sats = PACK_arch2sats(arch);
ninstrxsat = cellfun(@length,sats);
smallsats = find(ninstrxsat < 3);
if ~isempty(smallsats) && length(smallsats)>1
    same = true;
    its = 1;
    while(same && its < MAX_ITS)
        ind = randi(length(smallsats),[1 2]);% indices of sats to combine
        same = isequal(ind./max(ind),ones(1,2));
        its = its + 1;
    end
    if its <= MAX_ITS
        sat1 = smallsats(ind(1));% sats to combine
        sat2 = smallsats(ind(2));
        sats = merge_sats(sats,sat1,sat2);
    end
end
new_arch = PACK_fix(PACK_sats2arch(sats));

end