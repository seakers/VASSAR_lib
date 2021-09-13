function launch_dates = get_launch_dates_from_seq2(varargin)
global params
if nargin>1
    sequence = cell2mat(varargin);
else
    sequence = varargin{1};
end
launch_dates = zeros(1,params.SCHEDULING_num_missions);%launch_dates(i) = launch date of mission with id i
% startTime = params.years(1);
% tmpDate    = startTime;
% % launch_dates2 = java.util.HashMap;
% for i = 1:length(sequence);
%     miss_ID = sequence(i);
% %     miss = params.SCHEDULING_MissionFromIds.get(miss_ID);% string mission
%     cost = params.SCHEDULING_MissionCosts(miss_ID);% get its cost
%     year_up = ceil(tmpDate)-startTime+1;% number of years from start, rounded up
%     budget = params.budget(year_up);% Finds the budget for the next year, if a project doesn't take a full year, this will repeat budgets
%     tmpDate = tmpDate + (cost / budget); %Adds the time to launch based on budget to the time line
%     launch_dates(miss_ID) = tmpDate;
% %     launch_dates2.put(params.SCHEDULING_MissionFromIds.get(miss_ID),tmpDate);
% end

yrs = [params.startdate:1:params.enddate];
% launch_dates = java.util.HashMap;
mission_profiles = params.SCHEDULING_MissionCostProfiles.clone();
to_launch = sequence;
budgets = params.budget;
for t =1:length(yrs)
    budget = budgets(t);
    money = budget;
    next_to_launch = to_launch;
    for m = 1:length(to_launch)
        %invest on next mission
        next_miss = params.SCHEDULING_MissionFromIds.get(to_launch(m));
        profile = mission_profiles.get(next_miss);
        if isempty(profile),continue;end
        if money >= profile(1)
            money = money - profile(1);
            if length(profile)>1
                mission_profiles.put(next_miss,profile(2:end));
            else
                next_to_launch(next_to_launch == to_launch(m)) = [];
                mission_profiles.put(next_miss,[]);
                launch_dates(to_launch(m))=yrs(t);
            end
        else
%             if t < length(budgets)
%                 budgets(t+1) = budgets(t+1) + money;
%             end
            profile(1) = profile(1) - money;
            mission_profiles.put(next_miss,profile);
            break;
        end
    end
    to_launch = next_to_launch;
end
end