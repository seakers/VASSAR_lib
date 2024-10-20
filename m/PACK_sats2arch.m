function arch = PACK_sats2arch(sats)
% PACK_sats2arch.m
% Example: 
% sats{1} = [1,2,3,7];
% sats{2} = [4,5,6,8];
% sats{3} = [9];
% arch = PACK_sats2arch(sats)
% arch = [1,1,1,2,2,2,1,2,3]

nsats = length(sats);
ninstr = sum(cellfun(@length,sats));
arch = zeros(1,ninstr);
for i = 1:nsats
    sat = sats{i};
    arch(sat) = i;
end
end