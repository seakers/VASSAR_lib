function archs = PACK_generate_random_archs(narc)
global params
ninstr = length(params.packaging_instrument_list);
max_sats = get_max_nsats();
if max_sats == 0 
    max_sats = ninstr;
end
rand_integers = randi(max_sats ,[narc ninstr]);

% pack_fix
archs = PACK_fix_archs(rand_integers);
archs = unique(archs,'rows');
end

