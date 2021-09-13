%% Iridium_run_sensitivity_analysis.m
arch = repmat([1 0 0 0 0 1 0 0 0 0 0],[1 6]);
sensit_results = RBES_sensitivity_analysis_instrument_attributes_Iridium([], [], 'BIOMASS', arch);
save sensit_results_BIOMASS sensit_results;
close all;

arch = repmat([2 0 0 0 0 2 0 0 0 0 0],[1 6]);
sensit_results = RBES_sensitivity_analysis_instrument_attributes_Iridium([], [], 'LORENTZ_ERB', arch);
save sensit_results_LORENTZ sensit_results;
close all;


arch = repmat([3 0 0 0 0 3 0 0 0 0 0],[1 6]);
sensit_results3 = RBES_sensitivity_analysis_instrument_attributes_Iridium([], [], 'CTECS', arch);
save sensit_results_CTECS sensit_results;
close all;

arch = repmat([4 0 0 0 0 4 0 0 0 0 0],[1 6]);
sensit_results = RBES_sensitivity_analysis_instrument_attributes_Iridium([], [], 'GRAVITY', arch);
save sensit_results_GRAVITY sensit_results;
close all;

arch = repmat([5 0 0 0 0 5 0 0 0 0 0],[1 6]);
sensit_results = RBES_sensitivity_analysis_instrument_attributes_Iridium([], [], 'SPECTROM', arch);
save sensit_results_SPECTROM sensit_results;
close all;
