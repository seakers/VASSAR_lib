function risk = SEL_compute_programmatic_risk(arch)
global params
instrums = params.instrument_list;
all_trls = RBES_get_instrument_TRLs(instrums);
my_trls = all_trls(logical(arch'));
risk = sum(my_trls<5)/length(my_trls);
end