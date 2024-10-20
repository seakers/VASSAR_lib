function results = SCHED_evaluate_architecture3(sequence)
%% SCHED_evaluate_architecture2.m
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
% sequence = sequence{1};

global params
% r = global_jess_engine();
fprintf('Evaluating sequence %s...',SCHED_arch_to_str(sequence));

%% 0) Compute launch dates
% launch_dates = zeros(1,params.SCHEDULING_num_missions);%launch_dates(i) = launch date of mission with id i
% startTime = params.years(1);
% tmpDate    = startTime;
% launch_dates2 = java.util.HashMap;
% for i = 1:length(sequence);
%     miss_ID = sequence(i);
% %     miss = params.SCHEDULING_MissionFromIds.get(miss_ID);% string mission
%     if isjava(params.SCHEDULING_MissionCosts)
%         miss = params.SCHEDULING_MissionFromIds.get(miss_ID);
%         cost = params.SCHEDULING_MissionCosts.get(miss);
%     else
%         cost = params.SCHEDULING_MissionCosts(miss_ID);% get its cost
%     end
%     
%     year_up = ceil(tmpDate)-startTime+1;% number of years from start, rounded up
%     budget = params.budget(year_up);% Finds the budget for the next year, if a project doesn't take a full year, this will repeat budgets
%     tmpDate = tmpDate + (cost / budget); %Adds the time to launch based on budget to the time line
%     launch_dates(miss_ID) = tmpDate;
%     launch_dates2.put(params.SCHEDULING_MissionFromIds.get(miss_ID),tmpDate);
% end
launch_dates = get_launch_dates_from_seq2(sequence);

%% 1) Get scores from params and discount them
discount_factor_matrix = zeros(params.SCHEDULING_num_missions,params.npanels);
% discounted_values = zeros(params.NumberOfMissions,params.npanels);
for i = 1:params.SCHEDULING_num_missions
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
discounted_value = sum(sum(discount_factor_matrix.*params.SCHEDULING_mission_panel_scores));

%% 2) Compute new data continuity score
overall_matrix = params.precursors_data_continuity_matrix;
for i = 1:length(sequence)
    % Offset corresponding params.MissionMatrices according to launch date
    % and lifetime
    matrix0 = params.SCHEDULING_MissionMatrices.get(params.SCHEDULING_MissionFromIds.get(sequence(i)));
    lifetime = params.SCHEDULING_MissionLifetimes.get(params.SCHEDULING_MissionFromIds.get(sequence(i)));
    launchdate2 = launch_dates(sequence(i));
    matrix1 = OffsetContinuityMatrix(matrix0,lifetime,launchdate2);
    
    % Superimpose all matrices
    overall_matrix = SuperimposeContinuityMatrix(overall_matrix,matrix1);
end

% Compute data continuity score from new matrix
data_continuity_matrix_int = cellfun(@size,overall_matrix);
data_continuity_matrix_diff = data_continuity_matrix_int - params.precursors_data_continuity_integer_matrix;
data_continuity_matrix_diff(data_continuity_matrix_diff < 0) = 0;%only improvements are considered
data_continuity_score = params.measurement_weights_for_data_continuity*data_continuity_matrix_diff*params.data_continuity_weighting_scheme;

%% Compute data continuity and data value scores (need to be SIB)
ref = params.ref_sched_arch;
if isfield(ref,'discounted_value')
    NORM_FACTOR1 = ref.discounted_value;
    NORM_FACTOR2 = ref.data_continuity;% -40*181
else
    NORM_FACTOR1 = 1;
    NORM_FACTOR2 = 1;
end
% metrics = [discounted_value/NORM_FACTOR1 data_continuity_score/NORM_FACTOR2];
results.overall_dcmatrix = overall_matrix;
results.launch_dates = launch_dates;
results.discounted_value = discounted_value/NORM_FACTOR1;
results.data_continuity_score = data_continuity_score/NORM_FACTOR2;
fprintf('DV= %f, DC = %f...\n',results.discounted_value,results.data_continuity_score);

end