%% ASSIGN_algorithm1.m
% RBES_desktop;
% RBES_Init_Params_EOS('ASSIGNING');
% RBES_set_parameter('MODE','ASSIGNING');
% RBES_Init_WithRules;
% 
TEST =1;
jess unwatch all;
jess reset;
% 
% %% EVAL REF ARCHITECTURE
% disp('Evaluating reference architecture...');
% ASSIGN_ref_arch(1);
    
%% INITIAL POPULATION
% Architectures to be considered
% % examples of given architectures
% jess reset;
if TEST
    ASSIGN_assert_test_archs;
else  
    load XX;
    init_archs = archs;
    init_results = results;
    RBES_assert_architectures('assigning',init_archs,init_results);
%     results = ASSIGN_convergence(results,archs);
end



%% Loop
NIT = 2;
for i = 1:NIT
    fprintf('*************************************************\n');
    fprintf('ASSIGN algorithm: starting generation %d from %d...\n',i,NIT);
    [these_results,archs] = ASSIGN_one_iteration(); 
    fprintf('Finished generation %d from %d, with %d architectures\n',i,NIT,size(archs,1));
%     these_results = ASSIGN_convergence(these_results,archs);
    fprintf('*************************************************\n');
    close all;
%     pause(1);
%     ASSIGN_plot_results(these_results,archs,i);
%     pause(1);
%     save_best_orbits();
end