function params = RBES_Init_Params_EOS_fct()
%% RBES_Init_Params_EOS_fct.m
RBES_Init_params_common;

%% Parameteres to control execution
params.ASSIMILATION = 0;% not needed for EOS and Decadal, only Iridium (not really true because if 2 measurements 
                        % are cross-registered and are of same parameter,
                        % should really assimilate them and thus improve
                        % revisit time and temporal resolution 
params.EXPLANATION = 1;% for GUI
params.ESTIMATE_SCIENCE = 1;
params.ESTIMATE_COST = 1;
params.SYNERGIES = 1;
params.LOAD_RULES = 0;% 1 means to load them at each submodule instead of all at the beginning, 0 otherwise

%% Paths for specific xls files 
params.requirement_rules_xls            = 'C:\Documents and Settings\Dani\My Documents\PhD\research\projects\Rule-based System Architecting\Decadal Objective Rule Definition.xlsx';
params.capability_rules_xls             = 'C:\Documents and Settings\Dani\My Documents\PhD\research\projects\Rule-based System Architecting\EOS Instrument Capability Definition.xlsx';
params.optimization_xls                 = 'C:\Documents and Settings\Dani\My Documents\PhD\research\projects\Rule-based System Architecting\EOS Case Study Parameters.xlsx';

%% Pool of instruments to be considered
load EOS_Instrument_names
params.instrument_list = EOS_Instrument_names;

%% Params for scheduling optimization (Decadal only)
params.SCHEDULING = 0;
% Budget
if params.SCHEDULING
    [num,~,~] = xlsread(params.optimization_xls,'Budgets');
    params.years = num(:,1);
    params.budget = num(:,2);

    % Mission costs
    [num,txt,~] = xlsread(params.optimization_xls,'Mission costs');

    ORIGINAL = 1;
    LATEST = 2;
    % ********************
    % Change this if needed
    COSTS = ORIGINAL;
    % ********************
    lifetimes = num(:,3);
    params.mission_costs = num(:,COSTS);
    params.mission_names = txt(2:end,1);% all Decadal missions
    % TIER_1 = [params.];
    % params.mission_names = txt(1+TIER_1,1);% consider only tier I missions

    params.NumberOfMissions = length(params.mission_names);
    params.MissionCosts = java.util.HashMap;
    params.MissionIds = java.util.HashMap;
    params.MissionFromIds = java.util.HashMap;
    params.MissionLifetimes = java.util.HashMap;
    for i = 1:params.NumberOfMissions
        params.MissionCosts.put(params.mission_names{i},params.mission_costs(i));
        params.MissionIds.put(params.mission_names{i},i);
        params.MissionFromIds.put(i,params.mission_names{i});
        params.MissionLifetimes.put(params.mission_names{i},lifetimes(i));
    end

    % Discount rates
    [num,~,~] = xlsread(params.optimization_xls,'Panel discount rates');
    params.panel_discount_rates = num(:,1);% order: WE CL LA WA HE SE
else
    params.mission_names = {'AQUA','TERRA','AURA'};% EOS
    params.MissionIds = java.util.HashMap;
    params.MissionFromIds = java.util.HashMap;
    params.NumberOfMissions = length(params.mission_names);
    for i = 1:params.NumberOfMissions
        params.MissionIds.put(params.mission_names{i},i);
        params.MissionFromIds.put(i,params.mission_names{i});
    end
end

%% Params for packaging optimization
params.MAX_SAT = 5;
params.MAX_INSTR_PER_SAT = 8;
params.MAX_COST = 4000;
params.MIN_SCIENCE = 0.06;
params.WEIGHTS = [0.5 0.5]; % weights for science and cost to form a utility
params.MIN_UTILITY = 0.1;
params.MAX_PARETO_RANK = 5;

params.ref_pach_arch = [1 1 1 2 3 1 2 3 2 2 3 3];%EOS, assume CERES and MODIS are TERRA's 

params.ref_pach_arch_map = pack_arch_to_hashmap(params.ref_pach_arch,EOS_Instrument_names,params.mission_names);

params.packaging_instrument_list    = EOS_Instrument_names(1:end); % ACE
params.satellite_names              = 'EOS';
params.db_pack_file = 'C:\Documents and Settings\Dani\My Documents\My Dropbox\RBES\db_pack_EOS.mat';

%% Watch
params.WATCH = 0;

% Memory management
clearvars -except r params
params.MEMORY_SAVE = 0;
end
