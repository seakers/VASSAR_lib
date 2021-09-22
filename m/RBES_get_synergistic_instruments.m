function instr_list = RBES_get_synergistic_instruments(instr)
global params
instr_list = params.packaging_science_DSM.get(instr);
% instr_list = cell(instr_list.toArray);
end