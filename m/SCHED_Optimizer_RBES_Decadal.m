%% SCHED_Optimizer_RBES.m
% This script takes a list of missions as an input and finds the optimal
% mission sequence and launch dates

%% Setup RBES
RBES_Init_Params_Decadal;
[r,params]  = RBES_Init_WithRules(params);

%% Compute in preprocessing step the individual mission scores with RBES
params.scores = zeros(params.NumberOfMissions,params.npanels);
params.MissionScores = java.util.HashMap;
params.MissionMatrices = java.util.HashMap;
cont_matrices = cell(params.NumberOfMissions,1);
for i = 1:params.NumberOfMissions
    clear explanation_facility
    r.reset;
    miss_str = params.MissionFromIds.get(i);% mission str, e.g. 'ACE'
    fprintf('Preprocessing mission %s...\n',miss_str);
    payload = params.ref_pach_arch_map.get(miss_str);% an array of java strings
    instr_list_str = StringArraytoStringWithSpaces(payload);% transforms array of strings into single string with spaces for Jess
    orbit_params = params.MissionOrbitParameters.get(miss_str);
    
    call = ['(assert (MANIFEST::Mission (Name ' miss_str ')' ...
        ' (orbit-altitude# ' num2str(orbit_params(3)) ')' ...
        ' (orbit-inclination ' num2str(orbit_params(4)) ')' ...
        ' (orbit-RAAN ' num2str(orbit_params(5)) ')' ...
        ' (orbit-anomaly# ' num2str(orbit_params(6)) ')' ...
        ' (instruments ' instr_list_str ')' ...
        ' (lifetime ' num2str(params.MissionLifetimes.get(miss_str)) ')' ...
        ' (launch-date ' num2str(params.startdate) ')' ...
        '))'];
    r.eval(call);
    
    % assert cross-registered instruments
    if length(payload) > 1 % more than one instrument
        call = ['(assert (SYNERGIES::cross-registered-instruments '...
    ' (instruments ' instr_list_str ') '...
    ' (degree-of-cross-registration spacecraft) '...
    ' (platform ' miss_str ' ) '...
    '))' ];
        r.eval(call);
    end
    
    results = RBES_Evaluate_Manifest(r,params);
    params.scores(i,:) = results.panel_scores;
    score = results.panel_scores'*params.panel_weights;
    fprintf('Preprocessing mission %s done, score = %d\n',miss_str,score);
    params.MissionScores.put(miss_str,results.panel_scores);
    params.MissionMatrices.put(miss_str,results.dcmatrix_without_precursors);
    cont_matrices{i} = results.data_continuity_matrix;% with precursors
    
end

%% Setup GA
% nvars = params.NumberOfMissions;
nvars = 4;% only consider forst 4 missions

options = gaoptimset;
options = gaoptimset(options, 'PopulationType' , 'custom');
options = gaoptimset(options, 'CreationFcn',     @(x,y,z)createPermutations(x,y,z,params));
options = gaoptimset(options, 'SelectionFcn' ,   {  @selectiontournament [] });
options = gaoptimset(options, 'CrossoverFcn' ,   @crossoverPermutation);
options = gaoptimset(options, 'MutationFcn' ,    @mutatePermutation);
options = gaoptimset(options, 'PlotFcns',        @gaplotpareto);
options = gaoptimset(options, 'Display' ,        'iter');
options = gaoptimset(options, 'Generations',     10);
options = gaoptimset(options, 'PopulationSize',  20);
options = gaoptimset(options, 'InitialPopulation',params.good_sched_archs);

%% Loop
quit = false;
stop = false;

while(~quit)
    while(~stop)
        %% Run 10 generations of the GA
        clc;disp('Running GA...');
        [x,fval,exitflag,output,population,score] = ...
        gamultiobj(@(x)SCHED_evaluate_architecture(x,params),nvars,[],[],[],[],[],[],options);

        %% Check if we want to stop
        fid = fopen('control_matlab.txt','r');
        s = fscanf(fid,'%s\n');
        if strcmp(s(end-3:end),'stop')
            stop = true;
        else
            save intermediate_scheduling_results.mat x fval output population score
        end
    end
    
    %% Show results
    
    %% repair etc
    disp('Repair results and type return when done');
    keyboard;
    
    %% Check if we want to quit
    fid = fopen('control_matlab.txt','r');
    s = fscanf(fid,'%s\n');
    if strcmp(s(end-3:end),'quit')
        quit = true;
    else
        % clean matlab control file and continue
        stop = false;
        fid = fopen('control_matlab.txt','w');
        fprintf(fid,'%s\n','%% write stop on next line to stop matlab execution')
        fclose(fid);
    end
    
end


