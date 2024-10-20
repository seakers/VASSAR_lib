%% PACK_Optimizer_RBES.m
% This script takes a list of instruments given in params.instrument_list
% as input and then tries to optimize their packaging
% It considers all combinations of instruments if the number of instruments
% is small enough and evaluates them in terms of science, cost, and risk.
% Differences in terms of science will come from synergies between
% cross-registered measurements. Differences in terms of cost will come
% from interferences between instruments, and schedule slippage?
% Differences in terms of risk will come from the egg basket argument.
% An architecture is represented as an array of integers of length equal to
% the number of instruments, where element i represents the id of the
% satellite that instrument i is flying on. For example, for 5 instruments:
% arch = [1 1 2 2 3] represents an architecture with 3 satellites where
% instruments 1 and 2 are together, instruments 3 and 4 are together, and
% instrument 5 is alone.

% RBES_Init_Params_Decadal;

%% Loop
quit = false;
stop = false;
BATCH = 50;
all_science = zeros(100000,1);
all_cost= zeros(100000,1);
b = 0;
all_archs = [];
while(~quit)
    while(~stop)
        %% Run 1 batch
        b = b + 1;
        clc;fprintf('Running new batch %d...\n',b);        
        clearvars -except all_science all_cost all_archs BATCH b quit stop;
        RBES_Init_Params_EOS;

        [r,params]  = RBES_Init_WithRules(params);
        Population = zeros(BATCH,13);
        for i = 1:BATCH
            tmp = ones(1,13);
            for n = 2:13
                tmp(n) = 1+round(max(tmp)*rand);
            end
            Population(i,:) = tmp;
        end

        % arch.packaging = [1 1 2 2];
        for i = 1:BATCH
            fprintf('Evaluating architecture %d of %d:',i,BATCH);
            fprintf('%d,',Population(i,:));
            fprintf('...');
            arch.packaging = Population(i,:);
            params.NumberOfMissions = max(Population(i,:));
            [science,cost] = PACK_evaluate_architecture(r,params,arch);
            all_science(i+(b-1)*BATCH) = science;
            all_cost(i+(b-1)*BATCH) = cost;
            fprintf('cost = %f science = %f\n',cost,science);
        end
         
        all_archs = [all_archs;Population];
        plot(all_cost,all_science,'bx');
        hold on
        %% Check if we want to stop
        fid = fopen('control_matlab.txt','r');
        s = fscanf(fid,'%s\n');
        if strcmp(s(end-3:end),'stop')
            stop = true;
        else
            t = clock();str = [date '-' num2str(t(4)) '-' num2str(t(5))];
            filename = ['intermediate_packaging_results-' str '.mat'];
            save filaneme science cost all_science all_cost Population all_archs
        end
    end
    fprintf('STOP\n');
    %% Show results
    plot(all_cost,all_science,'bx');
    hold on

    %% repair etc
%     disp('Repair results and type return when done');
%     keyboard;
%     
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


