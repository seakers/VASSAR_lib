function str = PACK_arch_to_str(arch)
sats = PACK_arch2sats2(RBES_get_parameter('packaging_instrument_list'),arch);
str = '';
for i = 1:length(sats)
    sat = sats{i};
    str = [str StringArraytoStringWithSpaces(sat)];
    if i<length(sats)
        str = [str ' & '];
    end
end
end