function seq = get_seq_from_instr(instr)
instr_list =  RBES_get_parameter('instrument_list');
mask = zeros(1,length(instr_list));
for i = 1:length(instr)
    index = cellfun(@(x)strcmp(x,instr{i}),instr_list);
    mask(index) = 1;
end
seq = bi2de(mask);
end