function instr_list = get_instr_from_seq(seq)
% load EOS_Instrument_names5
instrument_list = RBES_get_parameter('instrument_list');
instr_list = StringArraytoStringWithSpaces(instrument_list(logical(de2bi(seq,length(instrument_list)))));
end