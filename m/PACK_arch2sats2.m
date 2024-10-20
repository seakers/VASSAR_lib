function sats = PACK_arch2sats2(instr_list,arch)
% PACK_arch2sats2.m
% Example: 
% sats = PACK_arch2sats2(params.instrument_list,[1,1,1,2,2,2,1,2,3])
% sats{1} = {'I1','I2','I3','I7'};
% sats{2} = {'I4','I5','I6','I8'};
% sats{3} = {'I9'};

nsats = max(arch);
sats = cell(nsats,1);
for i = 1:nsats
    sats{i} = instr_list(arch==i);
end
end