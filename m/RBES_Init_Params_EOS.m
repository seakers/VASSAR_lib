%% RBES_Init_Params_EOS.m
function RBES_Init_Params_EOS(varargin)
global params
params.startdate    = 1995;
params.enddate      = 2012;
params.lifetime     = 6;
params.missions_to_be_considered = 'ESA+NASA+CNES no EOS';
if nargin > 0
    RBES_Init_params_common(varargin{1});
    mode = varargin{1};
else
    RBES_Init_params_common();
end

%% Parameteres to control execution
params.ASSIMILATION = 0;% not needed for EOS and Decadal, only Iridium (not really true because if 2 measurements 
                        % are cross-registered and are of same parameter,
                        % should really assimilate them and thus improve
                        % revisit time and temporal resolution 
params.EXPLANATION = 0;% for GUI
params.ESTIMATE_SCIENCE = 1;
params.ESTIMATE_COST = 1;
params.SYNERGIES = 1;
params.LOAD_RULES = 0;% 1 means to load them at each submodule instead of all at the beginning, 0 otherwise
params.CROSS_REGISTER = 1;
params.USE_LOOKUP_TABLES = 0;
params.MODE = mode;
params.TEST = 0;
params.CASE_STUDY = 'EOS';
params.WATCH_ONLY = [];
if strcmp(mode,'SCHEDULING')
    params.DATA_CONTINUITY = 1;
else
    params.DATA_CONTINUITY = 0;
end
params.BUS = 'STANDARD';% STANDARD OR DEDICATED
% params.BUS = 'DEDICATED';% STANDARD OR DEDICATED

%% Paths for specific xls files 
params.requirement_rules_xls            = '.\xls\EOS Objective Rule Definition.xlsx';
params.aggregation_rules_xls            = '.\xls\EOS Objective Rule Definition.xlsx';
params.capability_rules_xls             = '.\xls\EOS Instrument Capability Definition.xlsx';
params.optimization_xls                 = '.\xls\EOS Case Study Parameters.xlsx';

%% Pool of instruments to be considered
% load EOS_Instrument_names % 16 instruments = 13 from TERRA, AQUA, and AURA with 3 CERES and 2 MODIS for simplified packaging or scheduling
% load EOS_Instrument_names2 % 26 instruments for packaging problem
% load EOS_Instrument_names3 % 42 instruments for selection problem
% load EOS_Instrument_names4 % 30 instruments, initial program as presented to OMB in 1989
load EOS_Instrument_names7 % 40 instruments for instrument selection with DORIS, CERES-B and -C
params.instrument_list = EOS_Instrument_names;% 
get_mask_from_instruments({'hola','si'},params.instrument_list);

%% Params for scheduling optimization
params.SCHEDULING = 1;
params.scheduling_instrument_list = regexp('ACRIM AIRS ALI ALT-SSALT AMR AMSR-E AMSU-A ASTER CALIOP CERES CERES-B CERES-C CPR DORIS ETM+ GGI GLAS GRACE HIRDLS HSB LIS MISR MLS MODIS MODIS-B MOPITT NSCAT OMI POSEIDON-3 PR SAFIRE SAGE-III SEAWIFS SOLSTICE SEAWINDS SIM TES TIM TMI TMR TOMS VIRS','\s','split');
% params.ref_sched_arch.arch = [7     8    10     1     5     6     2     4     9     3];
% Budget
if params.SCHEDULING == 1
    [num,~,~] = xlsread(params.optimization_xls,'Budgets');
    params.years = num(:,1);
    params.budget = num(:,2);

    % Mission costs
    [num,txt,~] = xlsread(params.optimization_xls,'Mission parameters');

    ORIGINAL = 1;
    LATEST = 2;

    % ********************
    % Change this if needed
    COSTS = ORIGINAL;
    % ********************

    lifetimes = num(:,3);
%     scores = num(:,4:4+params.npanels-1);
    params.SCHEDULING_mission_costs = num(:,COSTS);
    params.SCHEDULING_MissionNames = txt(2:end,1);% all Decadal missions
    params.SCHEDULING_MissionPayloads = txt(2:end,5);
    params.SCHEDULING_partnerships = num(:,5);
    params.SCHEDULING_MissionLaunchDates = num(:,6);
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
%         params.MissionScores.put(params.mission_names{i},scores(i,:));
    end

    % Discount rates
    [num,~,~] = xlsread(params.optimization_xls,'Panel discount rates');
    params.panel_discount_rates = num(:,1);% order: WE CL LA WA HE SE

%     params.ref_sched_arch.arch = SCHED_str_to_arch('ORBVIEW-SEAWIFS QUIKSCAT TERRA ACRIMSAT JASON-1 METEOR-SAGE-III AQUA ICESAT SORCE AURA');
    params.ref_sched_arch.arch = SCHED_str_to_arch('ORBVIEW-SEAWIFS TRMM TERRA LANDSAT-7 ACRIMSAT JASON-1 QUIKSCAT EO-1-NMP AQUA ADEOS-II METEOR-SAGE-III ICESAT GRACE AURA SORCE CALIPSO CLOUDSAT OSTM');
    params.SCHED_ref_discounted_value = [];
    params.SCHED_ref_data_continuity_score = [];
    
    [num,txt,~] = xlsread(params.optimization_xls,'Fine budgeting');
    params.SCHEDULING_MissionCostProfiles = java.util.HashMap;
    for i = 1:size(txt)-1
        profile =ones(1,num(i,1)).*num(i,2);
        params.SCHEDULING_MissionCostProfiles.put(txt{i+1},profile);
    end
    
elseif params.SCHEDULING == 0
    params.mission_names = {'AQUA','TERRA','AURA'};% EOS
    params.MissionIds = java.util.HashMap;
    params.MissionFromIds = java.util.HashMap;
    params.num_missions = length(params.mission_names);
    for i = 1:params.num_missions
        params.MissionIds.put(params.mission_names{i},i);
        params.MissionFromIds.put(i,params.mission_names{i});
    end
end



%% Params for selection
% [r,params] = RBES_update_science_lookup_tables(r,params);

params.ref_sel_arch.arch = [1 1 1 1 1 1 1 1 0 1 0 0 0 0 0 1 1 0 0 1 0 1 1 1 0 1 1 0 1 0 0 1 1 1 0 1 1 0 1 1];
% params.ref_sel_arch.science = 0.8188;
% params.ref_sel_arch.cost = 6642.5;
% this ref arch has cost $6313M and science (no assim) 0.5427
params.mutation_improvement_ratio = 0.5;
params.science_metric = 'MAX'; % if MAX then the max of subobjective scores is taken, if SUM the sum is taken.

load EOS_DSMs; %computed using compute_pair_scores
params.science_DSM = EOS_science_DSM;
params.engineering_DSM = EOS_engineering_DSM;
% params.instrument_indexes = java.util.HashMap;
% for i = 1:length(params.packaging_instrument_list)
%     params.instrument_indexes.put(params.instrument_list{i},i);
% end

%% Params for packaging optimization
params.potent_orbits = {'SSO-800-SSO-AM','SSO-800-SSO-PM'};
params.all_launch_vehicles = {'Shuttle-class' 'Atlas5-class' 'Delta7920-class' 'Delta7420-class' 'Delta7320-class' 'MinotaurIV-class' 'Taurus-XL-class' 'Taurus-class' 'Pegasus-class'};
params.launch_vehicles = 'Shuttle-class Atlas5-class Delta7920-class Delta7420-class Delta7320-class Taurus-XL-class Taurus-class Pegasus-class';
% params.launch_vehicles = 'Shuttle-class Atlas5-class Delta7920-class Pegasus-class';

% params.lv_ids = [1 1 1 1 1 0 1 1 1]';
params.lv_ids = [1 1 1 0 0 0 0 0 1]';

% params.orbit_ids = [0 0 0 1 0];
params.orbit_selection_rule = 'MAX_UTILITY';
params.orbit_selection_weights = [0.75 0.25];% [science cost]
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

% params.packaging_instrument_list    = params.instrument_list(logical(SEL_ref_arch()));
params.mission_names = {'AQUA','TERRA','AURA'};
params.packaging_instrument_list = {'AIRS' 'AMSR-E' 'AMSU-A' 'ASTER' 'CERES' 'CERES-B' 'CERES-C' 'HIRDLS' 'HSB' 'MISR' 'MLS' 'MODIS' 'MODIS-B' 'MOPITT' 'OMI' 'TES'};
% for i = 1:length(params.packaging_instrument_list)
%     cellfun(@(x)strcmp(x,params.packaging_instrument_list{1}),params.instrument_list)
% end
% 

% params.packaging_instrument_indexes = zeros(1,
params.packaging_instrument_indexes = zeros(1,length(params.packaging_instrument_list));% index of instrument form packaging_list in complete list.
for i = 1:length(params.packaging_instrument_list)
    if i == 13
        params.packaging_instrument_indexes(i) = find(strcmp(params.instrument_list,'MODIS'));
    else
        params.packaging_instrument_indexes(i) = find(strcmp(params.instrument_list,params.packaging_instrument_list{i}));
    end
end


params.packaging_science_DSM = java.util.HashMap;
params.packaging_engineering_DSM = java.util.HashMap;
params.list_of_synergistic_pairs = cell(length(params.packaging_instrument_list),3);
params.list_of_interfering_pairs = cell(length(params.packaging_instrument_list),3);


n = 1;
m = 1;
for i = 1:length(params.instrument_list)
    for j = i+1:length(params.instrument_list)
        if EOS_science_DSM(i,j) > 0 && ~isempty(find(params.packaging_instrument_indexes == i,1)) && ~isempty(find(params.packaging_instrument_indexes == j,1))
            params.list_of_synergistic_pairs{n,1} = params.instrument_list{i};
            params.list_of_synergistic_pairs{n,2} = params.instrument_list{j};
            params.list_of_synergistic_pairs{n,3} = EOS_science_DSM(i,j);
            n = n + 1;
        end
        if EOS_engineering_DSM(i,j) > 0 && ~isempty(find(params.packaging_instrument_indexes == i,1)) && ~isempty(find(params.packaging_instrument_indexes == j,1))
            params.list_of_interfering_pairs{m,1} = params.instrument_list{i};
            params.list_of_interfering_pairs{m,2} = params.instrument_list{j};
            params.list_of_interfering_pairs{m,3} = EOS_engineering_DSM(i,j);
            m = m + 1;
        end
    end
end

params.list_of_interfering_pairs(m:end,:) = [];
for i = 1:length(params.instrument_list)
    list = java.util.ArrayList;
    indexes1 = EOS_science_DSM(:,i) > 0;
    indexes2 = EOS_science_DSM(i,:) > 0;
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
    indexes1 = EOS_engineering_DSM(:,i) > 0;
    indexes2 = EOS_engineering_DSM(i,:) > 0;
    indexes = indexes1 + indexes2';
    if sum(indexes) > 0
        indexes = find(indexes);
        for j = 1:length(indexes)
            list.add(params.instrument_list{indexes(j)});
        end
    end
    params.packaging_engineering_DSM.put(params.instrument_list{i},list);
    
end
% params.packaging_science_DSM = EOS_science_DSM();
% params.packaging_engineering_DSM = EOS_engineering_DSM();
% params.pack_ref_arch                = [1 1 1 2 2 2 1 3 1 2 3 1 2 2 3 3];%EOS
params.ref_pack_arch.arch           = [1 1 1 2 2 2 1 3 1 2 3 1 2 2 3 3];%EOS
params.satellite_names              = 'EOS';
params.db_pack_file = 'C:\Documents and Settings\Dani\My Documents\My Dropbox\RBES\db_pack_EOS.mat';
params.ref_pach_arch_map = pack_arch_to_hashmap(params.ref_pack_arch.arch,params.packaging_instrument_list,params.mission_names);

%% Params for assigning optimization
params.assign_instrument_list = {'AIRS','AMSU-A','HSB','AMSR-E','OMI'};
params.orbit_list = {'SSO-800-SSO-AM','SSO-800-SSO-PM'};
params.ref_assign_arch.arch = [1 1 3 2 2];

%% Params for utility and pareto ranking computations
params.utility_metrics_names = {'sciences','costs'};
params.utility_metrics_types = {'LIB','SIB'};
params.utility_metrics_weights = [0.5 0.5];
params.MAX_PARETO_RANKING = 3;

%% Watch
params.WATCH = 0;
params.TALK = 0;
% Memory management
% clearvars -except r params
params.MEMORY_SAVE = 0;

%% Fast science
load pairs_subobjective_scores;
params.pairs_subobjective_scores = pairs_subobjective_scores;
load subobjective_scores_singles;
params.subobjective_scores_singles = subobjective_scores_singles;
load special_subobjective_scores;
params.special_subobjective_scores = special_subobjective_scores;

%% Results
params.path_save_results = '.\results\EOS results\';
end
