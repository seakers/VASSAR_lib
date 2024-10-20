function h = PACK_entropy(arch)
ninstr = PACK_ninstr_per_sat(arch);
h = sum(-(ninstr{1}./sum(ninstr{1})).*log2(ninstr{1}./sum(ninstr{1})))./log2(length(arch));

end