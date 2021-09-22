%% SEL_algorithm1.m
% RBES_desktop;
% RBES_Init_Params_EOS('SELECTION');
% RBES_Init_WithRules;

TEST = 0;
jess unwatch all;
jess reset;

% %% EVAL REF ARCHITECTURE
% disp('Evaluating reference architecture...');
% SEL_ref_arch;
% 
% %% INITIAL POPULATION
% % Architectures to be considered
% % % examples of given architectures
% jess reset;
arch.type = 'selection';
arch.seq = [];
% 
% if TEST
%     disp('Initial population: random');
%     SEL_assert_test_architectures_Decadal;
% else
%     filename = '.\results\EOS results\after_repair-11-Jan-2012-10  27';
%     load(filename);
%     load after_repa'ir-11-Jan-2012-10  27'
%     load('C:\Users\Ana-Dani\Dropbox\RBES\results\EOS results\selection\aft_select-13-Jan-2012-0-11.mat')
%     disp('Initial population: Warm start from Feb 02 2012');
%     load('C:\Users\Ana-Dani\Dropbox\RBES\results\EOS results\selection\aft_select-02-Feb-2012-14-59.mat');
%     SEL_assert_test_architectures;
%     init_archs = archs;
%     init_results = results;
%     RBES_assert_architectures('selection',init_archs,init_results);
%     SEL_assert_test_architectures_Decadal;
% end
% 
% assert ref architecture
ref = SEL_ref_arch;
arch.instruments = get_instr_from_seq(bi2de(ref));
arch.seq = bi2de(ref);
assert_architecture(arch);

% assert full architecture
instrument_list = RBES_get_parameter('instrument_list');
n = length(instrument_list);
full = ones(1,n);
arch.instruments = get_instr_from_seq(bi2de(full));
arch.seq = bi2de(full);
assert_architecture(arch);



%% Loop
NIT = 10;
disp('Loop');
for i = 1:NIT
    fprintf('Starting generation %d from %d...\n',i,NIT);
    [these_results,archs] = SEL_one_iteration();
    fprintf('Finished generation %d from %d, with %d architectures...\n',i,NIT,size(archs,1));
    close all;
    pause(1);
    SEL_plot_results(these_results,archs,i);
    pause(1);
end
