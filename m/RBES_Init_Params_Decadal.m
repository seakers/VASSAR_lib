%% RBES_Init_Params_Decadal.m
function RBES_Init_Params_Decadal(varargin)
global params
params.startdate    = 2010;
params.enddate      = 2050;
params.lifetime     = 6;
params.missions_to_be_considered = 'NASA only, no Decadal';
if nargin > 0
    RBES_Init_params_common(varargin{1});
     mode = varargin{1};
else
    RBES_Init_params_common();
end

%% Parameteres to control execution
params.ASSIMILATION = 1;% 

params.EXPLANATION = 0;% for GUI
params.ESTIMATE_SCIENCE = 1;
params.ESTIMATE_COST = 1;
params.SYNERGIES = 1;
params.LOAD_RULES = 0;% 1 means to load them at each submodule instead of all at the beginning, 0 otherwise
params.CROSS_REGISTER = 1;
params.USE_LOOKUP_TABLES = 0;
params.MODE = mode;
params.CASE_STUDY = 'DECADAL';
params.WATCH_ONLY = [];
if strcmp(mode,'SCHEDULING')
    params.DATA_CONTINUITY = 1;
else
    params.DATA_CONTINUITY = 0;
end
params.BUS = 'DEDICATED';% STANDARD OR DEDICATED

%% Paths for specific xls files 
params.requirement_rules_xls = '.\xls\Decadal Objective Rule Definition.xlsx';
params.capability_rules_xls= '.\xls\Decadal Instrument Capability Definition.xlsx';
params.aggregation_rules_xls = '.\xls\Decadal Objective Rule Definition.xlsx';

params.optimization_xls= '.\xls\Decadal Case Study Parameters.xlsx';


%% Pool of instruments to be considered
% [~,txt,~] = xlsread(params.optimization_xls,'Ref packaging');
load Decadal_Instrument_names
params.instrument_list = Decadal_Instrument_names;
get_mask_from_instruments({'hola','si'},params.instrument_list);

%% Params for scheduling optimization (Decadal only)
% params.good_sched_archs{1} = [9 4 8 11];% From 9/16/11 run 1 HISPYRI DESDYNI GRACE-II ACE, DV = 0.4311 DC = 0.1077
% params.good_sched_archs{2} = [7 10 11 2];% From 9/16/11 run 1 GPSRO ICESAT-II ACE ASCENDS, DV = 0.2011 DC = 0.2072
% params.good_sched_archs{3} = [3 15 4 16];% From 9/16/11 run 1 CLARREO SWOT DESDYNI XOVWM, DV = 0.3139 DC = 0.1409
% params.good_sched_archs{4} = [3 15 1 2];% From 9/16/11 run 2 CLARREO SWOT ACE ASCENDS, DV = 0.3139 DC = 0.1409
% params.good_sched_archs{5} = [9 11 1 16];% From 9/16/11 run 2 HYSPIRI LIST ACE XOVWM, DV = 0.3139 DC = 0.1409
params.SCHEDULING = 1;
if params.SCHEDULING == 1
% Budget
    [num,~,~] = xlsread(params.optimization_xls,'Budgets');
    params.years = num(:,1);
    params.budget = num(:,2);

    % Mission costs
    [num,txt,~] = xlsread(params.optimization_xls,'Mission parameters');

    ORIGINAL = 1;
    LATEST = 2;
    % ********************
    % Change this if needed
    COSTS = LATEST;
    % ********************
    lifetimes = num(:,3);
    params.SCHEDULING_mission_costs = num(:,COSTS);
    params.SCHEDULING_MissionNames = txt(2:end,1);% all Decadal missions
    params.SCHEDULING_MissionPayloads = txt(2:end,5);
    params.SCHEDULING_partnerships = num(:,5);
    params.SCHEDULING_num_missions = length(params.SCHEDULING_MissionNames);
    params.SCHEDULING_MissionCosts = java.util.HashMap;
    params.SCHEDULING_MissionIds = java.util.HashMap;
    params.SCHEDULING_MissionFromIds = java.util.HashMap;
    params.SCHEDULING_MissionLifetimes = java.util.HashMap;
    params.SCHEDULING_MissionScores = java.util.HashMap;

    for i = 1:params.SCHEDULING_num_missions
        params.SCHEDULING_MissionCosts.put(params.SCHEDULING_MissionNames{i},params.SCHEDULING_mission_costs(i));
        params.SCHEDULING_MissionIds.put(params.SCHEDULING_MissionNames{i},i);
        params.SCHEDULING_MissionFromIds.put(i,params.SCHEDULING_MissionNames{i});
        params.SCHEDULING_MissionLifetimes.put(params.SCHEDULING_MissionNames{i},lifetimes(i));
        % params.MissionScores.put(params.mission_names{i},scores(i,:));
    end

    % Discount rates
    [num,~,~] = xlsread(params.optimization_xls,'Panel discount rates');
    params.panel_discount_rates = num(:,1);% order: WE CL LA WA HE SE

    params.SCHED_ref_arch = SCHED_str_to_arch('SMAP ICESAT-II DESDYNI CLARREO GPSRO ASCENDS ACE GEO-CAPE SWOT HYSPIRI XOVWM GACM GRACE-II LIST PATH SCLP 3DWINDS');
    params.ref_sched_arch.arch = SCHED_str_to_arch('SMAP ICESAT-II DESDYNI CLARREO GPSRO ASCENDS ACE GEO-CAPE SWOT HYSPIRI XOVWM GACM GRACE-II LIST PATH SCLP 3DWINDS');
    params.SCHED_ref_discounted_value = [];
    params.SCHED_ref_data_continuity_score = [];
    [num,txt,~] = xlsread(params.optimization_xls,'Fine budgeting');
    params.SCHEDULING_MissionCostProfiles = java.util.HashMap;
    for i = 1:size(txt)-1
        profile =ones(1,num(i,1)).*num(i,2);
        params.SCHEDULING_MissionCostProfiles.put(txt{i+1},profile);
    end
    
elseif params.SCHEDULING == 0
    params.mission_names = {'ACE' 'ASCENDS' 'CLARREO' 'DESDYNI' 'GACM' 'GEO-CAPE' 'GPSRO' 'GRACE-II' ...
    'HYSPIRI' 'ICESAT-II' 'LIST' 'PATH' 'SCLP' 'SMAP' 'SWOT' 'XOVWM' '3DWINDS'};
    params.MissionIds = java.util.HashMap;
    params.MissionFromIds = java.util.HashMap;
    params.num_missions = length(params.mission_names);
    for i = 1:params.num_missions
        params.MissionIds.put(params.mission_names{i},i);
        params.MissionFromIds.put(i,params.mission_names{i});
    end
    
    
    
end

%% Decadal mission orbit parameters
[num,txt,raw] = xlsread(params.optimization_xls,'Mission orbits');
params.MissionOrbitParameters = java.util.HashMap;
for i = 1:size(num,1)
list = cell(1,6);
list{1} = raw{i+1,2};%architecture
list{2} = raw{i+1,3};%type
list{3} = raw{i+1,4};%altitude
list{4} = raw{i+1,5};%inclination
list{5} = raw{i+1,6};%raan
list{6} = raw{i+1,7};%anomaly
params.MissionOrbitParameters.put(txt{i+1,1},list);
end

load('./mat/Decadal_best_orbits');
params.best_orbits = best_orbits;

%% Params for selection
% [r,params] = RBES_update_science_lookup_tables(r,params);

params.ref_sel_arch.arch = ones(1,39);
% params.ref_sel_arch.science = 0.8188;
% params.ref_sel_arch.cost = 6642.5;
% this ref arch has cost $6313M and science (no assim) 0.5427
params.mutation_improvement_ratio = 0.5;
params.science_metric = 'MAX'; % if MAX then the max of subobjective scores is taken, if SUM the sum is taken.

load Decadal_DSMs; %computed using compute_pair_scores
params.science_DSM = Decadal_science_DSM;
params.engineering_DSM = Decadal_engineering_DSM;
% params.instrument_indexes = java.util.HashMap;
% for i = 1:length(params.packaging_instrument_list)
% params.instrument_indexes.put(params.instrument_list{i},i);
% end


%% Params for packaging optimization
params.potent_orbits = {'LEO-400-polar-NA','SSO-400-SSO-AM',...
    'SSO-400-SSO-DD','LEO-600-polar-NA','SSO-600-SSO-AM','SSO-600-SSO-DD','SSO-800-SSO-AM','SSO-800-SSO-DD'};
params.launch_vehicles = 'Shuttle-class Atlas5-class Delta7920-class Delta7420-class Delta7320-class MinotaurIV-class Taurus-class Taurus-XL-class Pegasus-class';
params.orbit_selection_rule = 'MAX_UTILITY';
params.orbit_selection_weights = [0.5 0.5];
params.all_launch_vehicles = {'Shuttle-class' 'Atlas5-class' 'Delta7920-class' 'Delta7420-class' 'Delta7320-class' 'MinotaurIV-class' 'Taurus-XL-class' 'Taurus-class' 'Pegasus-class'};
params.lv_ids = [1 1 1 1 1 1 1 1 1]';
params.launch_vehicle_performances =  ...
[50000	50000	50000	50000	50000	50000	20000;
20000	20000	15000	15000	10000	10000	10000; 
3642	3600	 3482 	3400	3328	3200	500;
2269	2257	 2162 	2123	2059	1989	300;
1982	1860	 1882 	1740	1787	1620	250;
1225	1180	 1160 	1110	1100	1050	0;
1015	1053	 927 	961.5	839	870	0;
1015	1053	 927 	961.5	839	870	0;
300	280	 255 	240	208	190	0];
load('./mat/Decadal_best_orbits');
params.best_orbits = best_orbits;
params.MAX_SAT = 5;
params.MAX_INSTR_PER_SAT = 8;
params.MAX_COST = 4000;
params.MIN_SCIENCE = 0.06;
params.WEIGHTS = [0.5 0.5]; % weights for science and cost to form a utility
params.MIN_UTILITY = 0.1;
params.MAX_PARETO_RANK = 5;
% params.mission_names = {'ACE' 'ASCENDS' 'CLARREO' 'DESDYNI' 'GACM' 'GEO-CAPE' 'GPSRO' 'GRACE-II' ...
%     'HYSPIRI' 'ICESAT-II' 'LIST' 'PATH' 'SCLP' 'SMAP' 'SWOT' 'XOVWM' '3DWINDS'};
% params.mission_names = {'ACE' 'ASCENDS' 'CLARREO' 'DESDYNI' 'GACM'  ...
%     'HYSPIRI' 'ICESAT-II' 'LIST' 'SCLP' 'SMAP' 'SWOT' 'XOVWM' '3DWINDS'};
params.mission_names = {'CLARREO' 'ASCENDS' 'DESDYNI' 'HYSPIRI' 'ICESAT-II' 'SMAP'};

% params.ref_pack_arch.arch = [1 1 1 1 2 2 2 3 3 3 4 4 5 5 5 5 6 6 7 8 9 9 10 10 11 11 11 11 12 12 12 13 13];
% params.ref_pack_arch.arch = [1 1 1 1 2 2 2 3 3 4 4 5 6 6];
params.ref_pack_arch.arch = [1 1 1 2 2 2 3 3 4 4 5 6 6];

params.ref_pach_arch_map = pack_arch_to_hashmap(params.ref_pack_arch.arch,Decadal_Instrument_names,params.mission_names);

params.packaging_instrument_list= Decadal_packaging_instrument_names; % all except GEO, GPSRO, GRACE (33)
params.satellite_names= 'Decadal';

params.packaging_instrument_indexes = zeros(1,length(params.packaging_instrument_list));% index of instrument form packaging_list in complete list.
for i = 1:length(params.packaging_instrument_list)
        params.packaging_instrument_indexes(i) = find(strcmp(params.instrument_list,params.packaging_instrument_list{i}));
end


params.packaging_science_DSM = java.util.HashMap;
params.packaging_engineering_DSM = java.util.HashMap;
params.list_of_synergistic_pairs = cell(length(params.packaging_instrument_list),3);
params.list_of_interfering_pairs = cell(length(params.packaging_instrument_list),3);


n = 1;
m = 1;
for i = 1:length(params.instrument_list)
    for j = i+1:length(params.instrument_list)
        if Decadal_science_DSM(i,j) > 0 && ~isempty(find(params.packaging_instrument_indexes == i,1)) && ~isempty(find(params.packaging_instrument_indexes == j,1))
            params.list_of_synergistic_pairs{n,1} = params.instrument_list{i};
            params.list_of_synergistic_pairs{n,2} = params.instrument_list{j};
            params.list_of_synergistic_pairs{n,3} = Decadal_science_DSM(i,j);
            n = n + 1;
        end
        if Decadal_engineering_DSM(i,j) > 0 && ~isempty(find(params.packaging_instrument_indexes == i,1)) && ~isempty(find(params.packaging_instrument_indexes == j,1))
            params.list_of_interfering_pairs{m,1} = params.instrument_list{i};
            params.list_of_interfering_pairs{m,2} = params.instrument_list{j};
            params.list_of_interfering_pairs{m,3} = Decadal_engineering_DSM(i,j);
            m = m + 1;
        end
    end
end

params.list_of_interfering_pairs(m:end,:) = [];
for i = 1:length(params.instrument_list)
    list = java.util.ArrayList;
    indexes1 = Decadal_science_DSM(:,i) > 0;
    indexes2 = Decadal_science_DSM(i,:) > 0;
    indexes = indexes1 + indexes2';
    if sum(indexes) > 0
        indexes = find(indexes);
        for j = 1:length(indexes)
            list.add(params.instrument_list{indexes(j)});
        end
    end
    params.packaging_science_DSM.put(params.instrument_list{i},list);
%     clear list;
    
    list = java.util.ArrayList;
    indexes1 = Decadal_engineering_DSM(:,i) > 0;
    indexes2 = Decadal_engineering_DSM(i,:) > 0;
    indexes = indexes1 + indexes2';
    if sum(indexes) > 0
        indexes = find(indexes);
        for j = 1:length(indexes)
            list.add(params.instrument_list{indexes(j)});
        end
    end
    params.packaging_engineering_DSM.put(params.instrument_list{i},list);
    
end
%% Fast science
load Decadal_pairs_subobjective_scores;
params.pairs_subobjective_scores = pairs_subobjective_scores;
load Decadal_subobjective_scores_singles;
params.subobjective_scores_singles = subobjective_scores_singles;
load Decadal_special_subobjective_scores;
params.special_subobjective_scores = special_subobjective_scores;

%% Watch
params.WATCH = 0;
params.TALK = 0;
% Memory management
% clearvars -except r params
params.MEMORY_SAVE = 0;

%% Results
params.path_save_results = '.\results\Decadal results\';
end
