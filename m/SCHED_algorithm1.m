%% SCHED_algorithm1.m
% RBES_desktop;
% RBES_Init_Params_EOS(1);
% RBES_set_parameter('MODE','SCHEDULING');
% RBES_set_parameter('SCHEDULING',1);
% 
% RBES_Init_WithRules;
RBES_set_parameter('TEST',0);

jess unwatch all;
jess reset;

%% COMPUTE MISSION SCORES, REF ARCHITECTURE AND UPDATE PARAMS
% disp('Computing mission scores...');
% results = SCHED_compute_mission_scores;
    
% ref = SCHED_ref_arch();
% res = SCHED_evaluate_architecture3(ref.arch);
% ref.discounted_value = res.discounted_value;
% ref.data_continuity = res.data_continuity;

% RBES_set_parameter('ref_sched_arch',ref);
% RBES_set_parameter('SCHED_ref_discounted_value',ref_res.discounted_value);
% RBES_set_parameter('SCHED_ref_data_continuity_score',ref_res.data_continuity_score);

%% INITIAL POPULATION
% Architectures to be considered
% % examples of given architectures
disp('Initial population...');
TEST = RBES_get_parameter('TEST');
if TEST
    SCHED_assert_test_archs;
else
%     load('C:\Users\Ana-Dani\Dropbox\RBES\results\EOS results\packaging\aft_select-16-Jan-2012-22-28.mat');
%     results = SCHED_convergence(results,archs);
%     load('C:\Users\dani\Documents\My Dropbox\RBES\results\EOS results\scheduling\aft_select-26-Jan-2012-17-34.mat')
%     load('C:\Users\Ana-Dani\Dropbox\RBES\results\EOS results\scheduling\aft_select-26-Jan-2012-21-53.mat');
%     load('C:\Users\Ana-Dani\Dropbox\RBES\results\EOS results\scheduling\aft_select-12-Feb-2012-8-41.mat');
%     load('C:\Users\Ana-Dani\Dropbox\RBES\results\EOS results\scheduling\aft_select-23-Feb-2012-18-0.mat');
%     init_archs = archs;
%     init_results = results;
%     RBES_assert_architectures('scheduling',init_archs,init_results);
    SCHED_assert_test_archs;
end



%% Loop
disp('Loop...');

NIT = 10;
for i = 1:NIT
    fprintf('*************************************************\n');
    fprintf('SCHEDULING algorithm: starting generation %d from %d...\n',i,NIT);
    
    [these_results,archs] = SCHED_one_iteration();
    
    fprintf('Finished generation %d from %d, with %d architectures\n',i,NIT,size(archs,1));
    these_results = SCHED_convergence(these_results,archs);
    fprintf('*************************************************\n');
    close all;
    pause(1);
    SCHED_plot_results(these_results,archs,i);
    pause(1);
end