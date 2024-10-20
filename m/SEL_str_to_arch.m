function arch = SEL_str_to_arch(str)
global params
instr_list = regexp(str,'\s','split');
arch = false(1,length(params.instrument_list));
for j = 1:length(instr_list)
        instr = instr_list{j};
        index = strcmp(params.instrument_list,instr);
        arch(index) = true;
end
end