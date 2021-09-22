function RBES_Init_WithRules()
global params
%% Init RBES
display('Initializing Rule-based system...');
RBES_Init;

%% Define modules
display('Defining modules..');
load_modules;

%% Load templates
display('Loading templates from excel..');
load_templates2; % Uses excel Attributes for definition of instrument, and measurement templates

%% Load user functions
display('Loading user defined functions...');
load_functions;

%% Load fact databases
display('Loading mission analysis database...');
load_revisit_time_facts;
  
display('Loading instrument database...');
load_instrument_database;

%% Load rules
% Load Orbit selection rules
display('Loading orbit selection rules...');
load_orbit_selection_rules;

% Load Launch vehicle selection rules
display('Loading launch vehicle selection rules...');
load_launch_vehicle_selection_rules;

% Load standard bus selection rules
display('Loading standard bus selection rules...');
load_standard_bus_selection_rules;

% Load power budget calculation rules
display('Loading power budget calculation rules...');
load_eps_design_rules;

% Load mass budget calculation rules
display('Loading mass budget calculation rules...');
load_mass_budget_rules;

% Load cost estimation rules
display('Loading cost estimation rules...');
load_cost_estimation_rules;

% Attribute inheritance rules
display('Loading attribute inheritance rules...');
load_attribute_inheritance_rules;

% Fuzzy attribute rules
display('Loading fuzzy attribute rules...');
load_fuzzy_attribute_rules;

% Synergy rules
display('Loading synergy rules...');
load_synergy_rules2;

% Assimilation rules
display('Loading assimilation rules...');
load_assimilation_rules;

% Explanation rules
display('Loading explanation rules...');
load_explanation_rules;

% Capability rules
display('Loading instrument capability rules from excel...');
Excel = OpenExcelConnection( [pwd params.capability_rules_xls(2:end)] );
load_capability_rules(Excel);
CloseExcelConnection( Excel );

% Measuerement requirement rules (from excel)
display('Loading requirements rules from excel...');
load_requirement_rules_from_excel;
% load_requirement_rules_new;

% Requirement aggregation rules (from excel)
display('Loading requirement aggregation rules from excel...');
load_aggregation_rules_from_excel;

% display('Loading precompute science rules...');
% if ~strcmp(params.CASE_STUDY,'IRIDIUM')
%     load_precompute_science_rules;
% end

% Data continuity requirements (from excel)
display('Loading data continuity requirements from excel...');
load_data_continuity_rules_from_excel;

jess batch ".\\clp\\smap_rules_test.clp";

% load enumeration rules
display('Loading enumeration rules...');
load_enumeration_rules;

% load enumeration rules
display('Loading search heuristic rules...');
load_search_heuristic_rules;

% load down-selection rules
display('Loading down-selection rules...');
load_down_selection_rules;

% load case study specific rules
if strcmp(params.CASE_STUDY,'DECADAL')
%     load_clp('Decadal_specific_rules');
    
% jess batch "C:\\Users\\dani\\Documents\\My Dropbox\\RBES\\clp\\smap_rules_test.clp";


end

return