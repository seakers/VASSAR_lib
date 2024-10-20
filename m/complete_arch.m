function new_seq = complete_arch(seq)
%% complete_arch.m
global params

instr_list = params.instrument_list(logical(de2bi(seq,length(params.instrument_list))));
obj_list = RBES_objectives_from_instrument_list(instr_list);
missing_objectives = RBES_missing_objectives(obj_list);
if missing_objectives.size > 0
    obj = missing_objectives.get(randi([0 missing_objectives.size-1],1));
    candidate_instruments = RBES_who_satisfies(obj);
    instr = candidate_instruments.get(randi(candidate_instruments.size,1)-1);
    pos = strcmp(params.instrument_list,instr);
    bi = de2bi(seq,length(params.instrument_list));
    bi(pos) = true;
    new_seq = bi2de(bi);
else
    new_seq = seq;
end

    
end