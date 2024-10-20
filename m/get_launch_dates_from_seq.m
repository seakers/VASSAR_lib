function launch_dates = get_launch_dates_from_seq(varargin)
global params
if nargin>1
    sequence = cell2mat(varargin);
else
    sequence = varargin{1};
end
launch_dates = zeros(1,params.SCHEDULING_num_missions);%launch_dates(i) = launch date of mission with id i
startTime = params.years(1);
tmpDate    = startTime;
% launch_dates2 = java.util.HashMap;
for i = 1:length(sequence);
    miss_ID = sequence(i);
%     miss = params.SCHEDULING_MissionFromIds.get(miss_ID);% string mission
    cost = params.SCHEDULING_MissionCosts(miss_ID);% get its cost
    year_up = ceil(tmpDate)-startTime+1;% number of years from start, rounded up
    budget = params.budget(year_up);% Finds the budget for the next year, if a project doesn't take a full year, this will repeat budgets
    tmpDate = tmpDate + (cost / budget); %Adds the time to launch based on budget to the time line
    launch_dates(miss_ID) = tmpDate;
%     launch_dates2.put(params.SCHEDULING_MissionFromIds.get(miss_ID),tmpDate);
end
end