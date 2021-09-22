function archs = PACK_generate_random_archs2(narc)
global params
ninstr = length(params.packaging_instrument_list);
max_sats = get_max_nsats();
archs = zeros(narc,ninstr);
for i = 1:narc
    tmp = ones(1,ninstr);
    for n = 2:ninstr
            tmp(n) = 1+round(min(max(tmp),max_sats-1)*rand);
    end
    archs(i,:) = tmp;
end
end