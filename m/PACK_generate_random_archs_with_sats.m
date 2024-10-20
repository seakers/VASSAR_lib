function archs = PACK_generate_random_archs_with_sats(narc,nsat)
%% PACK_generate_random_archs_with_sats.m

global params
ninstr = length(params.packaging_instrument_list);
archs = zeros(narc,ninstr);
i = 1;
while i <= narc
    tmp = ones(1,ninstr);
    for n = 2:ninstr
            tmp(n) = 1+round(min(max(tmp),nsat-1)*rand);
    end
    if i>1
        tmp2 = unique([archs(1:i-1,:); tmp],'rows');
    end
    
    if max(tmp) == nsat && (i==1 || (size(tmp2,1) == size(archs(1:i-1,:),1) + 1))
        archs(i,:) = tmp;
        i = i + 1;
    end
end
end