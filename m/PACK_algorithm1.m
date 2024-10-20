%% PACK_algorithm1.m
% RBES_desktop;
% RBES_Init_Params_EOS('PACKAGING');
% % RBES_set_parameter('MODE','PACKAGING');
% RBES_Init_WithRules;
% 
TEST = 0;
jess unwatch all;
jess reset;
% 
% %% EVAL REF ARCHITECTURE
% disp('Evaluating reference architecture...');
PACK_ref_arch(1);
DC = RBES_get_parameter('DATA_CONTINUITY');
    
%% INITIAL POPULATION
% Architectures to be considered
% % examples of given architectures
% jess reset;
if TEST
    PACK_assert_test_archs;
else
%     load('C:\Users\Ana-Dani\Dropbox\RBES\results\EOS results\packaging\aft_select-05-Feb-2012-16-38.mat');
%     load('C:\Users\Ana-Dani\Dropbox\RBES\results\EOS results\packaging\aft_select-20-Feb-2012-12-36.mat');
%     load('C:\Users\dani\Documents\My Dropbox\RBES\results\EOS results\packaging\bef_downsel-20-Feb-2012-15-38.mat');
%     load('C:\Users\Ana-Dani\Dropbox\RBES\results\EOS results\packaging\aft_select-20-Feb-2012-17-54.mat');
%     results.launch_risks = 1 - PACK_compute_entropies(archs);
%     load('C:\Users\Ana-Dani\Dropbox\RBES\results\Decadal results\packaging\aft_select-15-Mar-2012-12-21.mat');
%     load('C:\Users\Ana-Dani\Dropbox\RBES\results\Decadal results\packaging\bef_downsel-16-Mar-2012-10-46.mat')
%     load('C:\Users\Ana-Dani\Dropbox\RBES\results\Decadal results\packaging\aft_select-26-Mar-2012-3-13.mat');
%     load('C:\Users\Ana-Dani\Dropbox\RBES\results\Decadal results\packaging\aft_select-30-Mar-2012-19-7.mat');
%     load('C:\Users\Ana-Dani\Dropbox\RBES\results\Decadal results\packaging\bef_downsel-08-Apr-2012-18-13.mat');
%     load('C:\Users\dani\Documents\My Dropbox\RBES\results\Decadal results\packaging\aft_select-08-Apr-2012-18-13.mat');
%     load('C:\Users\Ana-Dani\Dropbox\RBES\results\Decadal results\packaging\aft_select-10-Apr-2012-16-14.mat');
%     load('C:\Users\dani\Documents\My Dropbox\RBES\results\EOS results\packaging\aft_select-09-Apr-2012-12-22.mat');

%    load('C:\Users\dani\Documents\My Dropbox\RBES\results\EOS results\packaging\aft_select-15-Apr-2012-9-48.mat');
%     load('C:\Users\Ana-Dani\Dropbox\RBES\results\Decadal results\packaging\aft_select-15-Apr-2012-15-22.mat');
%     load('C:\Users\Ana-Dani\Dropbox\RBES\results\Decadal results\packaging\aft_select-19-Apr-2012-10-1.mat')
    load('C:\Users\Ana-Dani\Dropbox\RBES\results\Decadal results\packaging\aft_select-20-Apr-2012-22-28.mat');
%     load('C:\Users\Ana-Dani\Dropbox\RBES\results\EOS results\packaging\aft_select-16-Apr-2012-10-29.mat');
% load('C:\Users\dani\Documents\My Dropbox\RBES\results\EOS results\packaging\aft_select-16-Apr-2012-10-29.mat');
%     load('C:\Users\Ana-Dani\Dropbox\RBES\results\EOS results\packaging\bef_downsel-27-Apr-2012-7-56.mat');
    if DC == 1
        results.utilities = RBES_compute_utilities3(results,{'sciences','costs','programmatic_risks','launch_risks','data_continuities'},{'LIB','SIB','SIB','SIB','LIB'},[0.5 0.35 0.05 0.05 0.05]);
    else
        results.utilities = RBES_compute_utilities3(results,{'sciences','costs','programmatic_risks','launch_risks'},{'LIB','SIB','SIB','SIB'},[0.5 0.35 0.075 0.075]);
    end
    
    init_archs = archs;
    init_results = results;
    RBES_assert_architectures('packaging',init_archs,init_results);
    results = PACK_convergence(results,archs);
end



%% Loop
NIT = 10;
for i = 1:NIT
    fprintf('*************************************************\n');
    fprintf('PACK algorithm: starting generation %d from %d...\n',i,NIT);
    [these_results,archs] = PACK_one_iteration(); 
    fprintf('Finished generation %d from %d, with %d architectures\n',i,NIT,size(archs,1));
    these_results = PACK_convergence(these_results,archs);
    fprintf('*************************************************\n');
    close all;
    pause(1);
    PACK_plot_results(these_results,archs,i);
    pause(1);
    save_best_orbits();
end