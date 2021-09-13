function [metrics,results] = SCHED_evaluate_architecture(sequence,params)
%% SCHED_evaluate_architecture.m
% This function takes as an input a scheduling architecture and provides as
% outputs two  metric: discounted value and data continuity.\
% Usage: metrics = SCHED_evaluate_architecture(sequence,params)
% sequence = [4,3,2,7,...] sequence(j) = i means mission i from lost of mission
% is flown in jth position
% 
% 0) Launch dates are calculated using input sequence, and budgets and
% mission costs from params
% 1) The RBES is used to calculate raw undiscounted mission scores, with
% all synergies considered
% 2) Discounted value = sum of mission values to each panel, weighted by discount
% rate factors
% 3) Data continuity score (directly from RBES): computes sum of values of
% measurements covered by architecture
sequence = sequence{1};
fprintf('Evaluating sequence %s...',num2str(sequence));

%% 0) Compute launch dates
launch_dates = zeros(1,length(params.NumberOfMissions));%launch_dates(i) = launch date of mission with id i
startTime = params.years(1);
tmpDate    = startTime;
for i = 1:length(sequence);
    miss_ID = sequence(i);
    miss = params.MissionFromIds.get(miss_ID);% string mission
    cost = params.MissionCosts.get(miss);% get its cost
    year_up = ceil(tmpDate)-startTime+1;% number of years from start, rounded up
    budget = params.budget(year_up);% Finds the budget for the next year, if a project doesn't take a full year, this will repeat budgets
    tmpDate = tmpDate + (cost / budget); %Adds the time to launch based on budget to the time line
    launch_dates(miss_ID) = tmpDate;
end
    
%% 1) Get scores from params and discount them
discount_factor_matrix = zeros(params.NumberOfMissions,params.npanels);
% discounted_values = zeros(params.NumberOfMissions,params.npanels);
for i = 1:params.NumberOfMissions
    if (find(sequence==i,1)>0)
        dt = launch_dates(i) - params.startdate;% the launch date of mission i, as opposed of seq(i) which would be launch date of the ith mission
    else % if the mission is not manifested in the top nvars (e.g. 4)
        dt = 10000;% essentially discount everything so that this mission score does not count at all
    end
    for j = 1:params.npanels
        r = params.panel_discount_rates(j);
        discount_factor_matrix(i,j) = exp(-r*dt);
    end
end
discounted_value = sum(sum(discount_factor_matrix.*params.scores));

%% 2) Compute new data continuity score
overall_matrix = params.precursors_data_continuity_matrix;
for i = 1:length(sequence)
    % Offset corresponding params.MissionMatrices according to launch date
    % and lifetime
    matrix0 = params.MissionMatrices.get(params.MissionFromIds.get(i));
    lifetime = params.MissionLifetimes.get(params.MissionFromIds.get(i));
    launchdate = launch_dates(sequence == i);
    matrix1 = OffsetContinuityMatrix(matrix0,lifetime,launchdate,params);
    
    % Superimpose all matrices
    overall_matrix = SuperimposeContinuityMatrix(overall_matrix,matrix1);
end

% Compute data continuity score from new matrix
data_continuity_matrix_int = cellfun(@size,overall_matrix);
data_continuity_matrix_diff = data_continuity_matrix_int - params.precursors_data_continuity_integer_matrix;
data_continuity_matrix_diff(data_continuity_matrix_diff < 0) = 0;%only improvements are considered
data_continuity_score = params.measurement_weights_for_data_continuity*data_continuity_matrix_diff*params.data_continuity_weighting_scheme;

%% Compute data continuity and data value scores (need to be SIB)
NORM_FACTOR1 = -5;
NORM_FACTOR2 = -40*181;
metrics = [discounted_value/NORM_FACTOR1 data_continuity_score/NORM_FACTOR2];
results.overall_dcmatrix = overall_matrix;
fprintf('DV= %f, DC = %f...\n',metrics(1),metrics(2));

end