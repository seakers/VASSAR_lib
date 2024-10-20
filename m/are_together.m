function yes = are_together(instr1,instr2,arch)
global params
i1 = strcmp(params.packaging_instrument_list,instr1);
i2 = strcmp(params.packaging_instrument_list,instr2);
yes = arch(i1) == arch(i2);
end